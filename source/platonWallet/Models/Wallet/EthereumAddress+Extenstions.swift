//
// Created by liyf on 2020/6/23.
// Copyright (c) 2020 ju. All rights reserved.
//

import Foundation
import platonWeb3

extension EthereumAddress {
    public init(bech32: String, eip55: Bool) throws {
        try self.init(hex: WalletUtil.convert0x(bech32), eip55: eip55)
    }

    public func bech32(eip55: Bool) -> String {
        WalletUtil.convertBech32(self.hex(eip55: eip55))
    }
}