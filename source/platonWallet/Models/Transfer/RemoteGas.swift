//
//  RemoteGas.swift
//  platonWallet
//
//  Created by Admin on 10/1/2020.
//  Copyright © 2020 ju. All rights reserved.
//

import Foundation
import BigInt

struct RemoteGas: Decodable {
    var gasLimit: String?
    var gasPrice: String?

    var gasLimitBInt: BigUInt {
        return BigUInt(1000000)
//        return BigUInt(gasLimit ?? "0") ?? BigUInt.zero
    }

    var gasPriceBInt: BigUInt {
        return BigUInt(gasPrice ?? "0") ?? BigUInt.zero
    }

    var gasUsedBInt: BigUInt {
        return gasLimitBInt.multiplied(by: gasPriceBInt)
    }

    var gasUsed: String {
        return gasUsedBInt.description
    }
}
