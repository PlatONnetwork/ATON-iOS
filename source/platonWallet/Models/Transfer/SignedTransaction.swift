//
//  SignedTransaction.swift
//  platonWallet
//
//  Created by Admin on 2/3/2020.
//  Copyright © 2020 ju. All rights reserved.
//

import Foundation

struct SignedTransaction: Codable {
    var signedData: String
    var remark: String?
}

extension SignedTransaction {
    var jsonString: String? {
        guard
            let signedData = try? JSONEncoder().encode(self),
            let signedString = String(data: signedData, encoding: .utf8)
            else { return nil }
        return signedString
    }
}
