//
//  EthereumUtil.swift
//  platonWallet
//
//  Created by matrixelement on 2018/10/17.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import TrezorCrypto
import platonWeb3

public let publicKeyByteSize = 64
public let privateKeyByteSize = 32

class WalletUtil {
    
    static func generateMnemonic(strength:Int) throws -> String {
        
        guard let ptr = mnemonic_generate(128) else { 
            throw Error.mnemonicGeneFailed
        }  
        
        guard let mnemonic = String(cString: ptr, encoding: .utf8) else {
            throw Error.mnemonicGeneFailed
        }
        
        return mnemonic
        
    }
    
    static func seedFromMnemonic(_ mnemonic:String, passphrase:String) -> Data {
        
        let seedLength = 512 / 8
        let seed = UnsafeMutablePointer<UInt8>.allocate(capacity: seedLength)
        seed.initialize(repeating: 0, count: seedLength)
        defer {
            seed.deinitialize(count: seedLength)
            seed.deallocate()
        }
        mnemonic_to_seed(mnemonic.cString(using: .utf8), passphrase.cString(using: .utf8), seed, nil)
        
        return Data(bytes: seed, count: seedLength)
         
    }
    
    static func hdNodeFromSeed(_ seed:Data) -> HDNode{
        
        var node = HDNode()
        
        let count = Int32(seed.count)
        _ = seed.withUnsafeBytes { seed in
            hdnode_from_seed(seed, count, "secp256k1", &node)
        }
        return node
    }
    
    static func privateKeyFromHDNode(_ node:inout HDNode, hdPath:String) throws -> Data {
        
        guard let derivationIndices = HDPath(pathStr: hdPath).indices else { 
            throw Error.hdPathInvalid
        }
        
        for index in derivationIndices {
            hdnode_private_ckd(&node, index)
        }
        
        let privateKeyData = Data(bytes: withUnsafeBytes(of: &node.private_key) { ptr in
            return ptr.map({ $0 })
        })
        
        return privateKeyData
        
    }
    
    static func publicKeyFromPrivateKey(_ privateKey:Data) -> Data {
        
        let publicKeyLength = 65
        let publicKey = UnsafeMutablePointer<UInt8>.allocate(capacity: publicKeyLength)
        publicKey.initialize(repeating: 0, count: publicKeyLength)
        defer {
            publicKey.deinitialize(count: publicKeyLength)
            publicKey.deallocate()
        }
        var mutableSecp256k1 = secp256k1
        ecdsa_get_public_key65(&mutableSecp256k1, privateKey.bytes, publicKey)
        return Data(bytes: publicKey, count: 65)[1...]
        
    }
    
    static func addressFromPublicKey(_ publicKey:Data, eip55:Bool) throws -> String {
        
        let result = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
        result.initialize(repeating: 0, count: 32)
        defer {
            result.deinitialize(count: 32)
            result.deallocate()
        }
        
        guard publicKey.count == 64 else {
            throw Error.publicKeyInvalid
        }
        
        keccak_256(publicKey.bytes, publicKey.count, result)
        let resultData = Data(bytes: result, count: 32)
        let addressData = resultData.suffix(20)
        do {
            return try EthereumAddress(bytes: addressData.bytes).hex(eip55: eip55)
        } catch  {
            throw Error.addressGeneFailed
        }

    }
    
    static func isValidMnemonic(_ mnemonic:String) -> Bool {
        
        let res = mnemonic_check(mnemonic.cString(using: .utf8))
        return res > 0
        
    }
    
    static func isValidPrivateKeyData(_ privateKey:Data) -> Bool
    {
        if privateKey.count != privateKeyByteSize {
            return false
        }
        
        guard privateKey.contains(where: { $0 != 0 }) else {
            return false
        }
        
        return true
    }    
    
    static func isValidPrivateKeyHexStr(_ privateKey: String) -> Bool {
        
        if privateKey.length != privateKeyByteSize * 2 {
            return false
        }
        return true
    }
    
    static func isValidPublicKeyHexStr(_ publicKey: String) -> Bool {
        
        if publicKey.length != publicKeyByteSize * 2 {
            return false 
        }
        return true
    }
    
    static func isValidAddress(_ address: String) -> Bool {
        return address.is40ByteAddress()
    }
    
    
    static func generateNewObservedWalletName() -> String {
        let wallets = WallletPersistence.sharedInstance.getAll(detached: true)
        let observeredWallets = wallets.filter { $0.type == .observed }
        guard let lastObWallet = observeredWallets.last else {
            return "LAT-Wallet-1"
        }
        
        let walletName = lastObWallet.name
        let indexString = String(walletName.suffix(from: walletName.index(walletName.startIndex, offsetBy: 11)))
        guard let index = Int(indexString) else { return "LAT-Wallet-1" }
        return String(format: "LAT-Wallet-%d", index + 1)
    }
}

extension WalletUtil {
    
    public enum Error : Swift.Error {
        case mnemonicGeneFailed
        case hdPathInvalid
        case publicKeyInvalid
        case addressGeneFailed
    }
    
}
