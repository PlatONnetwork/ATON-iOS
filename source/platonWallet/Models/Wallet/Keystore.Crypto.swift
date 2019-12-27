//
//  KeystoreObject.Crypto.swift
//  platonWallet
//
//  Created by matrixelement on 2018/10/16.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import CryptoSwift
import ScryptSwift

public enum KDF: String, Codable {
    case SCRYPT = "scrypt"
    case PBKDF2 = "pbkdf2"
    case unknown
}

extension Keystore {

    public struct Crypto {

        public var cipherText: Data

        public var cipher = "aes-128-ctr"

        public var cipherParams: Crypto.CipherParams

        public var kdf: KDF = KDF.SCRYPT

        public var kdfParams: Any

        public var mac: Data

        public init(cipherText: Data, cipherParams: CipherParams, kdfParams: Any, mac: Data) {
            self.cipherText = cipherText
            self.cipherParams = cipherParams
            self.kdfParams = kdfParams
            self.mac = mac
        }

        public init(password: String, data: Data) throws {
            let cipherParams = CipherParams()
            let kdfParams = ScryptParams()

            let scrypt = Scrypt(params: kdfParams)
            let derivedKey = try scrypt.calculate(password: password)

            let encryptionKey = derivedKey[0...15]
            let aecCipher = try AES(key: encryptionKey.bytes, blockMode: CTR(iv: cipherParams.iv.bytes), padding: .noPadding)

            let encryptedKey = try aecCipher.encrypt(data.bytes)
            let prefix = derivedKey[(derivedKey.count - 16) ..< derivedKey.count]
            let mac = Keystore.computeMAC(prefix: prefix, key: Data(bytes: encryptedKey))

            self.init(cipherText: Data(bytes: encryptedKey), cipherParams: cipherParams, kdfParams: kdfParams, mac: mac)
        }
    }
}

extension Keystore.Crypto: Codable {
    enum CodingKeys: String, CodingKey {
        case cipherText = "ciphertext"
        case cipher
        case cipherParams = "cipherparams"
        case kdf
        case kdfParams = "kdfparams"
        case mac
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let cipherTextStr = try values.decode(String.self, forKey: .cipherText)
        cipherText = Data(bytes: cipherTextStr.hexToBytes())

        cipher = try values.decode(String.self, forKey: .cipher)
        cipherParams = try values.decode(CipherParams.self, forKey: .cipherParams)
        kdf = try values.decode(KDF.self, forKey: .kdf)
        if let scryptParams = try? values.decode(ScryptParams.self, forKey: .kdfParams) {
            kdfParams = scryptParams
        } else if let pbkdf2Params = try? values.decode(PBKDF2Params.self, forKey: .kdfParams) {
            kdfParams = pbkdf2Params
        } else {
            throw DecryptError.unsupportedKDF
        }

        let macStr = try values.decode(String.self, forKey: .mac)
        mac = Data(bytes: macStr.hexToBytes())
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(cipherText.toHexString(), forKey: .cipherText)
        try container.encode(cipher, forKey: .cipher)
        try container.encode(cipherParams, forKey: .cipherParams)
        try container.encode(kdf, forKey: .kdf)
        if let scryptParams = kdfParams as? ScryptParams {
            try container.encode(scryptParams, forKey: .kdfParams)
        } else if let pbkdf2Params = kdfParams as? PBKDF2Params {
            try container.encode(pbkdf2Params, forKey: .kdfParams)
        } else {
            throw EncryptError.unsupportedKDF
        }

        try container.encode(mac.toHexString(), forKey: .mac)
    }
}

extension Keystore.Crypto {

    public struct CipherParams {
        public static let blockSize = 16
        public var iv: Data

        /// Initializes `CipherParams` with a random `iv` for AES 128.
        public init() {
            iv = Data(repeating: 0, count: CipherParams.blockSize)
            let result = iv.withUnsafeMutableBytes { p in
                SecRandomCopyBytes(kSecRandomDefault, CipherParams.blockSize, p)
            }
            precondition(result == errSecSuccess, "Failed to generate random number")
        }
    }

}

extension Keystore.Crypto.CipherParams:Codable {
    enum CodingKeys: String, CodingKey {
        case iv
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let ivStr = try values.decode(String.self, forKey: .iv)
        iv = Data(bytes: ivStr.hexToBytes())
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(iv.toHexString(), forKey: .iv)
    }
}

