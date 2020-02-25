//
//  MyDelegatesViewController.swift
//  platonWallet
//
//  Created by Admin on 24/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import Localize_Swift
import EmptyDataSet_Swift
import MJRefresh
import BigInt
import platonWeb3

class MyDelegatesViewController: BaseViewController, IndicatorInfoProvider {

    var itemInfo: IndicatorInfo = IndicatorInfo(title: "staking_main_mydelegate_text")

    lazy var tableView = { () -> ATableView in
        let tbView = ATableView(frame: .zero)
        tbView.delegate = self
        tbView.dataSource = self
        tbView.register(MyDelegateViewCell.self, forCellReuseIdentifier: "MyDelegateViewCell")
        tbView.separatorStyle = .none
        tbView.backgroundColor = normal_background_color
        if #available(iOS 11, *) {
            tbView.estimatedRowHeight = UITableView.automaticDimension
        } else {
            tbView.estimatedRowHeight = 100
        }
        return tbView
    }()

    let headerView = MyDelegateHeaderView()
    lazy var footerView = { () -> MyDelegateFooterView in
        let fView = MyDelegateFooterView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 80))
        fView.faqButton.addTarget(self, action: #selector(faqTapAction), for: .touchUpInside)
        fView.turButton.addTarget(self, action: #selector(tutorialTapAction), for: .touchUpInside)
        return fView
    }()

    lazy var refreshHeader = { () -> MJRefreshHeader in
        let header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(fetchData))!
        return header
    }()

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }

    var listData: [Delegate] = []
    var generateQrCode: QrcodeData<[TransactionQrcode]>?
    var currentDelegate: Delegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(UIApplication.shared.statusBarFrame.height)
            make.bottom.leading.trailing.equalToSuperview()
        }

        tableView.tableHeaderView = headerView
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        headerView.frame.size = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        tableView.tableHeaderView = headerView
        headerView.delegateRecordHandler = { [weak self] in
            self?.gotoDelegateRecordVC()
        }
        headerView.rewardRecordHandler = { [weak self] in
            self?.gotoRewardDetailVC()
        }

        tableView.tableFooterView = footerView

        let attributed = NSAttributedString(string: "empty_string_my_delegates_left")
        let actionAttributed = NSAttributedString(string: "empty_string_my_delegates_right", attributes: [NSAttributedString.Key.foregroundColor: common_blue_color])
        tableView.emptyDataSetView { [weak self] view in
            let holder = self?.emptyViewForTableview(forEmptyDataSet: (self?.tableView)!, [attributed, actionAttributed], "3.img-No trust") as? TableViewNoDataPlaceHolder
            holder?.textTapHandler = { [weak self] in
                self?.doShowValidatorListController()
            }
            view.customView(holder)
            view.isScrollAllowed(true)
            if let frame = self?.tableView.tableHeaderView?.frame {
                view.verticalOffset(frame.height/2.0)
            }
        }

        tableView.mj_header = refreshHeader

        NotificationCenter.default.addObserver(self, selector: #selector(shouldUpdateDelegateData), name: Notification.Name.ATON.updateWalletList, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveTransactionUpdate(_:)), name: Notification.Name.ATON.DidUpdateTransactionByHash, object: nil)

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        shouldUpdateDelegateData()
        GuidanceViewMgr.sharedInstance.checkGuidance(page: GuidancePage.MyDelegatesViewController, presentedVC: UIApplication.shared.keyWindow?.rootViewController ?? self)
    }

    @objc func shouldUpdateDelegateData() {
        if AssetVCSharedData.sharedData.walletList.count == 0 {
            listData.removeAll()
            updateDelagateHeader()
            tableView.reloadData()
            return
        }
        tableView.mj_header.beginRefreshing()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func faqTapAction() {
        let controller = WebCommonViewController()
        controller.navigationTitle = Localized("delegate_faq_title")
        controller.requestUrl = AppConfig.H5URL.FAQURL.faqurl
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }

    @objc func tutorialTapAction() {
        let controller = WebCommonViewController()
        controller.navigationTitle = Localized("delegate_tutorial_title")
        controller.requestUrl = AppConfig.H5URL.TutorialURL.tutorialurl
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }

    func updateDelagateHeader() {
        guard listData.count > 0 else {
            headerView.totalDelegateLabel.text = "0.00"
            headerView.totalRewardLabel.text = "0.00"
            headerView.unclaimedRewardLabel.text = "0.00"
            return
        }
        let total = listData.reduce(BigUInt(0)) { (result, delegate) -> BigUInt in
            return result + BigUInt(delegate.delegated ?? "0")!
        }
        let totalReward = listData.reduce(BigUInt(0)) { (result, delegate) -> BigUInt in
            return result + BigUInt(delegate.cumulativeReward ?? "0")!
        }
        let totalUnClaim = listData.reduce(BigUInt(0)) { (result, delegate) -> BigUInt in
            return result + BigUInt(delegate.withdrawReward ?? "0")!
        }

        headerView.totalRewardLabel.text = (totalReward.description.vonToLATString ?? "0").ATPSuffix()
        headerView.unclaimedRewardLabel.text = (totalUnClaim.description.vonToLATString ?? "0.00").ATPSuffix()

        let contents = (total.description.vonToLATWith12DecimalString ?? "0.00").split(separator: ".")
        guard contents.count == 2 else {
            headerView.totalDelegateLabel.text = (total.description.vonToLATString ?? "0").ATPSuffix()
            return
        }

        let firstValue = contents[0]
        let secondValue = contents[1]
        let secondAttributed = NSAttributedString(string: "." + String(secondValue), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .medium)])
        let mutableAttributed = NSMutableAttributedString(string: String(firstValue))
        mutableAttributed.append(secondAttributed)
        headerView.totalDelegateLabel.attributedText = mutableAttributed
    }

    private func gotoDelegateRecordVC() {
        let viewController = DelegateRecordMainViewController()
        viewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func gotoDelegateDetailVC(_ delegate: Delegate) {
        let controller = DelegateDetailViewController()
        controller.delegate = delegate
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }

    private func gotoRewardDetailVC() {
        let viewController = RewardRecordViewController()
        viewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func doShowValidatorListController() {
        guard let tabController = self.parent as? StakingMainViewController else { return }
        tabController.moveToValidatorListController()
    }

    func claimRewardAction(_ indexPath: IndexPath) {
        let delegate = listData[indexPath.row]
        guard delegate.status == .unclaim else {
            return
        }

        let transactions = TransferPersistence.getPendingTransaction(address: delegate.walletAddress)
        if transactions.count >= 0 && (Date().millisecondsSince1970 - (transactions.first?.createTime ?? 0) < 300 * 1000) {
            showErrorMessage(text: Localized("transaction_warning_wait_for_previous"))
            return
        }

        showLoadingHUD()
        TransactionService.service.getContractGas(from: delegate.walletAddress, txType: TxType.claimReward) { [weak self] (result, remoteGas) in
            self?.hideLoadingHUD()
            switch result {
            case .success:
                guard let gas = remoteGas else {
                    self?.showErrorMessage(text: "get gas api error", delay: 2.0)
                    return
                }
                self?.showClaimConfirmView(delegate: delegate, gas: gas)
            case .fail(_, let errMsg):
                self?.showErrorMessage(text: errMsg ?? "get gas api error", delay: 2.0)
            }
        }
    }

    func showClaimConfirmView(delegate: Delegate, gas: RemoteGas) {
        let controller = PopUpViewController()
        let confirmView = RewardClaimComfirmView()
        confirmView.valueLabel.attributedText = delegate.withdrawRewardValue
        confirmView.walletLabel.text = delegate.walletName
        confirmView.balanceLabel.text = delegate.freeBalanceValue
        confirmView.feeLabel.text = (gas.gasUsed.vonToLATString ?? "0.00").ATPSuffix()
        confirmView.comfirmBtn.style = (delegate.freeBalanceBInt >= gas.gasUsedBInt) ? .blue : .disable
        controller.setUpConfirmView(view: confirmView, width: PopUpContentWidth)
        controller.onCompletion = { [weak self] in
            self?.inputPasswordForClaimTransaction(delegate: delegate, gas: gas)
        }
        controller.show(inViewController: self)
    }

    func inputPasswordForClaimTransaction(delegate: Delegate, gas: RemoteGas) {
        currentDelegate = delegate
        guard let wallet = (AssetVCSharedData.sharedData.walletList as? [Wallet])?.first(where: { $0.address.lowercased() == delegate.walletAddress.lowercased() }) else {
            showMessage(text: "notfound wallet", delay: 2.0)
            return
        }

        guard let amount = delegate.withdrawReward else {
            showErrorMessage(text: "withdraw reward must be > 0")
            return
        }

        if wallet.type == .observed {
            let funcType = FuncType.withdrawDelegateReward
            web3.platon.platonGetNonce(sender: wallet.address) { [weak self] (result, blockNonce) in
                guard let self = self else { return }
                switch result {
                case .success:
                    guard let nonce = blockNonce else { return }
                    let nonceString = nonce.quantity.description

                    let transactionData = TransactionQrcode(amount: amount, chainId: web3.properties.chainId, from: wallet.address, to: PlatonConfig.ContractAddress.rewardContractAddress, gasLimit: gas.gasLimit, gasPrice: gas.gasPrice, nonce: nonceString, typ: nil, nodeId: nil, nodeName: nil, stakingBlockNum: nil, functionType: funcType.typeValue)

                    let qrcodeData = QrcodeData(qrCodeType: 0, qrCodeData: [transactionData], chainId: web3.chainId, functionType: 5000, from: wallet.address, nodeName: nil, rn: amount, timestamp: Int(Date().timeIntervalSince1970 * 1000))
                    guard
                        let data = try? JSONEncoder().encode(qrcodeData),
                        let content = String(data: data, encoding: .utf8) else { return }
                    self.generateQrCode = qrcodeData
                    DispatchQueue.main.async {
                        self.showOfflineConfirmView(content: content)
                    }
                case .fail(_, let message):
                    self.showErrorMessage(text: message ?? "get nonce error")
                }
            }
            return
        }

        showPasswordInputPswAlert(for: wallet) { [weak self] (privateKey, _, error) in
            guard let self = self else { return }
            guard let pri = privateKey else {
                if let errorMsg = error?.localizedDescription {
                    self.showErrorMessage(text: errorMsg, delay: 2.0)
                }
                return
            }
            self.sendClaimTransaction(delegate: delegate, gas: gas, privateKey: pri)
        }
    }

    func sendClaimTransaction(delegate: Delegate, gas: RemoteGas, privateKey: String) {
        showLoadingHUD()
        StakingService.sharedInstance.rewardClaim(from: delegate.walletAddress, privateKey: privateKey, gas: gas) { [weak self] (result, transaction) in
            self?.hideLoadingHUD()
            switch result {
            case .success:
                guard let newTx = transaction else {
                    self?.showMessage(text: "not repsonse transaction object", delay: 2.0)
                    return
                }
                newTx.totalReward = delegate.withdrawReward
                TransferPersistence.add(tx: newTx)
                self?.tableView.mj_header.beginRefreshing()
            case .fail(_, let errMsg):
                self?.showMessage(text: errMsg ?? "network error", delay: 2.0)
            }
        }
    }

    func showOfflineConfirmView(content: String) {
        let qrcodeView = OfflineSignatureQRCodeView()
        let qrcodeWidth = PopUpContentWidth - 32
        let qrcodeImage = UIImage.geneQRCodeImageFor(content, size: qrcodeWidth, isGzip: true)
        qrcodeView.imageView.image = qrcodeImage

        let type = ConfirmViewType.qrcodeGenerate(contentView: qrcodeView)
        let offlineConfirmView = OfflineSignatureConfirmView(confirmType: type)
        offlineConfirmView.titleLabel.localizedText = "confirm_generate_qrcode_for_transaction"
        offlineConfirmView.descriptionLabel.localizedText = "confirm_generate_qrcode_for_transaction_tip"
        offlineConfirmView.submitBtn.localizedNormalTitle = "confirm_button_next"

        let controller = PopUpViewController()
        controller.onCompletion = { [weak self] in
            self?.showQrcodeScan()
        }
        controller.setUpConfirmView(view: offlineConfirmView, width: PopUpContentWidth)
        controller.show(inViewController: self)
    }

    func showQrcodeScan() {
        var qrcodeData: QrcodeData<[String]>?
        let scanView = OfflineSignatureScanView()
        scanView.scanCompletion = { [weak self] in
            self?.doShowScanController(completion: { (data) in
                guard
                    let qrcode = data,
                    let signedDatas = qrcode.qrCodeData, qrcode.chainId == web3.chainId else { return }
                DispatchQueue.main.async {
                    scanView.textView.text = signedDatas.joined(separator: ";")
                }
                qrcodeData = qrcode
            })
        }
        let type = ConfirmViewType.qrcodeScan(contentView: scanView)
        let offlineConfirmView = OfflineSignatureConfirmView(confirmType: type)
        offlineConfirmView.titleLabel.localizedText = "confirm_scan_qrcode_for_read"
        offlineConfirmView.descriptionLabel.localizedText = "confirm_scan_qrcode_for_read_tip"
        offlineConfirmView.submitBtn.localizedNormalTitle = "confirm_button_send"

        let controller = PopUpViewController()
        controller.onCompletion = {
            guard let qrcode = qrcodeData else { return }
            self.sendSignatureTransaction(qrcode: qrcode)
        }
        controller.setUpConfirmView(view: offlineConfirmView, width: PopUpContentWidth)
        controller.show(inViewController: self)
    }

    func doShowScanController(completion: ((QrcodeData<[String]>?) -> Void)?) {
        let controller = QRScannerViewController()
        controller.hidesBottomBarWhenPushed = true
        controller.scanCompletion = { result in
            let qrcodeType = QRCodeDecoder().decode(result)
            switch qrcodeType {
            case .signedTransaction(let data):
                completion?(data)
            default:
                AssetViewControllerV060.getInstance()?.showMessage(text: Localized("QRScan_failed_tips"))
                completion?(nil)
            }
        }

        (UIApplication.shared.keyWindow?.rootViewController as? BaseNavigationController)?.pushViewController(controller, animated: true)
    }

    func sendSignatureTransaction(qrcode: QrcodeData<[String]>) {

        guard
            let signatureArr = qrcode.qrCodeData,
            let type = qrcode.functionType,
            let from = qrcode.from,
            let amount = currentDelegate?.withdrawReward
        else { return }
        for (index, signature) in signatureArr.enumerated() {
            let bytes = signature.hexToBytes()
            let rlpItem = try? RLPDecoder().decode(bytes)

            if
                let signedTransactionRLP = rlpItem,
                let signedTransaction = try? EthereumSignedTransaction(rlp: signedTransactionRLP) {
                self.showLoadingHUD()
                web3.platon.sendRawTransaction(transaction: signedTransaction) { (response) in
                    self.hideLoadingHUD()
                    guard
                        let to = signedTransaction.to?.rawAddress.toHexString().add0x() else { return }
                    let gasPrice = signedTransaction.gasPrice.quantity
                    let gasLimit = signedTransaction.gasLimit.quantity
                    let gasUsed = gasPrice.multiplied(by: gasLimit).description

                    let tx = Transaction()
                    tx.from = from
                    tx.to = to
                    tx.gasUsed = gasUsed
                    tx.createTime = Int(Date().timeIntervalSince1970 * 1000)
                    tx.txReceiptStatus = -1
                    tx.totalReward = amount
                    tx.transactionType = Int(type)
                    tx.toType = .contract
                    tx.txType = .claimReward
                    tx.direction = .Receive
                    tx.txhash = signedTransaction.hash?.add0x()

                    switch response.status {
                    case .success:
                        TransferPersistence.add(tx: tx)
                        if index == signatureArr.count - 1 {
                            DispatchQueue.main.async {
                                self.tableView.mj_header.beginRefreshing()
                            }
                        }
                    case .failure(let err):
                        switch err {
                        case .reponseTimeout:
                            TransferPersistence.add(tx: tx)
                            if index == signatureArr.count - 1 {
                                DispatchQueue.main.async {
                                    self.tableView.mj_header.beginRefreshing()
                                }
                            }
                        case .requestTimeout:
                            self.showErrorMessage(text: Localized("RPC_Response_connectionTimeout"), delay: 2.0)
                        default:
                            self.showErrorMessage(text: err.message, delay: 2.0)
                        }

                    }
                }
            }
        }
    }

    @objc func didReceiveTransactionUpdate(_ notification: Notification) {
        // 由于余额发生变化时会更新交易记录，因此，这里并需要再次更新

        guard let txStatus = notification.object as? TransactionsStatusByHash, let status = txStatus.txReceiptStatus, status != .pending else { return }
        tableView.mj_header.beginRefreshing()
    }
}

extension MyDelegatesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyDelegateViewCell") as! MyDelegateViewCell
        let delegate = listData[indexPath.row]
        cell.delegate = delegate
        cell.cellDidHandle = { [weak self] tapCell in
            self?.gotoDelegateDetailVC(delegate)
        }
        cell.claimDidHandle = { [weak self] _ in
            self?.claimRewardAction(indexPath)
        }
        return cell
    }
}

