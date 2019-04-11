//
//  Wallet+extension.swift
//  platonWallet
//
//  Created by Ned on 14/3/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import UIKit

enum BalanceStatus {
    case NotSufficient,Sufficient,unknowStatus
}

extension Wallet{
    func balanceDescription() -> String{
        
        let balance = AssetService.sharedInstace.assets[(self.key?.address)!]
        if let balance = balance{
            return (balance!.displayValueWithRound(round: 8)?.balanceFixToDisplay(maxRound: 8))!.ATPSuffix()
        }
        return "-".ATPSuffix()
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
    
    func getAssociatedJointWallets() -> [SWallet]{
        var jointWallet : [SWallet] = []
        
        for item in SWalletService.sharedInstance.wallets {
            if item.walletAddress.ishexStringEqual(other: self.key?.address){
                jointWallet.append(item)
            }
        }
        return jointWallet
    }
}

extension SWallet{
    func balanceDescription() -> String{
        
        let balance = AssetService.sharedInstace.assets[self.contractAddress]
        if let balance = balance{
            return (balance!.displayValueWithRound(round: 8)?.balanceFixToDisplay(maxRound: 8))!.ATPSuffix()
        }
        return "-".ATPSuffix()
    }
    
    func image() -> UIImage{
        return UIImage(named: (self.contractAddress.walletAddressLastCharacterAvatar()))!
    }
    
    func ownerWallet() -> Wallet?{
        let wallet = SWalletService.sharedInstance.getATPWalletByAddress(address: self.walletAddress)
        return wallet
    }
    
    func WalletBalanceStatus() -> BalanceStatus{
        let balance = AssetService.sharedInstace.assets[self.contractAddress]
        if let b = balance{
            if String((b!.balance)!) == "0"{
                return .NotSufficient
            }
            return .Sufficient
        }
        return BalanceStatus.unknowStatus
    }
}
