//
//  Balance.swift
//  platonWallet
//
//  Created by Admin on 15/8/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import BigInt

struct Balance: Decodable {
    var addr: String
    var free: String? //自由账户余额
    var lock: String? //锁仓账户余额
}

extension Balance {
    var lockedBalanceValue: String {
        guard
            let lockedString = lock,
            let lockedValue = BigUInt(lockedString) else { return "0" }
        let ret = lockedValue.divide(by: ETHToWeiMultiplier, round: 8)
        return ret
    }
}
