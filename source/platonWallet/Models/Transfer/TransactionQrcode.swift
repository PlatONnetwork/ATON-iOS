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
    var timestamp: Int?
}

struct SignatureQrcode: Codable {
    var signedData: [String]?
    var from: String?
    var type: UInt16?
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
    var nodeName: String?
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
    
    var fromName: String {
        guard let wallet = (AssetVCSharedData.sharedData.walletList as? [Wallet])?.first(where: { $0.address.lowercased() == from?.lowercased() }) else {
            return from ?? "--"
        }
        return wallet.name + "（\(wallet.address.addressForDisplayShort())）"
    }
    
    var toName: String {
        switch type! {
        case 0:
            guard let wallet = (AssetVCSharedData.sharedData.walletList as? [Wallet])?.first(where: { $0.address.lowercased() == to?.lowercased() }) else {
                return to ?? "--"
            }
            return wallet.name + "（\(wallet.address)）"
        default:
            guard let nid = nodeId else { return "--" }
            guard let nName = nodeName else { return nid }
            return nName + "\n（\(nid)）"
        }
    }
    
}
