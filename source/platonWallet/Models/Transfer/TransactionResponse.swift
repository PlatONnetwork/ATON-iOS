//
//  TransactionResponse.swift
//  platonWallet
//
//  Created by Admin on 17/5/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation

class TransactionResponse: Decodable {
    var errMsg: String? = ""
    var code: Int? = 0
    var data: [Transaction] = []
}
