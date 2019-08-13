//
//  WalletBalance.swift
//  platonWallet
//
//  Created by matrixelement on 25/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import BigInt

class WalletBalance {
    
    var uuid : String?
    
    var address : String?
    
    var balance : BigUInt?
    
    var lockedBalance: BigUInt?
    
    var updateTime : CLong = 0
    
    var walletType : WalletType = .ClassicWallet
    
    var lockedDescriptionString: String? {
        get {
            guard let lockedBlc = lockedBalance else { return "0" }
            let ret = lockedBlc.divide(by: ETHToWeiMultiplier, round: 8)
            return ret
        }
    }
    
    func displayLockedValueWithRound(round: Int) -> String? {
        guard let lockedBlc = lockedBalance else { return "0" }
        let ret = lockedBlc.divide(by: ETHToWeiMultiplier, round: round)
        return ret
    }
    
    var descriptionString : String?{
        get{
            if balance != nil {
                var ret = balance?.divide(by: ETHToWeiMultiplier, round: 8)
                if ret == nil{
                    ret = "0"
                }
                return ret
            }
            return "0"
        }
    }
    
    func displayValueWithRound(round : Int) -> String? {
        if balance != nil {
            var ret = balance?.divide(by: ETHToWeiMultiplier, round: round)
            if ret == nil{
                ret = "0"
            }
            return ret
        }
        return "0"
    }
    
    
    
}
