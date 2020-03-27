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

    init(viewModel: AssetHeaderViewModel = AssetHeaderViewModel()) {
        self.viewModel = viewModel

        initialViewModel()
        initialObserver()
    }

    func initialViewModel() {
        guard let isHide = UserDefaults.standard.object(forKey: AssetHidingStatus) as? Bool else {
            UserDefaults.standard.set(true, forKey: AssetHidingStatus)
            UserDefaults.standard.synchronize()
            viewModel.assetIsHide.value = true
            return
        }
        viewModel.assetIsHide.value = isHide

        viewModel.visibleBtnPressed = { [weak self] in
            guard let isHide = UserDefaults.standard.object(forKey: AssetHidingStatus) as? Bool else {
                UserDefaults.standard.set(true, forKey: AssetHidingStatus)
                UserDefaults.standard.synchronize()
                self?.viewModel.assetIsHide.value = true
                return
            }

            UserDefaults.standard.set(!isHide, forKey: AssetHidingStatus)
            UserDefaults.standard.synchronize()

            self?.viewModel.assetIsHide.value = !isHide

            NotificationCenter.default.post(name: Notification.Name.ATON.DidAssetBalanceVisiableChange, object: nil)
        }

        var viewModels: [RowViewModel] = []
        if let wallets = AssetVCSharedData.sharedData.walletList as? [Wallet] {
            for wallet in wallets {
                let walletViewModel = AssetWalletViewModel(wallet: wallet)
                walletViewModel.cellPressed = {

                }
                viewModels.append(walletViewModel)
            }
        }

        let createWalletViewModel = AssetGenerateViewModel(title: "AddWalletMenuVC_createIndividualWallet_title", icon: UIImage(named: "cellItemCreate"))
        createWalletViewModel.cellPressed = {

        }

        let importWalletViewModel = AssetGenerateViewModel(title: "AddWalletMenuVC_importIndividualWallet_title", icon: UIImage(named: "cellItemImport"))
        importWalletViewModel.cellPressed = {

        }

        viewModels.append(createWalletViewModel)
        viewModels.append(importWalletViewModel)

        viewModel.walletViewModels.value = viewModels
    }

    func initialObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateAllAsset), name: Notification.Name.ATON.DidUpdateAllAsset, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(shouldUpdateWalletList), name: Notification.Name.ATON.updateWalletList, object: nil)
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

    @objc func didUpdateAllAsset() {}

    @objc func shouldUpdateWalletList() {}
    

}