extension MyDelegatesViewController {
    @objc func fetchData() {
        let addresses = (AssetVCSharedData.sharedData.walletList as! [Wallet]).map { return $0.address }
        guard addresses.count > 0 else {
            self.tableView.mj_header.endRefreshing()
            return
        }

        StakingService.sharedInstance.getMyDelegate(adddresses: addresses) { [weak self] (result, data) in
            self?.tableView.mj_header.endRefreshing()

            switch result {
            case .success:
                self?.listData.removeAll()
                if let newData = data as? [Delegate] {
                    self?.listData.append(contentsOf: newData)
                    self?.tableView.reloadData()
                    self?.updateDelagateHeader()
                }
                self?.tableView.reloadData()
            case .fail:
                break
            }
        }
    }
}

class ATableView: UITableView {
    override func reloadData() {
        super.reloadData()
        adjustTableFooterView()
    }

    func adjustTableFooterView() {
        if let footerView = tableFooterView {

            if frame.height > 0.0 {
                layoutIfNeeded()

                if contentSize.height < frame.height {
                    var tframe = footerView.frame
                    let height = max(80, frame.height - (contentSize.height - tframe.height))
                    if height != tframe.size.height {
                        tframe.size.height = height
                        footerView.frame = tframe
                        tableFooterView = footerView
                        reloadData()
                    }
                } else if contentSize.height > frame.height {
                    var tframe = footerView.frame
                    if tframe.size.height != 80 {
                        tframe.size.height = 80
                        footerView.frame = tframe
                        tableFooterView = footerView
                        reloadData()
                    }
                }
            }
        }
    }
}
