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

    init(wallet: Wallet) {
        self.wallet = wallet
    }

    // 是否是选中的钱包
    var isWalletSelected: Bool {
        guard
            let selectedWallet = AssetVCSharedData.sharedData.selectedWallet as? Wallet,
            selectedWallet.address.lowercased() == wallet.address.lowercased() else {
                return false
        }
        return true
    }
}
