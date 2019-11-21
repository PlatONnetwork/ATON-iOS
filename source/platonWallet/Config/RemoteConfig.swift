//
//  RemoteConfig.swift
//  platonWallet
//
//  Created by Admin on 30/10/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import BigInt

struct RemoteConfig: Decodable {
    var minGasPrice: String? // default gasPrice
    var minDelegation: String? // min delegate amount
    var timeout: String? // transaction timeout value
}

extension RemoteConfig {
    var minGasPriceBInt: BigUInt? {
        guard let gasPrice = minGasPrice else {
            return nil
        }
        return BigUInt(gasPrice)
    }

    var minDelegationBInt: BigUInt? {
        guard let minDlg = minDelegation else {
            return nil
        }
        return BigUInt(minDlg)
    }

    var timeoutSecond: TimeInterval {
        guard
            let timeoutStr = timeout,
            let timeInterval = TimeInterval(timeoutStr) else { return TimeInterval(24 * 3600) }
        return timeInterval
    }
}
