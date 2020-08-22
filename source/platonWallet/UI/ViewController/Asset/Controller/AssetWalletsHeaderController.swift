//
//  AssetWalletsHeaderController.swift
//  platonWallet
//
//  Created by Admin on 26/3/2020.
//  Copyright © 2020 ju. All rights reserved.
//

import Foundation

class AssetWalletsHeaderController {
    let viewModel: AssetHeaderViewModel

    var onwalletsSelect: (() -> Void)?
    var onImportPressed: (() -> Void)?
    var onCreatePressed: (() -> Void)?
    var onExchangeWalletToDisplay: ((_ walletAddress: String) -> Void)?

    init(viewModel: AssetHeaderViewModel = AssetHeaderViewModel()) {
        self.viewModel = viewModel

        initialViewModel()
        initialObserver()
    }

    func initialViewModel() {
        viewModel.assetIsHide.value = AssetCoreService.shared.assetVisible

        viewModel.visibleBtnPressed = { [weak self] in
            AssetCoreService.shared.assetVisible = !AssetCoreService.shared.assetVisible
            self?.viewModel.assetIsHide.value = AssetCoreService.shared.assetVisible

            NotificationCenter.default.post(name: Notification.Name.ATON.DidAssetBalanceVisiableChange, object: nil)
        }

        updateWalletList()
    }

    func initialObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateWalletListFromNotification), name: Notification.Name.ATON.updateWalletList, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func cellIdentifier(for viewModel: RowViewModel) -> String {
        switch viewModel {
        case is AssetWalletViewModel:
            return WalletCollectionViewCell.cellIdentifier()
        default:
            return CreateImportCollectionViewCell.cellIdentifier()
        }
    }
    
    @objc func updateWalletListFromNotification() {
        updateWalletList()
    }

    @objc func updateWalletList() {
        var viewModels: [RowViewModel] = []
        WalletService.sharedInstance.refreshDB()
        let rootWallets = AssetVCSharedData.sharedData.depthZeroWallets
        for (_, v) in rootWallets.enumerated() {
            let walletViewModel: AssetWalletViewModel = AssetWalletViewModel(wallet: v)
            viewModels.append(walletViewModel)
            walletViewModel.cellPressed = { [weak self] in
                AssetVCSharedData.sharedData.currentRootWalletAddress = walletViewModel.wallet.address
                self?.onwalletsSelect?()
            }
            walletViewModel.onExchangeWalletToDisplay = {[weak self] in
                guard let self = self else { return }
                if walletViewModel.wallet.subWallets.count > 0 {
                    guard let callback = self.onExchangeWalletToDisplay else { return }
                    callback(walletViewModel.wallet.address)
                }
            }
        }
        
        let createWalletViewModel = AssetGenerateViewModel(title: "AddWalletMenuVC_createIndividualWallet_title", icon: UIImage(named: "cellItemCreate"))
        createWalletViewModel.cellPressed = { [weak self] in
            self?.onCreatePressed?()
        }

        let importWalletViewModel = AssetGenerateViewModel(title: "AddWalletMenuVC_importIndividualWallet_title", icon: UIImage(named: "cellItemImport"))
        importWalletViewModel.cellPressed = { [weak self] in
            self?.onImportPressed?()
        }

        viewModels.append(createWalletViewModel)
        viewModels.append(importWalletViewModel)

        viewModel.walletViewModels.value = viewModels
    }

    func fetchLatestData() {

    }
}
