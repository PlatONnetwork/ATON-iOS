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
import platonWeb3

/// Support account types.
public enum WalletType {
    case classic
    case observed
    case cold

    var localizeText: String? {
        switch self {
        case .observed:
            return "asset_observer_wallet_title"
        case .cold:
            return "asset_cold_wallet_title"
        default:
            return nil
        }
    }
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

    @objc dynamic var userArrangementIndex = -1

    @objc dynamic var balance: String = ""

    @objc dynamic var lockedBalance: String = ""

    @objc dynamic var mnemonic: String = ""

    @objc dynamic var isBackup: Bool = false

    // 0.9.1新增i字段，用于解决HDPath从206改为486，关闭原有钱包助记词的导出功能，之前钱包的version初始化为0
    @objc dynamic var version: Int = 1

    // 保留chainId，以免通过反射调用的老代码报错
    @objc dynamic var chainId: String = ""

    // 钱包类型
    var type: WalletType {
        if key == nil {
            return .observed
        } else {
            if NetworkStatusService.shared.isConnecting == true {
                return .classic
            } else {
                return .cold
            }
        }
    }

    // 0.7.3增加离线钱包，因为只有一个address，不能生成keystore，且之前uuid是key.address赋值，所以增加address，值为uuid
    var originAddress: String {
        guard let ks = key else { return uuid }
//        return ks.address
        return try! AddrCoder.shared.decodeHex(addr: ks.address.mainnet)
    }

    var address: String {
        guard let ks = key else {
            if(AppConfig.Hrp.LAT == SettingService.shareInstance.currentNodeHrp) {
                return try! AddrCoder.shared.encode(hrp: AppConfig.Hrp.LAT, address: uuid)
            } else {
                return try! AddrCoder.shared.encode(hrp: AppConfig.Hrp.LAX, address: uuid)
            }
        }
        if(AppConfig.Hrp.LAT == SettingService.shareInstance.currentNodeHrp) {
            return ks.address.mainnet
        } else {
            return ks.address.testnet
        }
    }

    // 0.7.5 修改助记词存放位置
    var keystoreMnemonic: String {
        guard version >= 1 else {
            return ""
        }

        guard mnemonic.count > 0 else {
            if let mn = key?.mnemonic, mn.count > 0 {
                return mn
            }
            return ""
        }
        return mnemonic
    }

    public var key: Keystore?

    public var canBackupMnemonic: Bool {
        get {
            guard keystoreMnemonic.count > 0 else {
                return false
            }

            return !isBackup
        }
    }

    convenience init(name: String, originAddress: String) {
        self.init()
        primaryKeyIdentifier = originAddress + SettingService.shareInstance.currentNodeChainId
        self.uuid = originAddress
        self.name = name
        self.avatar = originAddress.walletAddressLastCharacterAvatar()
    }

    convenience init(name: String, mainnetAddress: String) {
        self.init()
        uuid = try! AddrCoder.shared.decodeHex(addr: mainnetAddress)
        primaryKeyIdentifier = uuid
        self.name = name
        self.avatar = uuid.walletAddressLastCharacterAvatar()
    }

    convenience init(name: String, testnetAddress: String) {
        self.init()
        uuid = try! AddrCoder.shared.decodeHex(addr: testnetAddress)
        primaryKeyIdentifier = uuid
        self.name = name
        self.avatar = uuid.walletAddressLastCharacterAvatar()
    }

    convenience public init(name: String, keystoreObject:Keystore) {

        self.init()
        uuid = try! AddrCoder.shared.decodeHex(addr: keystoreObject.address.mainnet)
        primaryKeyIdentifier = uuid
        key = keystoreObject
        keystorePath = ""
        self.name = name
        self.avatar = uuid.walletAddressLastCharacterAvatar()
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
        let originAddress = try! WalletUtil.addressFromPublicKey(publicKeyData, eip55: true)
        key!.address = Keystore.Address(address: originAddress, mainnetHrp: AppConfig.Hrp.LAT, testnetHrp: AppConfig.Hrp.LAX)
        uuid = originAddress
    }

}

extension Wallet: Comparable {
    public static func < (lhs: Wallet, rhs: Wallet) -> Bool {
        let lhsB = AssetService.sharedInstace.balances.first(where: { $0.addr.lowercased() == lhs.originAddress.lowercased() })
        let rhsB = AssetService.sharedInstace.balances.first(where: { $0.addr.lowercased() == rhs.originAddress.lowercased() })

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
