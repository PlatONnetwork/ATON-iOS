//
//  Wallet.swift
//  platonWallet
//
//  Created by matrixelement on 2018/10/15.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import RealmSwift
import BigInt

/// Support account types.
public enum WalletType {
    case classic
    case observed
    case cold
}

public enum WalletError: LocalizedError {
    case invalidKeyType
}

public final class Wallet: Object {

    @objc dynamic var uuid: String = ""

    @objc dynamic var primaryKeyIdentifier: String = ""

    @objc dynamic var keystorePath: String = ""

    @objc dynamic var createTime = Date().millisecondsSince1970

    @objc dynamic var updateTime = Date().millisecondsSince1970

    @objc dynamic var name: String = ""

    @objc dynamic var avatar: String = ""

    @objc dynamic var nodeURLStr: String = ""

    @objc dynamic var userArrangementIndex = -1

    @objc dynamic var balance: String = ""

    @objc dynamic var lockedBalance: String = ""

    // 钱包类型
    var type: WalletType {
        if key == nil {
            return .observed
        } else {
            if NetworkManager.shared.reachabilityManager?.isReachable == true {
                return .classic
            } else {
                return .cold
            }
        }
    }

    // 0.7.3增加离线钱包，因为只有一个address，不能生成keystore，且之前uuid是key.address赋值，所以增加address，值为uuid
    var address: String {
        guard let ks = key else { return uuid }
        return ks.address
    }

    public var key: Keystore?

    public var canBackupMnemonic: Bool {
        get {
            return key?.mnemonic != nil
        }
    }

    convenience init(name: String, address: String) {
        self.init()
        primaryKeyIdentifier = address + SettingService.threadSafeGetCurrentNodeURLString()
        self.uuid = address
        self.name = name
        self.avatar = address.walletAddressLastCharacterAvatar()
    }

    convenience public init(name: String, keystoreObject:Keystore) {

        self.init()
        uuid = keystoreObject.address
        primaryKeyIdentifier = keystoreObject.address + SettingService.threadSafeGetCurrentNodeURLString()
        key = keystoreObject
        keystorePath = ""
        nodeURLStr = SettingService.threadSafeGetCurrentNodeURLString()
        self.name = name
        self.avatar = keystoreObject.address.walletAddressLastCharacterAvatar()
    }

    override public static func ignoredProperties() -> [String] {
        return ["key"]
    }

    override public static func primaryKey() -> String? {
        return "primaryKeyIdentifier"
    }

    public static func == (lhs: Wallet, rhs: Wallet) -> Bool {
        return lhs.primaryKeyIdentifier == rhs.primaryKeyIdentifier
    }

    public func updateInfoFromPrivateKey(_ privateKey: String) {

        let publicKeyData = WalletUtil.publicKeyFromPrivateKey(Data(bytes: privateKey.hexToBytes()))

        key!.publicKey = publicKeyData.toHexString()
        key!.address = try! WalletUtil.addressFromPublicKey(publicKeyData, eip55: true)
        uuid = key!.address
    }

}

extension Wallet: Comparable {
    public static func < (lhs: Wallet, rhs: Wallet) -> Bool {
        let lhsB = AssetService.sharedInstace.balances.first(where: { $0.addr.lowercased() == lhs.address.lowercased() })
        let rhsB = AssetService.sharedInstace.balances.first(where: { $0.addr.lowercased() == rhs.address.lowercased() })

        guard
            let lhsBBigUInt = BigUInt(lhsB?.free ?? "0"),
            let rhsBBigUInt = BigUInt(rhsB?.free ?? "0") else {
                return lhs.createTime < rhs.createTime
        }

        if lhsBBigUInt == rhsBBigUInt {
            return lhs.createTime < rhs.createTime
        }

        return lhsBBigUInt > rhsBBigUInt
    }

}
