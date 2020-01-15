//
//  PBKDF2Params.swift
//  platonWallet
//
//  Created by Admin on 27/12/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import CryptoSwift

public struct PBKDF2Params {
    var salt: Array<UInt8>
    var iterations: Int
    var dklen: Int
    var prf: HMAC.Variant

    public init() {
        dklen = 32
        iterations = 1000000

        let length = 32
        var data = Data(repeating: 0, count: length)
        let result = data.withUnsafeMutableBytes { p in
            SecRandomCopyBytes(kSecRandomDefault, length, p)
        }
        precondition(result == errSecSuccess, "Failed to generate random number")
        salt = data.bytes
        prf = .sha256
    }
}

extension PBKDF2Params: Codable {

    enum CodingKeys: String, CodingKey {
        case salt
        case iterations = "c"
        case dklen
        case prf
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let saltData = try values.decodeHexString(forKey: .salt)
        salt = saltData.bytes
        iterations = try values.decode(Int.self, forKey: .iterations)
        dklen = try values.decode(Int.self, forKey: .dklen)

        let prfString = try values.decode(String.self, forKey: .prf)
        prf = prfString.prf
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let saltData = Data(bytes: salt)
        try container.encode(saltData.hexString, forKey: .salt)
        try container.encode(iterations, forKey: .iterations)
        try container.encode(dklen, forKey: .dklen)
        try container.encode(prf.prf, forKey: .prf)
    }
}

extension HMAC.Variant {
    var prf: String {
        switch self {
        case .md5:
            return "hmac-md5"
        case .sha1:
            return "hmac-sha1"
        case .sha256:
            return "hmac-sha256"
        case .sha384:
            return "hmac-sha384"
        case .sha512:
            return "hmac-sha512"
        }
    }
}

extension String {
    var prf: HMAC.Variant {
        switch self {
        case "hmac-md5":
            return .md5
        case "hmac-sha1":
            return .sha1
        case "hmac-sha256":
            return .sha256
        case "hmac-sha384":
            return .sha384
        case "hmac-sha512":
            return .sha512
        default:
            return .sha256
        }
    }
}
