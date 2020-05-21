//
// Created by liyf on 2020/5/14.
// Copyright (c) 2020 ju. All rights reserved.
//

import Foundation
import platonWeb3

extension Keystore {
    public struct Address {
        public var mainnet: String
        public var testnet: String

        public init(address: String, mainnetHrp: String, testnetHrp: String) {
            self.mainnet = try! AddrCoder.shared.encode(hrp: mainnetHrp, address: address)
            self.testnet = try! AddrCoder.shared.encode(hrp: testnetHrp, address: address)
        }

        public init(mainnet: String, testnet: String) {
            self.mainnet = mainnet
            self.testnet = testnet
        }
    }
}

extension Keystore.Address: Codable {
    enum CodingKeys: String, CodingKey {
        case mainnet
        case testnet
    }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        mainnet = try values.decode(String.self, forKey: .mainnet)
        testnet = try values.decode(String.self, forKey: .testnet)
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mainnet, forKey: .mainnet)
        try container.encode(testnet, forKey: .testnet)
    }
}