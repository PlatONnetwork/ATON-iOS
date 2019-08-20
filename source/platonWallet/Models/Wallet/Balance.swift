//
//  Balance.swift
//  platonWallet
//
//  Created by Admin on 15/8/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation

struct Balance: Decodable {
    var account: String
    var free: String? //自由账户余额
    var lock: String? //锁仓账户余额
}
