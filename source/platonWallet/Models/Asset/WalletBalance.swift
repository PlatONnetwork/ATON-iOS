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
    
    var updateTime : CLong = 0
    
    var walletType : WalletType = .ATPWallet
    
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
