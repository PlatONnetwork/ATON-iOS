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
        NotificationCenter.default.addObserver(self, selector: #selector(updateWalletList), name: Notification.Name.ATON.updateWalletList, object: nil)
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

    @objc func updateWalletList() {
        var viewModels: [RowViewModel] = []
        if let wallets = AssetVCSharedData.sharedData.walletList as? [Wallet] {

            for wallet in wallets {
                let walletViewModel: AssetWalletViewModel = AssetWalletViewModel(wallet: wallet, subWallets: [])
                if wallet.isHD == false {
                    viewModels.append(walletViewModel)
                } else {
                    if wallet.parentId == nil {
                        let allSubWallets = WalletHelper.fetchHDSubWallets(from: wallets)
                        let subWallets = allSubWallets.filter { (sWallet) -> Bool in
                            sWallet.parentId == wallet.uuid
                        }
                        walletViewModel.subWallets = subWallets
                        viewModels.append(walletViewModel)
                    }
                }
                walletViewModel.cellPressed = { [weak self] in
                    if walletViewModel.subWallets.count > 0 {
                        AssetVCSharedData.sharedData.currentWalletAddress = walletViewModel.subWallets[walletViewModel.wallet.selectedIndex].address
                    } else {
                        AssetVCSharedData.sharedData.currentWalletAddress = wallet.address
                    }
                    
                    self?.onwalletsSelect?()
                }
                walletViewModel.cellExchangeButtonPressed = {[weak self] in
                    guard let self = self else { return }
                    
                }
            }
            
//            for wallet in wallets {
//                let walletViewModel = AssetWalletViewModel(wallet: wallet)
//                walletViewModel.cellPressed = { [weak self] in
//                    AssetVCSharedData.sharedData.currentWalletAddress = wallet.address
//                    self?.onwalletsSelect?()
//                }
//                viewModels.append(walletViewModel)
//            }
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
