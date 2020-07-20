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
import platonWeb3

let HDPATH = "m/44'/486'/0'/0/0"

public struct Keystore {

    var id: String
    var address: Keystore.Address
    var crypto: Keystore.Crypto
    var version = 3

    var publicKey: String?
    var mnemonic:String?
    /// 主私钥
    private var hdNode: HDNode?
    private var rootPrivateKey: String?

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

    /// 根据钱包物理类型 构造Keystore
    public init(password: String, walletPhysicalType: WalletPhysicalType) throws {
        let mnemonic:String
        do {
            mnemonic = try WalletUtil.generateMnemonic(strength: 128)
        } catch WalletUtil.Error.mnemonicGeneFailed {
            throw Error.initFailed
        }
        try self.init(password: password, mnemonic: mnemonic, passphrase: "", walletPhysicalType: walletPhysicalType)
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
        } catch WalletUtil.Error.hdPathInvalid {
            throw Error.initFailed
        }

        try self.init(password: password, privateKey: privateKey)
        self.mnemonic = try encrypt(mnemonic: mnemonic, password: password)
    }

    public init(password: String, mnemonic: String, passphrase: String = "", walletPhysicalType: WalletPhysicalType) throws {

        let seed = WalletUtil.seedFromMnemonic(mnemonic, passphrase: "")
        var hdNode = WalletUtil.hdNodeFromSeed(seed)
//        self.hdNode = hdNode
        let mirror = Mirror(reflecting: hdNode.private_key)
        var privateKeyStr = String()
        for (_, v) in mirror.children {
            var value = String(format: "%x", v as! CVarArg)
            if value.count == 1 {
                value = "0" + value
            }
            privateKeyStr.append(value)
        }
        print("rootPrivateKey:", privateKeyStr)
        
        if walletPhysicalType == .hd {
            let data = Data(hex: privateKeyStr)
            try self.init(password: password, privateKey: data)
        } else {
            var privateKey:Data
            do {
                privateKey = try WalletUtil.privateKeyFromHDNode(&hdNode, hdPath: HDPATH)
            } catch WalletUtil.Error.hdPathInvalid {
                throw Error.initFailed
            }

            try self.init(password: password, privateKey: privateKey)
        }
        self.rootPrivateKey = privateKeyStr
        self.hdNode = hdNode
        self.mnemonic = try encrypt(mnemonic: mnemonic, password: password)
    }
    
    /// 根据hdNode生成根私钥
    fileprivate func generateRootPrivateKey(from hdNode: HDNode) -> Data {
        let mirror = Mirror(reflecting: hdNode.private_key)
        var privateKeyStr = String()
        for (_, v) in mirror.children {
            var value = String(format: "%x", v as! CVarArg)
            if value.count == 1 {
                value = "0" + value
            }
            privateKeyStr.append(value)
        }
        print("rootPrivateKey:", privateKeyStr)
        let data = Data(hex: privateKeyStr)
        return data
        
    }
    
    /// 通过Keystore私钥和路径生成子地址
    func generateHDSubAddress(index: UInt) -> String {
        let path = "m/44'/486'/0'/0/\(index)"
        var hdNode = self.hdNode!
        let privateKey = try! WalletUtil.privateKeyFromHDNode(&hdNode, hdPath: path)
        let publicKey = WalletUtil.publicKeyFromPrivateKey(privateKey)
        let originAddress = try! WalletUtil.addressFromPublicKey(publicKey, eip55: true)
        return originAddress
    }
    
    /// 通过Keystore生成母地址
    func generateHDParentAddress() -> String {
        let publicKey = WalletUtil.publicKeyFromPrivateKey(generateRootPrivateKey(from: self.hdNode!))
        let originAddress = try! WalletUtil.addressFromPublicKey(publicKey, eip55: true)
        return originAddress
    }

    /// 构建常规钱包的钱包文件
    public init(password: String, privateKey: Data) throws {

        let publicKey = WalletUtil.publicKeyFromPrivateKey(privateKey)

        do {
            let originAddress = try WalletUtil.addressFromPublicKey(publicKey, eip55: true)
            address = Keystore.Address(address: originAddress, mainnetHrp: AppConfig.Hrp.LAT, testnetHrp: AppConfig.Hrp.LAX)
            print("address:\(originAddress)")
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
        case .SCRYPT:
            if let scryptParams = crypto.kdfParams as? ScryptParams {
                let scrypt = Scrypt(params: scryptParams)
                derivedKey = try scrypt.calculate(password: password)
            } else {
                throw DecryptError.unsupportedKDFParams
            }
        case .PBKDF2:
            if let pbkdf2Params = crypto.kdfParams as? PBKDF2Params, let pw = password.data(using: .utf8)?.bytes {
                let pbkdf2 = try PKCS5.PBKDF2(password: pw, salt: pbkdf2Params.salt, iterations: pbkdf2Params.iterations, keyLength: pbkdf2Params.dklen, variant: pbkdf2Params.prf)
                let derivedKeyBytes = try pbkdf2.calculate()
                derivedKey = Data(bytes: derivedKeyBytes)
            } else {
                throw DecryptError.unsupportedKDFParams
            }
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
    case unsupportedKDFParams
}

public enum EncryptError: Error {
    case invalidMnemonic
    case invalidDerivationPath
    case unsupportedKDF
}

extension Keystore: Codable {
    enum CodingKeys: String, CodingKey {
        case address
        case id
        case crypto
        case version
        case publicKey
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

        if let address = try? values.decode(String.self, forKey: .address) {
            self.address = Keystore.Address(address: address, mainnetHrp: AppConfig.Hrp.LAT, testnetHrp: AppConfig.Hrp.LAX)
        } else {
            self.address = try! values.decodeIfPresent(Keystore.Address.self, forKey: .address) ?? Keystore.Address(mainnet: "", testnet: "")
        }
        publicKey = try values.decodeIfPresent(String.self, forKey: .publicKey)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(address, forKey: .address)
        try container.encode(crypto, forKey: .crypto)
        try container.encode(version, forKey: .version)
        try container.encodeIfPresent(publicKey, forKey: .publicKey)
    }
}

extension Keystore {
    enum Error: Swift.Error {
        case initFailed
    }
}
