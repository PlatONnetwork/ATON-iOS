//
//  TransactionQrcode.swift
//  platonWallet
//
//  Created by Admin on 24/9/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import Localize_Swift
import platonWeb3

struct QrcodeData<QRData: Codable>: Codable {
    var qrCodeType: Int?
    var qrCodeData: QRData?
    var timestamp: Int?
    var chainId: String?
    var functionType: UInt16?
    var from: String?
}

extension QrcodeData {
    func rlp() -> RLPItem {
        let qrCodeTypeRLP = RLPItem(integerLiteral: UInt(qrCodeType ?? 0))
        var qrcodeDataRLP: RLPItem?
        if let txQrcode = qrCodeData as? TransactionQrcode {
            qrcodeDataRLP = txQrcode.rlp()
        } else {
            qrcodeDataRLP = RLPItem(bytes: Bytes())
        }
        let timestampRLP = RLPItem(integerLiteral: UInt(timestamp ?? 0))
        let chainIdRLP = RLPItem(stringLiteral: chainId ?? "")
        let functionTypeRLP = RLPItem(bytes: functionType?.makeBytes() ?? Bytes())
        let fromRLP = RLPItem(stringLiteral: from ?? "")

        return RLPItem(arrayLiteral: [qrCodeTypeRLP, qrcodeDataRLP!, timestampRLP, chainIdRLP, functionTypeRLP, fromRLP])
    }
}

//extension QrcodeData<T> where T: TransactionQrcode {
//    func rlp() -> RLPItem {
//        let qrCodeTypeRLP = RLPItem(integerLiteral: qrCodeType ?? 0)
//        let qrCodeDataRLP = qrCodeData.rlp
//        let fromRLP = RLPItem(stringLiteral: from ?? "")
//        let toRLP = RLPItem(stringLiteral: to ?? "")
//        let gasLimitRLP = RLPItem(stringLiteral: gasLimit ?? "")
//        let gasPriceRLP = RLPItem(stringLiteral: gasPrice ?? "")
//        let nonceRLP = RLPItem(stringLiteral: nonce ?? "")
//        let typRLP = RLPItem(bytes: typ?.makeBytes() ?? Bytes())
//        let nodeIdRLP = RLPItem(stringLiteral: nodeId ?? "")
//        let nodeNameRLP = RLPItem(stringLiteral: nodeName ?? "")
//        let stakingBlockNumRLP = RLPItem(stringLiteral: stakingBlockNum ?? "")
//        let functionTypeRLP = RLPItem(bytes: functionType?.makeBytes() ?? Bytes())
//        return RLPItem(arrayLiteral: [amountRLP, chainIdRLP, fromRLP, toRLP, gasLimitRLP, gasPriceRLP, nonceRLP, typRLP, nodeIdRLP, nodeNameRLP, stakingBlockNumRLP, functionTypeRLP])
//    }
//}

//struct SignatureQrcode: Codable {
//    var signedData: [String]?
//    var from: String?
//    var type: UInt16?
//}

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
    var stakingBlockNum: String?
    var functionType: UInt16?
}

extension TransactionQrcode {
    func rlp() -> RLPItem {
        let amountRLP = RLPItem(stringLiteral: amount ?? "")
        let chainIdRLP = RLPItem(stringLiteral: chainId ?? "")
        let fromRLP = RLPItem(stringLiteral: from ?? "")
        let toRLP = RLPItem(stringLiteral: to ?? "")
        let gasLimitRLP = RLPItem(stringLiteral: gasLimit ?? "")
        let gasPriceRLP = RLPItem(stringLiteral: gasPrice ?? "")
        let nonceRLP = RLPItem(stringLiteral: nonce ?? "")
        let typRLP = RLPItem(bytes: typ?.makeBytes() ?? Bytes())
        let nodeIdRLP = RLPItem(stringLiteral: nodeId ?? "")
        let nodeNameRLP = RLPItem(stringLiteral: nodeName ?? "")
        let stakingBlockNumRLP = RLPItem(stringLiteral: stakingBlockNum ?? "")
        let functionTypeRLP = RLPItem(bytes: functionType?.makeBytes() ?? Bytes())
        return RLPItem(arrayLiteral: [amountRLP, chainIdRLP, fromRLP, toRLP, gasLimitRLP, gasPriceRLP, nonceRLP, typRLP, nodeIdRLP, nodeNameRLP, stakingBlockNumRLP, functionTypeRLP])
    }
}

extension TransactionQrcode {
    var typeString: String {
        switch functionType! {
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
        switch functionType! {
        case 0:
            guard let wallet = (AssetVCSharedData.sharedData.walletList as? [Wallet])?.first(where: { $0.address.lowercased() == to?.lowercased() }) else {
                return to?.addressForDisplayShort() ?? "--"
            }
            return wallet.name + "（\(wallet.address.addressForDisplayShort())）"
        default:
            guard let nid = nodeId else { return "--" }
            guard let nName = nodeName else { return nid }
            return nName + "\n（\(nid.nodeIdForDisplayShort())）"
        }
    }

}
