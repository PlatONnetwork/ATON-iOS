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
    var qrCodeData: [QRData]?
}

struct SignatureQrcode: Codable {
    var signedData: String?
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
    var typ: UInt16?
    var nodeId: String?
    var sender: String?
    var stakingBlockNum: String?
    var type: UInt16?
}


extension TransactionQrcode {
    var typeString: String {
        switch type! {
        case 0:
            return Localized("TransactionStatus_sending_title")
        case 1004:
            return Localized("TransactionStatus_delegateCreate_title")
        case 1005:
            return Localized("TransactionStatus_delegateWithdraw_title")
        default:
            return Localized("TransactionStatus_sending_title")
        }
    }
}
