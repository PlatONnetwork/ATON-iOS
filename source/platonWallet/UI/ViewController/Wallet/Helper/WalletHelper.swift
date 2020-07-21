//
//  WalletHelper.swift
//  platonWallet
//
//  Created by juzix on 2020/7/18.
//  Copyright © 2020 ju. All rights reserved.
//

import UIKit

class WalletHelper {
    
    /// 从钱包数组中筛选普通钱包
    static func fetchNormalWallets(from wallets: [Wallet]) -> [Wallet] {
        return wallets.filter { (w) -> Bool in
            w.isHD == false
        }
    }
    
    /// 从钱包中筛选HD钱包
    static func fetchHDWallets(from wallets: [Wallet]) -> [Wallet] {
        return wallets.filter { (w) -> Bool in
            w.isHD == true
        }
    }

    /// 从钱包中筛选HD母钱包
    static func fetchHDParentWallets(from wallets: [Wallet]) -> [Wallet] {
        return wallets.filter { (w) -> Bool in
            w.isHD == true && w.parentId == nil
        }
    }
    
    /// 从钱包中筛选HD子钱包
    static func fetchHDSubWallets(from wallets: [Wallet]) -> [Wallet] {
        return wallets.filter { (w) -> Bool in
            w.isHD == true && (w.parentId != nil && w.parentId!.count > 0)
        }
    }

    /// 从钱包数组中筛选深度为0的钱包
    static func fetchDepthIsZeroWallets(from wallets: [Wallet]) -> [Wallet] {
        return wallets.filter { (w) -> Bool in
            w.depth == 0
        }
    }
}
