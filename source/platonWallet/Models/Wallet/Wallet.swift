//
//  Wallet.swift
//  platonWallet
//
//  Created by matrixelement on 2018/10/15.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import RealmSwift

/// Support account types.
public enum WalletType {
    case ATPWallet
    case sWallet
}



public enum WalletError: LocalizedError {
    case invalidKeyType
}


public final class Wallet: Object {
    
    @objc dynamic var uuid: String = ""
    
    @objc dynamic var keystorePath: String = "" 
    
    @objc dynamic var createTime = Date().millisecondsSince1970
    
    @objc dynamic var updateTime = Date().millisecondsSince1970
    
    @objc dynamic var name: String = ""
    
    @objc dynamic var avatar: String = ""
    
    var type: WalletType = .ATPWallet
    
    public var key: Keystore?
    
//    public var keystoreJson: String? {
//        
//        return try? String(contentsOfFile: keystoreFolderPath + "/\(keystorePath)")
//        
//    }
    
//    convenience public init(name: String, keystoreFileURL: URL, keystoreObject: Keystore) {
//        
//        self.init()
//        uuid = keystoreObject.address
//        key = keystoreObject
//        keystorePath = keystoreFileURL.absoluteString
//        self.name = name
//        
//    }
//    
    convenience public init(name: String, keystoreObject:Keystore) {
        
        self.init()
        uuid = keystoreObject.address
        key = keystoreObject
        keystorePath = ""
        self.name = name
        self.avatar = keystoreObject.address.walletRandomAvatar()
        
    }
    
    override public static func ignoredProperties() ->[String] {
        return ["key"]
    }
    
    override public static func primaryKey() -> String? {
        return "uuid"
    }

    public static func == (lhs: Wallet, rhs: Wallet) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    public func updateInfoFromPrivateKey(_ privateKey: String) {
        
        let publicKeyData = WalletUtil.publicKeyFromPrivateKey(Data(bytes: privateKey.hexToBytes()))
        
        key!.publicKey = publicKeyData.toHexString()
        key!.address = try! WalletUtil.addressFromPublicKey(publicKeyData, eip55: true)
        uuid = key!.address
    }

}