//extension Keystore.Crypto {
//    
//    /// Scrypt function parameters.
//    public struct ScryptParams {
//        /// The N parameter of Scrypt encryption algorithm, using 256MB memory and taking approximately 1s CPU time on a
//        /// modern processor.
//        public static let standardN = 1 << 18
//        
//        /// The P parameter of Scrypt encryption algorithm, using 256MB memory and taking approximately 1s CPU time on a
//        /// modern processor.
//        public static let standardP = 1
//        
//        /// The N parameter of Scrypt encryption algorithm, using 4MB memory and taking approximately 100ms CPU time on a
//        /// modern processor.
//        public static let lightN = 1 << 12
//        
//        /// The P parameter of Scrypt encryption algorithm, using 4MB memory and taking approximately 100ms CPU time on a
//        /// modern processor.
//        public static let lightP = 6
//        
//        /// Default `R` parameter of Scrypt encryption algorithm.
//        public static let defaultR = 8
//        
//        /// Default desired key length of Scrypt encryption algorithm.
//        public static let defaultDesiredKeyLength = 32
//        
//        /// Random salt.
//        public var salt: Data
//        
//        /// Desired key length in bytes.
//        public var desiredKeyLength = defaultDesiredKeyLength
//        
//        /// CPU/Memory cost factor.
//        public var n = lightN
//        
//        /// Parallelization factor (1..232-1 * hLen/MFlen).
//        public var p = lightP
//        
//        /// Block size factor.
//        public var r = defaultR
//        
//        /// Initializes with default scrypt parameters and a random salt.
//        public init() {
//            let length = 32
//            var data = Data(repeating: 0, count: length)
//            let result = data.withUnsafeMutableBytes { p in
//                SecRandomCopyBytes(kSecRandomDefault, length, p)
//            }
//            precondition(result == errSecSuccess, "Failed to generate random number")
//            salt = data
//        }
//        
//        /// Initializes `ScryptParams` with all values.
//        public init(salt: Data, n: Int, r: Int, p: Int, desiredKeyLength: Int) throws {
//            self.salt = salt
//            self.n = n
//            self.r = r
//            self.p = p
//            self.desiredKeyLength = desiredKeyLength
//            if let error = validate() {
//                throw error
//            }
//        }
//        
//        /// Validates the parameters.
//        ///
//        /// - Returns: a `ValidationError` or `nil` if the parameters are valid.
//        public func validate() -> ValidationError? {
//            if desiredKeyLength > ((1 << 32 as Int64) - 1 as Int64) * 32 {
//                return ValidationError.desiredKeyLengthTooLarge
//            }
//            if UInt64(r) * UInt64(p) >= (1 << 30) {
//                return ValidationError.blockSizeTooLarge
//            }
//            if n & (n - 1) != 0 || n < 2 {
//                return ValidationError.invalidCostFactor
//            }
//            if (r > Int.max / 128 / p) || (n > Int.max / 128 / r) {
//                return ValidationError.overflow
//            }
//            return nil
//        }
//        
//        public enum ValidationError: Error {
//            case desiredKeyLengthTooLarge
//            case blockSizeTooLarge
//            case invalidCostFactor
//            case overflow
//        }
//    }
//    
//}
//
//extension Keystore.Crypto.ScryptParams: Codable {
//    enum CodingKeys: String, CodingKey {
//        case salt
//        case desiredKeyLength = "dklen"
//        case n
//        case p
//        case r
//    }
//    
//    public init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        let saltStr = try values.decode(String.self, forKey: .salt)
//        salt = Data(bytes: saltStr.hexToBytes())
//        desiredKeyLength = try values.decode(Int.self, forKey: .desiredKeyLength)
//        n = try values.decode(Int.self, forKey: .n)
//        p = try values.decode(Int.self, forKey: .p)
//        r = try values.decode(Int.self, forKey: .r)
//    }
//    
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(salt.toHexString(), forKey: .salt)
//        try container.encode(desiredKeyLength, forKey: .desiredKeyLength)
//        try container.encode(n, forKey: .n)
//        try container.encode(p, forKey: .p)
//        try container.encode(r, forKey: .r)
//    }
//}
