//
//  WalletHelper.swift
//  platonWallet
//
//  Created by juzix on 2020/7/18.
//  Copyright © 2020 ju. All rights reserved.
//

import UIKit

struct WalletDisplaySectionInfo {
    var wallet: Wallet
    var subWallets: [Wallet] = []
}

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
    
    /// 获取钱包展示的分组信息
    static func fetchWalletDisplaySectionInfos() -> [WalletDisplaySectionInfo] {
        var sectionInfos: [WalletDisplaySectionInfo] = []
        let wallets = AssetVCSharedData.sharedData.walletList as! [Wallet]
        for wallet in wallets {
            var sectionInfo = WalletDisplaySectionInfo(wallet: wallet, subWallets: [])
            if wallet.isHD == false {
                sectionInfos.append(sectionInfo)
            } else {
                if wallet.parentId == nil {
                    let subWallets = self.fetchSubWallets(of: wallet)
                    sectionInfo.subWallets = subWallets
                    sectionInfos.append(sectionInfo)
                }
            }
        }
        return sectionInfos
    }
    
    /*
     {
         var sectionInfos: [SelectWalletDisplaySectionInfo] = []
         /// 普通组
         var normalSectionInfo = SelectWalletDisplaySectionInfo(wallet: nil, subWallets: [])
         let wallets = AssetVCSharedData.sharedData.walletList as! [Wallet]
         for wallet in wallets {
             let foundable = self.isFoundable(wallet: wallet, keyword: keyword)
             if wallet.isHD == false {
                 if cate == .all || cate == .normal {
                     if keyword.count > 0 {
                         // 如果存在关键字，需要筛选钱包模糊名称或地址精确名称
                         if foundable == true {
                             normalSectionInfo.subWallets.append(wallet)
                         }
                     } else {
                         normalSectionInfo.subWallets.append(wallet)
                     }
                 }
             } else {
                 if cate == .all || cate == .hd {
                     if wallet.parentId == nil {
                         /// 临时的HD分组
                         var tempHDSectionInfo = SelectWalletDisplaySectionInfo(wallet: wallet, subWallets: [])
                         let allSubWallets = WalletHelper.fetchHDSubWallets(from: wallets)
                         let subWallets = allSubWallets.filter { (sWallet) -> Bool in
                             sWallet.parentId == wallet.uuid
                         }
                         if keyword.count > 0 {
                             let fiteredSubWallets = subWallets.filter { (wallet) -> Bool in
                                 return self.isFoundable(wallet: wallet, keyword: keyword)
                             }
                             tempHDSectionInfo.subWallets = fiteredSubWallets
                         } else {
                             tempHDSectionInfo.subWallets = subWallets
                         }
                         if tempHDSectionInfo.subWallets.count > 0 {
                             sectionInfos.append(tempHDSectionInfo)
                         }
                     }
                 }
             }
         }
         if normalSectionInfo.subWallets.count > 0 {
             /// 普通组作为数据源的第一组数据
             sectionInfos.insert(normalSectionInfo, at: 0)
         }
         return sectionInfos
     }
     */
    
    /// 获取某个钱包在某个钱包组中的子钱包
    static func fetchSubWallets(of wallet: Wallet, from wallets:[Wallet]) -> [Wallet] {
        let allSubWallets = WalletHelper.fetchHDSubWallets(from: wallets)
        let subWallets = allSubWallets.filter { (sWallet) -> Bool in
            sWallet.parentId == wallet.uuid
        }
        return subWallets
    }
    
    /// 获取某钱包的在数据库中的子钱包
    static func fetchSubWallets(of wallet: Wallet) -> [Wallet] {
        let wallets = AssetVCSharedData.sharedData.walletList as! [Wallet]
        return self.fetchSubWallets(of: wallet, from: wallets)
    }
    
}
