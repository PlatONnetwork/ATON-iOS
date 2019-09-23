//
//  Keystore.swift
//  platonWallet
//
//  Created by matrixelement on 2018/10/15.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import CryptoSwift
import TrezorCrypto
//import Web3
import ScryptSwift

let HDPATH = "m/44'/206'/0'/0/0"

public struct Keystore {
    
    var id: String
    var address: String
    var crypto: Keystore.Crypto
    var version = 3
    
    var publicKey: String?
    var mnemonic:String?
    
    public init(password: String) throws {
        
        let mnemonic:String
        
        do {
             mnemonic = try WalletUtil.generateMnemonic(strength: 128)
        } catch WalletUtil.Error.mnemonicGeneFailed {
            throw Error.initFailed
        }
        
        try self.init(password: password, mnemonic: mnemonic, passphrase: "")
        
        self.mnemonic = try encrypt(mnemonic: mnemonic, password: password)
        
    }
    

    public init(contentsOf url: URL) throws {
        let data = try Data(contentsOf: url)
        self = try JSONDecoder().decode(Keystore.self, from: data)
    }
    
    
    public init(password: String, mnemonic: String, passphrase: String = "") throws {
        
        let seed = WalletUtil.seedFromMnemonic(mnemonic, passphrase: "")
        
        var hdNode = WalletUtil.hdNodeFromSeed(seed)
        
        var privateKey:Data
        
        do {
            privateKey = try WalletUtil.privateKeyFromHDNode(&hdNode, hdPath: HDPATH)
            print("privateKey:\(privateKey.toHexString())")
        } catch WalletUtil.Error.hdPathInvalid {
            throw Error.initFailed
        }
        
        try self.init(password: password, privateKey: privateKey)
        
    }
    
    public init(password: String, privateKey: Data) throws {
        
        let publicKey = WalletUtil.publicKeyFromPrivateKey(privateKey)
        
        do {
            address = try WalletUtil.addressFromPublicKey(publicKey, eip55: true)
            print("address:\(address)")
        } catch WalletUtil.Error.publicKeyInvalid {
            throw Error.initFailed
        }
        id = UUID().uuidString.lowercased()
        crypto = try Keystore.Crypto(password: password, data: privateKey)
        self.publicKey = publicKey.toHexString()
        
    }
    
    
    /// Decrypts the key and returns the private key.
    public func decrypt(password: String) throws -> Data {
        let decryptionKey = try geneDecryptionKey(password: password)
        let decryptedPK: [UInt8]
        switch crypto.cipher {
        case "aes-128-ctr":
            let aesCipher = try AES(key: decryptionKey.bytes, blockMode: CTR(iv: crypto.cipherParams.iv.bytes), padding: .noPadding)
            decryptedPK = try aesCipher.decrypt(crypto.cipherText.bytes)
        case "aes-128-cbc":
            let aesCipher = try AES(key: decryptionKey.bytes, blockMode: CBC(iv: crypto.cipherParams.iv.bytes), padding: .noPadding)
            decryptedPK = try aesCipher.decrypt(crypto.cipherText.bytes)
        default:
            throw DecryptError.unsupportedCipher
        }
        
        return Data(bytes: decryptedPK)
    }
    
    fileprivate func geneDecryptionKey(password: String) throws -> Data {
        
        let derivedKey: Data
        switch crypto.kdf {
        case "scrypt":
            let scrypt = Scrypt(params: crypto.kdfParams)
            derivedKey = try scrypt.calculate(password: password)
        default:
            throw DecryptError.unsupportedKDF
        }
        
        let mac = Keystore.computeMAC(prefix: derivedKey[derivedKey.count - 16 ..< derivedKey.count], key: crypto.cipherText)
        if mac != crypto.mac {
            throw DecryptError.invalidPassword
        }
        
        return derivedKey[0...15]
        
    }
    
    fileprivate func encrypt(mnemonic: String, password: String) throws -> String {
        
        let decryptionKey = try geneDecryptionKey(password: password)
        let encryptedData: [UInt8]
        switch crypto.cipher {
        case "aes-128-ctr":
            
            let aesCipher = try AES(key: decryptionKey.bytes, blockMode: CTR(iv: crypto.cipherParams.iv.bytes), padding: .noPadding)
            encryptedData = try aesCipher.encrypt(mnemonic.data(using: .utf8)!.bytes)
            
        case "aes-128-cbc":
            let aesCipher = try AES(key: decryptionKey.bytes, blockMode: CBC(iv: crypto.cipherParams.iv.bytes), padding: .noPadding)
            encryptedData = try aesCipher.encrypt(mnemonic.data(using: .utf8)!.bytes)
        default:
            throw DecryptError.unsupportedCipher
        }
        return encryptedData.toHexString()
    }
    
    public func decrypt(encryptedMnemonic: String, password: String) throws -> String {
        let decryptionKey = try geneDecryptionKey(password: password)
        let decryptedData: [UInt8]
        switch crypto.cipher {
        case "aes-128-ctr":
            
            let aesCipher = try AES(key: decryptionKey.bytes, blockMode: CTR(iv: crypto.cipherParams.iv.bytes), padding: .noPadding)
            decryptedData = try aesCipher.decrypt(encryptedMnemonic.hexToBytes())
            
        case "aes-128-cbc":
            let aesCipher = try AES(key: decryptionKey.bytes, blockMode: CBC(iv: crypto.cipherParams.iv.bytes), padding: .noPadding)
            decryptedData = try aesCipher.decrypt(encryptedMnemonic.hexToBytes())
        default:
            throw DecryptError.unsupportedCipher
        }
        return String(data: Data(decryptedData), encoding: .utf8)!
    }
    
    static func computeMAC(prefix: Data, key: Data) -> Data {
        var data = Data(capacity: prefix.count + key.count)
        data.append(prefix)
        data.append(key)
        return data.sha3(.keccak256)
    }
    
}

public enum DecryptError: Error {
    case unsupportedKDF
    case unsupportedCipher
    case invalidCipher
    case invalidPassword
}

public enum EncryptError: Error {
    case invalidMnemonic
    case invalidDerivationPath
}

extension Keystore: Codable {
    enum CodingKeys: String, CodingKey {
        case address
        case id
        case crypto
        case version
        case publicKey
        case mnemonic
    }
    
    enum UppercaseCodingKeys: String, CodingKey {
        case crypto = "Crypto"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let altValues = try decoder.container(keyedBy: UppercaseCodingKeys.self)
        
        id = try values.decode(String.self, forKey: .id)
        if let crypto = try? values.decode(Keystore.Crypto.self, forKey: .crypto) {
            self.crypto = crypto
        } else {
            self.crypto = try altValues.decode(Keystore.Crypto.self, forKey: .crypto)
        }
        version = try values.decode(Int.self, forKey: .version)
        address = try values.decodeIfPresent(String.self, forKey: .address) ?? ""
        publicKey = try values.decodeIfPresent(String.self, forKey: .publicKey)
        mnemonic = try values.decodeIfPresent(String.self, forKey: .mnemonic)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(address, forKey: .address)
        try container.encode(crypto, forKey: .crypto)
        try container.encode(version, forKey: .version)
        try container.encodeIfPresent(publicKey, forKey: .publicKey)
        try container.encodeIfPresent(mnemonic, forKey: .mnemonic)
    }
}

extension Keystore {
    enum Error: Swift.Error {
        case initFailed
    }
}

//private extension String {
//    func drop0x() -> String {
//        if hasPrefix("0x") {
//            return String(dropFirst(2))
//        }
//        return self
//    }
//}

