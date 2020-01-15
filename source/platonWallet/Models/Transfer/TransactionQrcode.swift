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
    var chainId: String?
    var functionType: UInt16?
    var from: String?
}

//extension QrcodeData {
//    func rlp() -> RLPItem {
//
//        let qrCodeTypeRLP = RLPItem(integerLiteral: UInt(qrCodeType ?? 0))
//        var qrcodeDataRLP: RLPItem?
//        if let txQrcode = qrCodeData as? [TransactionQrcode] {
//            let resultRLPs = txQrcode.map { $0.rlp() }
//            let rlpedItems = resultRLPs.map { (rlpItem) -> RLPItem in
//                let rawRlp = try? RLPEncoder().encode(rlpItem)
//                return RLPItem.bytes(rawRlp ?? Bytes())
//            }
//
//            qrcodeDataRLP = RLPItem.array(rlpedItems)
//        } else if let txQrcode = qrCodeData as? [String] {
//            let result = txQrcode.map { $0.rlp() }
//            qrcodeDataRLP = RLPItem.array(result)
//        } else {
//            qrcodeDataRLP = RLPItem(bytes: Bytes())
//        }
//        let timestampRLP = RLPItem(integerLiteral: UInt(timestamp ?? 0))
//        let chainIdRLP = RLPItem(stringLiteral: chainId ?? "")
//        let functionTypeRLP = RLPItem(bytes: functionType?.makeBytes() ?? Bytes())
//        let fromRLP = RLPItem(stringLiteral: from ?? "")
//
//        return RLPItem.array([qrCodeTypeRLP, qrcodeDataRLP!, timestampRLP, chainIdRLP, functionTypeRLP, fromRLP])
//    }
//}

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

extension RLPItem {
//    func newQrcode() -> QrcodeData<[TransactionQrcode]>? {
//        let rlp = self
//        guard let array = rlp.array, array.count == 6, let txArray = array[1].array, let bt = txArray.first?.bytes, let dcRLP = try? RLPDecoder().decode(bt), dcRLP.newTx() != nil else {
//            return nil
//        }
//
//        let qrCodeType = UInt(bytes: array[0].bytes ?? Bytes())
//
//        var qrCodeDatas: [TransactionQrcode]?
//
//        if let txArray = array[1].array {
//            let bytesArr = txArray.map { $0.bytes! }
//            let result = bytesArr.map { (bytes) -> TransactionQrcode in
//                let response = (try? RLPDecoder().decode(bytes))?.newTx()
//                return response!
//            }
//            qrCodeDatas = result
//        }
//
//        let timestamp = UInt(bytes: array[2].bytes ?? Bytes())
//        let chainId = array[3].bytes?.makeString()
//        let functionType = UInt16(bytes: array[4].bytes ?? Bytes())
//        let from = array[5].bytes?.makeString()
//
//        return QrcodeData(qrCodeType: Int(qrCodeType), qrCodeData: qrCodeDatas, timestamp: Int(timestamp), chainId: chainId, functionType: functionType, from: from)
//    }

//    func newSigned() -> QrcodeData<[String]>? {
//        let rlp = self
//        guard let array = rlp.array, array.count == 6, let txArray = array[1].array, txArray.first?.string != nil else {
//            return nil
//        }
//
//        let qrCodeType = UInt(bytes: array[0].bytes ?? Bytes())
//
//        var qrCodeDatas: [String]?
//
//        if let txArray = array[1].array {
//            let result = txArray.map { $0.string! }
//            qrCodeDatas = result
//        }
//
//        let timestamp = UInt(bytes: array[2].bytes ?? Bytes())
//        let chainId = array[3].bytes?.makeString()
//        let functionType = UInt16(bytes: array[4].bytes ?? Bytes())
//        let from = array[5].bytes?.makeString()
//
//        return QrcodeData(qrCodeType: Int(qrCodeType), qrCodeData: qrCodeDatas, timestamp: Int(timestamp), chainId: chainId, functionType: functionType, from: from)
//    }

    func newTx() -> TransactionQrcode? {
        let rlp = self
        guard let array = rlp.array, array.count == 12 else {
            return nil
        }

        let amount = array[0].bytes?.makeString()
        let chainId = array[1].bytes?.makeString()
        let from = array[2].bytes?.makeString()
        let to = array[3].bytes?.makeString()
        let gasLimit = array[4].bytes?.makeString()
        let gasPrice = array[5].bytes?.makeString()
        let nonce = array[6].bytes?.makeString()
        let typ = UInt16(bytes: array[7].bytes ?? Bytes())
        let nodeId = array[8].bytes?.makeString()
        let nodeName = array[9].bytes?.makeString()
        let stakingBlockNum = array[10].bytes?.makeString()
        let functionType = UInt16(bytes: array[11].bytes ?? Bytes())

        let tx = TransactionQrcode(amount: amount, chainId: chainId, from: from, to: to, gasLimit: gasLimit, gasPrice: gasPrice, nonce: nonce, typ: typ, nodeId: nodeId, nodeName: nodeName, stakingBlockNum: stakingBlockNum, functionType: functionType)
        return tx
    }
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

        return RLPItem.array([amountRLP, chainIdRLP, fromRLP, toRLP, gasLimitRLP, gasPriceRLP, nonceRLP, typRLP, nodeIdRLP, nodeNameRLP, stakingBlockNumRLP, functionTypeRLP])
    }
}



extension TransactionQrcode {
    var typeString: String {
        switch functionType! {
        case 0:
            return Localized("transferVC_confirm_ATP_send")
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
