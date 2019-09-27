//
//  TransactionQrcode.swift
//  platonWallet
//
//  Created by Admin on 24/9/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import Localize_Swift

struct QrcodeData<QRData: Codable>: Codable {
    var qrCodeType: Int?
    var qrCodeData: QRData?
}

struct SignatureQrcode: Codable {
    var signedDatas: [String]?
    var from: String?
    var type: Int?
}

struct TransactionQrcode: Codable {
    var amount: String?
    var chainId: String?
    var from: String?
    var to: String?
    var gasLimit: String?
    var gasPrice: String?
    var nonce: String?
    var platOnFunction: PlatOnFunction?
}

struct PlatOnFunction: Codable {
    var type: Int?
    var delegateCode: [DelegateQrcode]?
    var withdrawCode: [WithdrawQrcode]?
    
    enum CodingKeys: String, CodingKey {
        case type
        case parameters
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        withdrawCode = try container.decodeIfPresent([WithdrawQrcode].self, forKey: .parameters)
        delegateCode = try container.decodeIfPresent([DelegateQrcode].self, forKey: .parameters)
        type = try container.decodeIfPresent(Int.self, forKey: .type)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if delegateCode != nil {
            try container.encodeIfPresent(delegateCode, forKey: .parameters)
        } else if withdrawCode != nil {
            try container.encodeIfPresent(withdrawCode, forKey: .parameters)
        }
        try container.encodeIfPresent(type, forKey: .type)
    }
}

struct DelegateQrcode: Codable {
    var typ: UInt16?
    var nodeId: String?
    var amount: String?
    var sender: String?
}

struct WithdrawQrcode: Codable {
    var stakingBlockNum: String?
    var nodeId: String?
    var amount: String?
    var sender: String?
}


extension PlatOnFunction {
    var typeString: String {
        switch type! {
        case 0:
            return Localized("TransactionStatus_transfer_title")
        case 1004:
            return Localized("TransactionStatus_delegateCreate_title")
        case 1005:
            return Localized("TransactionStatus_delegateWithdraw_title")
        default:
            return Localized("TransactionStatus_unknown_title")
        }
    }
}
