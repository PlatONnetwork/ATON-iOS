//
//  QRCodeRLPDecoder.swift
//  platonWallet
//
//  Created by Admin on 5/2/2020.
//  Copyright © 2020 ju. All rights reserved.
//

import Foundation
import platonWeb3

open class QRCodeRLPDecoder {
    public init() {}

    // return type nodeId amount
    func decode(_ rlpBytes: Bytes) throws -> (UInt16, String?, BigUInt?) {
        let rlpResult = try RLPDecoder().decode(rlpBytes)

        guard let rlpItems = rlpResult.array else {
            throw Error.rlpFormatInvalid
        }

        let subRlpItems = rlpItems.map { (item) -> RLPItem in
            let subItem = try? RLPDecoder().decode(item.bytes ?? Bytes())
            return subItem ?? RLPItem(bytes: Bytes())
        }

        guard let firstBytes = subRlpItems.first?.bytes else {
            throw Error.notRLPTransactionType
        }

        let type = UInt16(bytes: firstBytes)
        switch type {
        case 1004,
             1005:
            guard let nodeIdBytes = subRlpItems[2].bytes, let valueBInt = subRlpItems[3].bigUInt else {
                return (type, nil, nil)
            }
            let nodeId = nodeIdBytes.toHexString().add0x()
            return (type, nodeId, valueBInt)
        default:
            return (type, nil, nil)
        }
    }

    enum Error: Swift.Error {
        case rlpFormatInvalid
        case notRLPTransactionType
    }
}
