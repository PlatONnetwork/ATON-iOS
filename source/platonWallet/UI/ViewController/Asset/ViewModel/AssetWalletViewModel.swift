//
//  AssetWalletViewModel.swift
//  platonWallet
//
//  Created by Admin on 24/3/2020.
//  Copyright © 2020 ju. All rights reserved.
//

import Foundation

class AssetWalletViewModel: RowViewModel, ViewModelPressible {
    let wallet: Wallet
    var cellPressed: (() -> Void)?
    var cellExchangeButtonPressed: (() -> Void)?

    /// 子钱包数组
    var subWallets: [Wallet]

    init(wallet: Wallet, subWallets: [Wallet]) {
        self.wallet = wallet
        self.subWallets = subWallets
    }

//    init(wallet: Wallet) {
//        self.wallet = wallet
//    }

    // 是否是选中的钱包
    var isWalletSelected: Bool {
        /// 加入HD钱包分层后把母钱包的子钱包选中也要算母钱包选中
        if let selectedWallet = AssetVCSharedData.sharedData.selectedWallet as? Wallet {
            if selectedWallet.address.lowercased() == wallet.address.lowercased() {
                return true
            }
            let subWalletsAddresses = self.subWallets.map { (wallet) -> String in return wallet.address }
            if subWalletsAddresses.contains(selectedWallet.address) {
                return true
            }
        }
        return false
        // 如下是加入HD钱包业务以前的逻辑
//        guard
//            let selectedWallet = AssetVCSharedData.sharedData.selectedWallet as? Wallet,
//            selectedWallet.address.lowercased() == wallet.address.lowercased() else {
//                return false
//        }
//        return true
    }
}
