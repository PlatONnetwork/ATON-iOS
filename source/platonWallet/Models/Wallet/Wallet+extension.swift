//
//  Wallet+extension.swift
//  platonWallet
//
//  Created by Ned on 14/3/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import UIKit
import BigInt

import Localize_Swift

enum BalanceStatus {
    case NotSufficient,Sufficient,unknowStatus
}

extension Wallet{
    
    func lockedBalanceAttrForDisplayAsset() -> NSAttributedString? {
        guard let lockedBalanceString = lockedBalanceDescription() else { return nil }
        
        let attachment = NSTextAttachment()
        attachment.bounds = CGRect(x: 0, y: 0, width: 10, height: 10)
        attachment.image = UIImage(named: "1.icon_An error")
        
        let iconAttr = NSMutableAttributedString()
        iconAttr.append(NSAttributedString(attachment: attachment))
        
        let lockedBalanceAttr = NSMutableAttributedString(string: "(")
        lockedBalanceAttr.append(iconAttr)
        
        lockedBalanceAttr.append(NSAttributedString(string: " " + Localized("wallet_balance_restricted") + lockedBalanceString))
        lockedBalanceAttr.append(NSAttributedString(string: ")"))
        return lockedBalanceAttr
    }
    
    func lockedBalanceDescription() -> String? {
        guard
            let balance = AssetService.sharedInstace.balances.first(where: { $0.addr.lowercased() == self.key?.address.lowercased() }),
            let lockValue = BigUInt(balance.lock ?? "0"), lockValue > BigUInt.zero,
            let balanceStr = balance.lock?.vonToLATString else { return nil }
        
        WalletService.sharedInstance.updateWalletLockedBalance(self, value: balance.lock ?? "0")
        return balanceStr.ATPSuffix()
    }
    
    func balanceDescription() -> String{
        guard
            let balance = AssetService.sharedInstace.balances.first(where: { $0.addr.lowercased() == self.key?.address.lowercased() }),
            let balanceStr = balance.free?.vonToLATString else { return "0.00".ATPSuffix() }
        
        WalletService.sharedInstance.updateWalletBalance(self, balance: balance.free ?? "0")
        return balanceStr.ATPSuffix()
    }
    
    func image() -> UIImage{
        return UIImage(named: (self.key?.address.walletAddressLastCharacterAvatar())!)!
    }
    
    func WalletBalanceStatus() -> BalanceStatus{
        let balance = AssetService.sharedInstace.assets[(self.key?.address)!]
        if let b = balance{
            if String((b!.balance)!) == "0"{
                return .NotSufficient
            }
            return .Sufficient
        }
        return BalanceStatus.unknowStatus
    }
}
