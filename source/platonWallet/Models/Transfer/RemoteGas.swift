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
    var free: String?
    var lock: String?
    var minDelegation: String?
    var nonce: String?
    var blockGasLimit: String?

    var gasLimitBInt: BigUInt {
        return BigUInt(gasLimit ?? "0") ?? BigUInt.zero
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

    var nonceBInt: BigUInt {
        return BigUInt(nonce ?? "0") ?? BigUInt.zero
    }

    var minDelegationBInt: BigUInt {
        return BigUInt(minDelegation ?? "0") ?? BigUInt.zero
    }

    var freeBInt: BigUInt {
        return BigUInt(free ?? "0") ?? BigUInt.zero
    }
}
