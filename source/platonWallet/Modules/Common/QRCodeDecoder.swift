//
//  QRCodeDecoder.swift
//  platonWallet
//
//  Created by Admin on 26/9/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import platonWeb3
import Localize_Swift

enum QRCodeType {
    case transaction(data: QrcodeData<[TransactionQrcode]>)
    case signedTransaction(data: QrcodeData<[String]>)
    case address(data: String)
    case privatekey(data: String)
    case keystore(data: String)
    case error(data: String)
}

open class QRCodeDecoder {
    public init() {}

//    func decode(_ res: String) -> QRCodeType? {
//        if let rlp = try? RLPDecoder().decode(res.hexToBytes()), let result = rlp.newQrcode() {
//            return QRCodeType.transaction(data: result)
//        } else if let rlp = try? RLPDecoder().decode(res.hexToBytes()), let result = rlp.newSigned() {
//            return QRCodeType.signedTransaction(data: result)
//        } else {
//            if res.isValidAddress() {
//                return QRCodeType.address(data: res)
//            } else if res.isValidPrivateKey() {
//                return QRCodeType.privatekey(data: res)
//            } else if res.isValidKeystore() {
//                return QRCodeType.keystore(data: res)
//            }
//            return nil
//        }
//    }

    func decode(_ res: String) -> QRCodeType {
        if res.isValidAddress() {
            return QRCodeType.address(data: res)
        } else if res.isValidPrivateKey() {
            return QRCodeType.privatekey(data: res)
        } else if res.isValidKeystore() {
            return QRCodeType.keystore(data: res)
        } else {
            if let data = res.data(using: .utf8), let result = try? JSONDecoder().decode(QrcodeData<[TransactionQrcode]>.self, from: data) {
                return QRCodeType.transaction(data: result)
            } else if let data = res.data(using: .utf8), let result = try? JSONDecoder().decode(QrcodeData<[String]>.self, from: data) {
                return QRCodeType.signedTransaction(data: result)
            } else {
                return QRCodeType.error(data: Localized("QRScan_failed_tips"))
            }
        }
    }
}

