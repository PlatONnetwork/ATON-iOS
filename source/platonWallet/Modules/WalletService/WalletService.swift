//
//  KeyStore.swift
//  platonWallet
//
//  Created by matrixelement on 2018/10/15.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import RealmSwift
import Localize_Swift
import platonWeb3

/// 物理层级的钱包类型
public enum WalletPhysicalType: Int {
    case normal = 0
    case hd = 1
}

let keystoreFolderPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/keystore"

public final class WalletService {

    let keystoreFolderURL : URL

    public var wallets: [Wallet] = WallletPersistence.sharedInstance.getAll() {
        didSet {
//            print("\n😀😀😀😀😀😀😀😀😀😀😀😀😀\n")
        }
    }
    

    static let sharedInstance = WalletService()

    let walletQueue = DispatchQueue(label: "com.ju.walletServiceQueue", qos: .userInitiated, attributes: .concurrent)

    private init() {
        keystoreFolderURL = URL(fileURLWithPath: keystoreFolderPath)
        print("📁keystoreFloderURL:\(keystoreFolderURL.absoluteString)")
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: keystoreFolderPath) {
            try! fileManager.createDirectory(at: keystoreFolderURL, withIntermediateDirectories: false, attributes: nil)
        }

//        wallets = WallletPersistence.sharedInstance.getAll()

    }

    func refreshDB() {
        wallets.removeAll()
        wallets.append(contentsOf: WallletPersistence.sharedInstance.getAll())
    }
    
    func getWallet(byUUID uuid: String) -> Wallet? {
        for item in wallets {
            if item.uuid == uuid {
                return item
            }
        }
        return nil
    }

    func getWalletByAddress(address: String) -> Wallet? {
        for item in wallets {
            if item.address.isBech32AddressEqual(other: address) {
                return item
            }
        }
        return nil
    }
    
    /// 用于首页已经隐藏的钱包(是否已经点击过隐藏，隐藏后，直到下次启动前都不能再提示备份)
    private var hiddenWalletsAddresses: [String] = []
    /// 检查某个钱包是否被隐藏
    public func checkHiddenWalletsContain(wallet: Wallet) -> Bool {
        if self.hiddenWalletsAddresses.contains(wallet.address) == true {
            return true
        } else {
            return false
        }
    }
    /// 更新某个钱包的隐藏状态（设为隐藏）
    public func setupHiddenStatus(wallet: Wallet) {
        if hiddenWalletsAddresses.contains(wallet.address) == false {
            hiddenWalletsAddresses.append(wallet.address)
        }
    }

    /// 创建钱包（创建普通类型和HD类型）
    public func createWallet(name:String, password: String, physicalType: WalletPhysicalType, completion: @escaping (Wallet?, Error?) -> Void) {
        walletQueue.async {
            guard let keystore = try? Keystore(password: password, walletPhysicalType: physicalType) else {
                DispatchQueue.main.sync {
                    completion(nil, Error.keystoreGeneFailed)
                }
                return
            }

            var wallet: Wallet!
            if physicalType == .normal {
                // 普通钱包
                let uuid = try! AddrCoder.shared.decodeHex(addr: keystore.address.mainnet)
                wallet = Wallet(uuid: uuid, name: name, keystoreObject: keystore, isHD: false, pathIndex: 0, parentId: nil)
                DispatchQueue.main.async {
                    do {
                        try self.saveToDB(wallet: wallet)
                    } catch {
                        completion(nil, Error.keystoreFileSaveFailed)
                    }
                    completion(wallet, nil)
                }
            } else {
                // 分层钱包
                wallet = Wallet(uuid: keystore.generateRootWalletAddress(), name: name, keystoreObject: keystore, isHD: true, pathIndex: 0, parentId: nil)
                var subWallets: [Wallet] = []
                for i: Int in 0..<30 {
                    let subWalletItem = Wallet(uuid: keystore.generateHDSubAddress(index: i), name: "\(name)_\(i + 1)", keystoreObject: keystore, isHD: true, pathIndex: Int(i), parentId: wallet.uuid)
                    subWallets.append(subWalletItem)
                }
                DispatchQueue.main.async {
                    do {
                        try self.saveToDB(wallet: wallet, subWallets: subWallets.count == 0 ? nil : subWallets)
                    } catch {
                        completion(nil, Error.keystoreFileSaveFailed)
                    }
                    completion(wallet, nil)
                }
            }
        }
    }

    // 导入观察钱包
    public func `import`(address: String, completion: @escaping (Wallet?, Error?) -> Void) {
        guard WalletUtil.isValidAddress(address) else {
            completion(nil, Error.invalidAddress)
            return
        }
        walletQueue.async {
            let walletName = WalletUtil.generateNewObservedWalletName()
            let wallet = Wallet(name: walletName, originAddress: try! AddrCoder.shared.decodeHex(addr: address))
            DispatchQueue.main.async {
                do {
                    try self.saveObservedWalletToDB(wallet: wallet)
                } catch Error.walletAlreadyExists {
                    completion(nil, Error.walletAlreadyExists)
                    return
                } catch {
                    completion(nil, Error.keystoreFileSaveFailed)
                    return
                }
                completion(wallet, nil)
            }
        }
    }

    /// importWalletFromMnemonic
    public func `import`(mnemonic: String ,passphrase: String = "", walletName: String, walletPassword: String, physicalType: WalletPhysicalType = .normal, completion: @escaping (Wallet?, Error?) -> Void) {

        guard WalletUtil.isValidMnemonic(mnemonic) else {
            completion(nil, Error.invalidMnemonic)
            return
        }

        walletQueue.async {
            guard let keystore = try? Keystore(password: walletPassword, mnemonic: mnemonic, walletPhysicalType: physicalType) else {
                DispatchQueue.main.async {
                    completion(nil, Error.keystoreGeneFailed)
                }
                return
            }
            let name = walletName
            var wallet: Wallet!
            if physicalType == .normal {
                // 普通钱包
                wallet = Wallet(uuid: keystore.generateRootWalletAddress(), name: name, keystoreObject: keystore, isHD: false, pathIndex: 0, parentId: nil)
                wallet.isBackup = true
            } else {
                let allWallets = WalletService.sharedInstance.wallets
                let walletsUUIDs = allWallets.map { (wal) -> String in return wal.uuid }
                if walletsUUIDs.contains(keystore.generateHDSubAddress(index: 0)) == true {
                    completion(nil, Error.walletAlreadyExists)
                    return
                }
                // 分层钱包
                wallet = Wallet(uuid: keystore.generateRootWalletAddress(), name: name, keystoreObject: keystore, isHD: true, pathIndex: 0, parentId: nil)
                wallet.isBackup = true
                for i: Int in 0..<30 {
                    let subWalletItem = Wallet(uuid: keystore.generateHDSubAddress(index: i), name: "\(name)_\(i + 1)", keystoreObject: keystore, isHD: true, pathIndex: Int(i), parentId: wallet.uuid)
                    wallet.subWallets.append(subWalletItem)
                }
            }
            DispatchQueue.main.async {
                do {
                    try self.saveToDB(wallet: wallet)
                } catch Error.walletAlreadyExists {
                    completion(nil, Error.walletAlreadyExists)
                    return
                } catch {
                    completion(nil, Error.keystoreFileSaveFailed)
                }
                completion(wallet, nil)
            }
            
        }
    }

    /// importWalletFromPrivateKey
    public func `import`(privateKey: String, walletName: String, walletPassword: String, completion: @escaping (Wallet?, Error?) -> Void) {
        var privateK = privateKey
        if privateK.hasPrefix("0x") {
            privateK = String(privateK.dropFirst(2))
        }
        guard WalletUtil.isValidPrivateKeyHexStr(privateK) else {
            completion(nil, Error.invalidKey)
            return
        }
        let privateKeyData = Data(bytes: privateK.hexToBytes())
        guard WalletUtil.isValidPrivateKeyData(privateKeyData) else {
            completion(nil, Error.invalidKey)
            return
        }
        walletQueue.async {
            guard let keystore = try? Keystore(password: walletPassword, privateKey: privateKeyData) else {
                DispatchQueue.main.async {
                    completion(nil, Error.keystoreGeneFailed)
                }
                return
            }
            /// 只能私钥导入普通钱包
            let uuid = try! AddrCoder.shared.decodeHex(addr: keystore.address.mainnet)
            let wallet = Wallet(uuid: uuid, name: walletName, keystoreObject: keystore, isHD: false, pathIndex: 0, parentId: nil)
            DispatchQueue.main.async {
                do {
                    try self.saveToDB(wallet: wallet)
                } catch Error.walletAlreadyExists {
                    completion(nil, Error.walletAlreadyExists)
                    return
                } catch {
                    completion(nil, Error.keystoreFileSaveFailed)
                    return
                }
                completion(wallet, nil)
            }
        }
    }

    /// importWalletFromKeystoreFile
    public func `import`(keystore: String, walletName: String, password: String, completion: @escaping (Wallet?, Error?) -> Void) {
        guard let keystoreObj = try? JSONDecoder().decode(Keystore.self, from: keystore.data(using: .utf8)!) else {
            completion(nil, Error.invalidKeystore)
            return
        }
        walletQueue.async {
            let uuid = try! AddrCoder.shared.decodeHex(addr: keystoreObj.address.mainnet)
            let wallet = Wallet(uuid: uuid, name: walletName, keystoreObject: keystoreObj, isHD: false, pathIndex: 0, parentId: nil)

            self.exportPrivateKey(wallet: wallet, password: password, completion: { (privateKey, error) in
                if error != nil && privateKey == nil {
                    completion(nil, error)
                    return
                }
                if keystoreObj.crypto.kdf != .SCRYPT {
                    let privateKeyData = Data(bytes: privateKey!.hexToBytes())

                    guard WalletUtil.isValidPrivateKeyData(privateKeyData) else {
                        completion(nil, Error.invalidKey)
                        return
                    }
                    guard let ks = try? Keystore(password: password, privateKey: privateKeyData) else {
                        DispatchQueue.main.async {
                            completion(nil, Error.keystoreGeneFailed)
                        }
                        return
                    }
                    wallet.key = ks
                }
                wallet.updateInfoFromPrivateKey(privateKey!)
                do {
                    try self.saveToDB(wallet: wallet)

                } catch Error.walletAlreadyExists {
                    completion(nil, Error.walletAlreadyExists)
                    return
                } catch {
                    completion(nil, Error.keystoreFileSaveFailed)
                    return
                }
                completion(wallet, nil)
            })
        }
    }
    
    /// exportPrivateKey
    public func exportPrivateKey(wallet: Wallet, password: String, completion: @escaping (String?, Error?) -> Void) {
        var keystore: Keystore!
        var parentWallet: Wallet!
         if wallet.depth == 0 {
            // 普通钱包或HD母钱包
            keystore = wallet.key!
        } else if wallet.depth == 1 && wallet.isHD == true {
            // HD子钱包
            parentWallet = WalletService.sharedInstance.getWallet(byUUID: wallet.parentId!)
            keystore = parentWallet!.key!
        } else {
            // HD母钱包，不能导出私钥
            completion(nil, Error.invalidWallet)
            return
        }
        let isHD = wallet.isHD
        let pathIndex = wallet.pathIndex
        walletQueue.async {
            var privateKeyData: Data!
            guard let tmpPrivateKeyData = try? keystore.decrypt(password: password) else {
                DispatchQueue.main.async {
                    completion(nil, Error.invalidWalletPassword)
                }
                return
            }
            if isHD == true && parentWallet != nil {
                let mnemonic = try! keystore.decrypt(encryptedMnemonic: parentWallet!.mnemonic, password: password)
                let seed = WalletUtil.seedFromMnemonic(mnemonic, passphrase: "")
                let hdNode = WalletUtil.hdNodeFromSeed(seed)
                keystore.hdNode = hdNode
                privateKeyData = keystore.generateHDSubPrivateKey(index: pathIndex)
            } else {
                privateKeyData = tmpPrivateKeyData
            }
            guard WalletUtil.isValidPrivateKeyData(privateKeyData) else {
                completion(nil, Error.invalidKey)
                return
            }
            DispatchQueue.main.async {
                let res = privateKeyData.toHexString()
                print("🔑privateKey:\(res)")
                completion(res, nil)
            }
        }
    }

    /// exportKeystoreFile
    public func exportKeystore(wallet: Wallet, password: String = "") -> (keystore:String?, error:Error?) {

//        guard var keystore = wallet.key else {
//            return (nil, Error.invalidWallet)
//        }
        var keystore: Keystore!
        if wallet.depth == 0 && wallet.isHD == false {
            // 普通钱包
            keystore = wallet.key!
        } else if wallet.depth == 1 && wallet.isHD == true {
            // HD子钱包
            let parentWallet = WalletService.sharedInstance.getWallet(byUUID: wallet.parentId!)
            var parentKeystore = parentWallet!.key!
            let mnemonic = try! parentKeystore.decrypt(encryptedMnemonic: parentWallet!.mnemonic, password: password)
            let seed = WalletUtil.seedFromMnemonic(mnemonic, passphrase: "")
            let hdNode = WalletUtil.hdNodeFromSeed(seed)
            parentKeystore.hdNode = hdNode
            let privateKeyData = parentKeystore.generateHDSubPrivateKey(index: wallet.pathIndex)
            guard let key = try? Keystore(password: password, privateKey: privateKeyData) else {
                return (nil, Error.keystoreGeneFailed)
            }
            keystore = key
        } else {
            return (nil, Error.invalidWallet)
        }
        let tempPublicKey = keystore.publicKey
        keystore.publicKey = nil
        guard let keystoreJson = String(bytes: try! JSONEncoder().encode(keystore), encoding: .utf8) else {
            return (nil, Error.invalidWallet)
        }
        keystore.publicKey = tempPublicKey
        return (keystoreJson, nil)
    }

    public func exportMnemonic(wallet: Wallet, password: String, completion: @escaping (String?, Error?) -> Void) {
        guard let keystore = wallet.key else {
            completion(nil, Error.invalidWallet)
            return
        }
        let encryptedMnemonic = wallet.keystoreMnemonic
        guard encryptedMnemonic.count > 0 else {
            completion(nil, Error.invalidMnemonic)
            return
        }
        walletQueue.async {
            guard let mnemonic = try? keystore.decrypt(encryptedMnemonic: encryptedMnemonic, password: password) else {
                completion(nil, Error.invalidWalletPassword)
                return
            }
            DispatchQueue.main.async {
                completion(mnemonic, nil)
            }
        }
    }

    public func afterBackupMnemonic(wallet: Wallet, complete: (() -> Void)? = nil) {
        wallet.isBackup = true
        WallletPersistence.sharedInstance.updateWalletBackupStatus(wallet: wallet, isBackup: true, complete: complete)

//        guard var keystore = wallet.key else {
//            return
//        }
//        keystore.mnemonic = nil
//        guard let json = try? JSONEncoder().encode(keystore) else {
//            return
//        }
//        let fileURL = keystoreFolderURL.appendingPathComponent(wallet.keystorePath)
//        try? json.write(to: fileURL, options: [.atomicWrite])
//
//        let w = wallets.first { (item) -> Bool in
//            item.uuid == wallet.uuid
//        }
//        w?.key?.mnemonic = nil
    }

    public func deleteWallet(_ wallet:Wallet, shouldCleanParentWalletFinally: Bool = true, complete: (() -> Void)? = nil) {
        /*
        NotificationCenter.default.post(name: Notification.Name.ATON.WillDeleateWallet, object: wallet)
        wallets.removeAll(where: { $0.uuid == wallet.uuid})
        AssetVCSharedData.sharedData.willDeleteWallet(object: wallet as AnyObject)
         */
        NotificationCenter.default.post(name: Notification.Name.ATON.WillDeleateWallet, object: wallet)
        AssetService.sharedInstace.balances = AssetService.sharedInstace.balances.filter { $0.addr.lowercased() != wallet.address.lowercased() }
        WallletPersistence.sharedInstance.delete(wallet: wallet) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.refreshDB()
                // 保持AssetVCSharedData监听有效
                AssetVCSharedData.sharedData.active()
                complete?()
                NotificationCenter.default.post(name: Notification.Name.ATON.updateWalletList, object: wallet)
            }
        }
        /// 当母钱包没有了子钱包，则删除母钱包
        if let parentWallet = WalletHelper.fetchParentWallet(from: wallet), shouldCleanParentWalletFinally == true {
            self.removeWallet(wallet: wallet, fromParent: parentWallet)
            if parentWallet.subWallets.count == 0 {
                self.deleteWallet(parentWallet)
            }
        }
    }
    
    /// 删除某个钱包的子钱包
    public func deleteSubWallets(_ wallet:Wallet, complete: (() -> Void)? = nil) {
        AssetService.sharedInstace.balances = AssetService.sharedInstace.balances.filter { $0.addr.lowercased() != wallet.address.lowercased() }
        WallletPersistence.sharedInstance.deleteSubWallets(wallet: wallet) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                complete?()
            }
        }
    }
    
    /// 删除钱包并确认是否删除子钱包
    public func deleteWallet(_ wallet:Wallet ,shouldDeleteSubWallet: Bool, complete: (() -> Void)? = nil) {
        NotificationCenter.default.post(name: Notification.Name.ATON.WillDeleateWallet, object: wallet)
        AssetService.sharedInstace.balances = AssetService.sharedInstace.balances.filter { $0.addr.lowercased() != wallet.address.lowercased() }
        self.deleteSubWallets(wallet) {
            WallletPersistence.sharedInstance.delete(wallet: wallet) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.refreshDB()
                    // 保持AssetVCSharedData监听有效
                    AssetVCSharedData.sharedData.active()
                    complete?()
                    NotificationCenter.default.post(name: Notification.Name.ATON.updateWalletList, object: wallet)
                }
            }
        }
    }
    
    /// 从一个母钱包中移除子钱包（若是最后一个子钱包被删除，母钱包也会被删除）
    private func removeWallet(wallet: Wallet, fromParent parentWallet: Wallet) {
        // 反向遍历母钱包
        for (i, v) in parentWallet.subWallets.enumerated().reversed() {
            if wallet.uuid == v.uuid {
                parentWallet.subWallets.remove(at: i)
                if parentWallet.selectedIndex == v.pathIndex {
                    // 若删除的正好是母钱包中选中的这个子钱包，需要调整选中的索引值
                    if let firstPathIndex = parentWallet.subWallets.first?.pathIndex {
                        // 还有子钱包
                        parentWallet.selectedIndex = firstPathIndex
                    } else {
                        // 没有子钱包
                        parentWallet.selectedIndex = 0
//                        WalletService.sharedInstance.wallets.removeAll()
                        if WalletService.sharedInstance.wallets.contains(parentWallet) {
                            WalletService.sharedInstance.deleteWallet(parentWallet)
                        }
                    }
                    // 重新设定母钱包的索引值
                    WalletService.sharedInstance.updateWalletSelectedIndex(parentWallet, selectedIndex: parentWallet.selectedIndex)
                    /// 强制刷新
                    AssetVCSharedData.sharedData.active()
                }
            }
        }
    }
    


    public func updateWalletName(_ wallet: Wallet, name: String) {
        WallletPersistence.sharedInstance.updateWalletName(wallet: wallet, name: name)
    }

    public func updateWalletBalance(_ wallet: Wallet, balance: String) {
        WallletPersistence.sharedInstance.updateWalletBalance(wallet: wallet, balance: balance)
    }

    public func updateWalletLockedBalance(_ wallet: Wallet, value: String) {
        WallletPersistence.sharedInstance.updateWalletLockedBalance(wallet: wallet, value: value)
    }
    
    public func updateWalletSelectedIndex(_ wallet: Wallet, selectedIndex: Int, complete: (() -> Void)? = nil) {
        WallletPersistence.sharedInstance.updateWalletSelectedIndex(wallet: wallet, selectedIndex: selectedIndex) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                complete?()
            }
        }
    }

    /// Generates a unique file name for an address.
    func generateFileName(identifier: String, date: Date = Date(), timeZone: TimeZone = .current) -> String {
        // keyFileName implements the naming convention for keyfiles:
        // UTC--<created_at UTC ISO8601>-<address hex>
        return "UTC--\(filenameTimestamp(for: date, in: timeZone))--\(identifier)"
    }

    private func filenameTimestamp(for date: Date, in timeZone: TimeZone = .current) -> String {
        var tz = ""
        let offset = timeZone.secondsFromGMT()
        if offset == 0 {
            tz = "Z"
        } else {
            tz = String(format: "%03d00", offset/60)
        }

        let components = Calendar(identifier: .iso8601).dateComponents(in: timeZone, from: date)
        return String(format: "%04d-%02d-%02dT%02d-%02d-%02d.%09d%@", components.year!, components.month!, components.day!, components.hour!, components.minute!, components.second!, components.nanosecond!, tz)
    }

    private func saveObservedWalletToDB(wallet: Wallet) throws {
        let sameUuidWallet = wallets.first { (item) -> Bool in
            item.uuid == wallet.uuid
        }

        if sameUuidWallet != nil {
            throw Error.walletAlreadyExists
        }

        WallletPersistence.sharedInstance.save(wallet: wallet)

        wallets.removeAll { (item) -> Bool in
            item.uuid == wallet.uuid
        }

        wallets.append(wallet)
    }

    private func saveToDB(wallet: Wallet, subWallets: [Wallet]? = nil) throws {

        guard let keystore = wallet.key else {
            throw Error.invalidWallet
        }

        let sameUuidWallet = wallets.first { (item) -> Bool in
            (item.uuid == wallet.uuid) || (item.address.lowercased() == wallet.address.lowercased())
        }

        if sameUuidWallet != nil {
            throw Error.walletAlreadyExists
        }

        let fileName = generateFileName(identifier: "\(keystore.address).json")

        let fileURL = keystoreFolderURL.appendingPathComponent(fileName)

        let json = try JSONEncoder().encode(keystore)
        do {
            try json.write(to: fileURL, options: [.atomicWrite])
        } catch {
            throw WalletService.Error.keystoreFileSaveFailed
        }

        /*
        if var paths = FileManager.default.subpaths(atPath: keystoreFolderPath) {
            paths.removeAll { (p) -> Bool in
                p == fileName
            }
            for path in paths {
                if String(path.split(separator: "-").last!) == "\(keystore.address).json" {
                    try FileManager.default.removeItem(at: keystoreFolderURL.appendingPathComponent(path))
                }
            }
        }
    */

        wallet.keystorePath = fileName
        wallet.mnemonic = keystore.mnemonic ?? ""

        WallletPersistence.sharedInstance.save(wallet: wallet, subWallets: subWallets)

        wallets.removeAll { (item) -> Bool in
            item.uuid == wallet.uuid
        }

        wallets.append(wallet)

    }

}

extension WalletService {
    public enum Error: Swift.Error, LocalizedError {
        case invalidWalletName
        case invalidWalletPassword
        case keystoreGeneFailed
        case keystoreFileSaveFailed
        case walletAlreadyExists
        case accountNotFound
        case invalidMnemonic
        case invalidKey
        case invalidKeystore
        case invalidWallet
        case invalidAddress

        public var errorDescription: String? {
            switch self {
            case .invalidWalletName:
                return nil
            case .invalidWalletPassword:
                return Localized("Invalid password")
            case .keystoreGeneFailed:
                return nil
            case .keystoreFileSaveFailed:
                return nil
            case .invalidWallet:
                return Localized("Invalid wallet")
            case .walletAlreadyExists:
                return Localized("Wallet already exists")
            case .accountNotFound:
                return Localized("Account not found")
            case .invalidMnemonic:
                return Localized("Invalid mnemonic phrase")
            case .invalidKey:
                return Localized("Invalid private key")
            case .invalidKeystore:
                return Localized("Invalid keystore")
            case .invalidAddress:
                return Localized("Invalid address")
            }
        }
    }
}
