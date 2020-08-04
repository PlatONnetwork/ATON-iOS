//
//  AssetController.swift
//  platonWallet
//
//  Created by Admin on 26/3/2020.
//  Copyright © 2020 ju. All rights reserved.
//

import Foundation
import BigInt

class AssetController {
    let viewModel: AssetViewModel

    let headerController: AssetWalletsHeaderController
    let sectionController: AssetWalletsSectionController

    init(viewModel: AssetViewModel = AssetViewModel()) {
        self.viewModel = viewModel

        let headerViewModel = AssetHeaderViewModel()
        self.headerController = AssetWalletsHeaderController(viewModel: headerViewModel)
        self.sectionController = AssetWalletsSectionController(viewModel: AssetSectionViewModel())

        initialViewModel()
        initialTimers()
        initialObserver()
        initialTimers()
    }

    func initialViewModel() {
        guard let selectedAddress = AssetVCSharedData.sharedData.selectedWalletAddress else { return }
        viewModel.transactionsData.value[selectedAddress] = viewModel.transactionsData.value[selectedAddress]?.filter { !$0.isInvalidated }
        refreshPendingData()
        fetchTransactionLastest()
    }

    func initialObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(nodeDidSwitch), name: Notification.Name(NodeStoreService.didSwitchNodeNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveTransactionUpdate(_:)), name: Notification.Name.ATON.DidUpdateTransactionByHash, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pollingWalletTransactions), name: Notification.Name.ATON.UpdateTransactionList, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willDeleteWallet(_:)), name: Notification.Name.ATON.WillDeleateWallet, object: nil)

        // observer
        AssetVCSharedData.sharedData.registerHandler(object: self) { [weak self] in
            guard let self = self else { return }
            self.viewModel.isHideSectionView.value = (AssetVCSharedData.sharedData.walletList.count == 0)

            guard let wallet = AssetVCSharedData.sharedData.selectedWallet as? Wallet else { return }
            self.sectionController.viewModel.wallet.value = wallet
            self.sectionController.viewModel.freeBalance.value = self.sectionController.viewModel.wallet.value?.freeBalance ?? BigUInt.zero
            self.sectionController.viewModel.lockBalance.value = self.sectionController.viewModel.wallet.value?.lockBalance ?? BigUInt.zero
            var isShowBackupPromptView = wallet.canBackupMnemonic
            if let parentWallet = WalletHelper.fetchParentWallet(from: wallet) {
                isShowBackupPromptView = parentWallet.canBackupMnemonic
            }
            self.viewModel.isShowBackupPromptView.value = isShowBackupPromptView

            self.fetchTransactionLastest()
        }

        AssetCoreService.shared.registerHandler(object: self) { [weak self] in
            guard let self = self else { return }
            self.sectionController.viewModel.assetIsHide.value = AssetCoreService.shared.assetVisible
        }

        NetworkStatusService.shared.registerHandler(object: self) { [weak self] in
            guard let self = self else { return }
            self.sectionController.viewModel.wallet.active()
            self.headerController.viewModel.walletViewModels.active()
            self.viewModel.isShowOfflinePromptView.value = !NetworkStatusService.shared.isConnecting
        }
    }

    func initialTimers() {
        let pollingTimer = Timer.scheduledTimer(timeInterval: TimeInterval(AppConfig.TimerSetting.balancePollingTimerInterval), target: self, selector: #selector(pollingGetBalance), userInfo: nil, repeats: true)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func fetchTransactionLastest() {
        guard let selectedAddress = AssetVCSharedData.sharedData.selectedWalletAddress else { return }
        fetchTransaction(address: selectedAddress, beginSequence: -1, completion: nil)
    }

    func fetchTransaction(address: String, beginSequence: Int64, completion: (() -> Void)?) {
        viewModel.isFetching.value = true
        TransactionService.service.getBatchTransaction(addresses: [address], beginSequence: beginSequence, listSize: 20, direction: "new") { [weak self] (result, response) in
            self?.viewModel.isFetching.value = false
            guard let self = self else { return }

            switch result {
            case .success:
                // 返回的交易数据条数为0，则显示无加载更多
                guard let remoteTransactions = response, remoteTransactions.count > 0 else {
                    if let count = self.viewModel.transactionsData.value[address]?.count {
                        self.viewModel.isShowFooterMore.value = !(count < 20)
                    } else {
                        self.viewModel.isShowFooterMore.value = false
                    }
                    self.viewModel.transactionsData.value[address] = []
                    return
                }

                for tx in remoteTransactions {
                    tx.direction = tx.getTransactionDirection(address)
                }

                var pendingexcludedTxs: [Transaction] = []
                pendingexcludedTxs.append(contentsOf: remoteTransactions)

                let txHashes = remoteTransactions.map { $0.txhash!.add0x() }

                var timeouttxs = self.getTimeoutTransaction()
                timeouttxs = timeouttxs.filter { !txHashes.contains($0.txhash!.add0x()) }

                if timeouttxs.count > 0 {
                    let mappedTimeoutTxs = timeouttxs.map({ (t) -> Transaction in
                        //交易时间临时赋值给确认时间，仅用于交易的排序
                        if t.createTime != 0 {
                            t.confirmTimes = t.createTime
                        } else if t.confirmTimes != 0 && t.createTime == 0 {
                            t.createTime = t.confirmTimes
                        }
                        return t
                    })
                    pendingexcludedTxs.append(contentsOf: mappedTimeoutTxs)
                    pendingexcludedTxs.sortByConfirmTimes()
                }
                var pendingTransaction = self.getPendingTransation()
                pendingTransaction = pendingTransaction.filter { !txHashes.contains($0.txhash!.add0x()) }
                pendingTransaction.append(contentsOf: pendingexcludedTxs)

                self.viewModel.transactionsData.value[address] = pendingTransaction
                self.fetchWalletBalance()

                if let count = self.viewModel.transactionsData.value[address]?.count {
                    self.viewModel.isShowFooterMore.value = !(count < 20)
                } else {
                    self.viewModel.isShowFooterMore.value = false
                }
                completion?()
            case .failure:
                completion?()
            }
        }
    }

    func fetchWalletBalance() {
        // 获取余额并没有进行改造，保持原来的获取方式
        AssetService.sharedInstace.fetchWalletBalanceForV7 { [weak self] (result, _) in
            switch result {
            case .success:
                self?.headerController.viewModel.totalBalance.value = AssetService.sharedInstace.totalFreeBalance
                self?.sectionController.viewModel.freeBalance.value = self?.sectionController.viewModel.wallet.value?.freeBalance ?? BigUInt.zero
                self?.sectionController.viewModel.lockBalance.value = self?.sectionController.viewModel.wallet.value?.lockBalance ?? BigUInt.zero
            case .fail:
                break
            }
        }
    }

    func getTimeoutTransaction() -> [Transaction] {
        guard let selectedAddress = AssetVCSharedData.sharedData.selectedWalletAddress else { return [] }
        var transactions = TransferPersistence.getTransactionsByAddress(from: selectedAddress, status: TransactionReceiptStatus.timeout, detached: true)
        transactions.txSort()
        for tx in transactions {
            tx.direction = tx.getTransactionDirection(selectedAddress)
        }
        return transactions
    }

    func getPendingTransation() -> [Transaction] {
        guard let selectedAddress = AssetVCSharedData.sharedData.selectedWalletAddress else { return [] }
        let pendingTxsInDB = TransferPersistence.getTransactionsByAddress(from: selectedAddress, status: TransactionReceiptStatus.pending)
        for tx in pendingTxsInDB {
            tx.direction = tx.getTransactionDirection(selectedAddress)
        }
        return pendingTxsInDB
    }

    func refreshPendingData() {
        guard let selectedAddress = AssetVCSharedData.sharedData.selectedWalletAddress else { return }
        let pendingTransactions = getPendingTransation()
        viewModel.transactionsData.value[selectedAddress] = viewModel.transactionsData.value[selectedAddress]?.filter { $0.sequence != nil && $0.sequence != 0 }
        guard viewModel.transactionsData.value[selectedAddress] != nil else {
            viewModel.transactionsData.value[selectedAddress] = pendingTransactions
            return
        }
        viewModel.transactionsData.value[selectedAddress]!.insert(contentsOf: pendingTransactions, at: 0)
    }

    @objc func nodeDidSwitch() {
        viewModel.transactionsData.value = [String: [Transaction]]()
    }

    @objc func didReceiveTransactionUpdate(_ notification: Notification) {
        // 由于余额发生变化时会更新交易记录，因此，这里并需要再次更新

        guard let selectedAddress = AssetVCSharedData.sharedData.selectedWalletAddress else { return }
        guard let txStatus = notification.object as? TransactionsStatusByHash, let status = txStatus.txReceiptStatus else { return }
        fetchTransaction(address: selectedAddress, beginSequence: -1) { [weak self] in
            guard let self = self else { return }
            for txObj in self.viewModel.transactionsData.value {
                for tx in txObj.value {
                    if tx.txhash?.lowercased() == txStatus.hash?.lowercased() {
                        tx.txReceiptStatus = status.rawValue
                    }
                }
            }
        }
    }

    @objc func pollingGetBalance() {
        AssetService.sharedInstace.fetchWalletBalanceForV7(nil)
    }

    @objc func pollingWalletTransactions() {
        guard AssetVCSharedData.sharedData.walletList.count > 0 else { return }
        fetchTransactionLastest()
    }

    @objc func willDeleteWallet(_ notification: Notification) {
        guard let selectedAddress = AssetVCSharedData.sharedData.selectedWalletAddress else {
            fetchLatestData()
            return
        }
        guard let wallet = notification.object as? Wallet else { return }
        guard wallet.address.lowercased() == selectedAddress.lowercased() else { return }
        var tempData = viewModel.transactionsData.value
        tempData[selectedAddress]?.removeAll()
        viewModel.transactionsData.value = tempData
    }

    func fetchLatestData() {
        fetchWalletBalance()
        fetchTransactionLastest()
    }

    func fetchWallets() {
        headerController.updateWalletList()
        sectionController.viewModel.wallet.value = (AssetVCSharedData.sharedData.selectedWallet as? Wallet)
    }
}
