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

let keystoreFolderPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/keystore"

public final class WalletService {
    
    let keystoreFolderURL : URL
    
    var walletStorge: WallletPersistence! {
        didSet {
            wallets = walletStorge.getAll()
            for item in wallets {
                item.key = try? Keystore(contentsOf: URL(fileURLWithPath: keystoreFolderPath + "/\(item.keystorePath)"))
            }
        }
    }
    
    public private(set) var wallets = [Wallet]()
    
    static let sharedInstance = WalletService()
    
    let walletQueue = DispatchQueue(label: "com.ju.walletServiceQueue", qos: .userInitiated, attributes: .concurrent)
    
    
    private init() {
        
        keystoreFolderURL = URL(fileURLWithPath: keystoreFolderPath)
        
        print("📁keystoreFloderURL:\(keystoreFolderURL.absoluteString)")
        
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: keystoreFolderPath) {
            try! fileManager.createDirectory(at: keystoreFolderURL, withIntermediateDirectories: false, attributes: nil)
        }
        
    }
    
    func getWalletByAddress(address: String) -> Wallet?{

        for item in wallets{
            if (item.key?.address.ishexStringEqual(other: address))!{

                return item
            }
        }
        return nil
    }
    
    /// Create Wallet
    ///
    /// - Parameters:
    ///   - name: <#name description#>
    ///   - password: <#password description#>
    ///   - completion: <#completion description#>
    public func createWallet(name:String, password: String, completion: @escaping (Wallet?, Error?) -> Void) {
        
        walletQueue.async {
            
            guard let keystore = try? Keystore(password: password) else {
                DispatchQueue.main.sync {
                    completion(nil, Error.keystoreGeneFailed)
                }
                return
            }
            
            let wallet = Wallet(name: name, keystoreObject: keystore)
            
            DispatchQueue.main.async {
                
                do{
                    try self.saveToDB(wallet: wallet)
                }catch {
                    completion(nil, Error.keystoreFileSaveFailed)
                }
                
                completion(wallet, nil)
            }
            
        }
        
    }
    
    /// importWalletFromMnemonic
    ///
    /// - Parameters:
    ///   - mnemonic: <#mnemonic description#>
    ///   - passphrase: <#passphrase description#>
    ///   - walletName: <#walletName description#>
    ///   - walletPassword: <#walletPassword description#>
    ///   - completion: <#completion description#>
    public func `import`(mnemonic: String ,passphrase: String = "", walletName: String, walletPassword: String, completion: @escaping (Wallet?, Error?) -> Void) {
        
        guard WalletUtil.isValidMnemonic(mnemonic) else {
            completion(nil, Error.invalidMnemonic)
            return
        } 
        
        walletQueue.async {
            
            guard let keystore = try? Keystore(password: walletPassword, mnemonic: mnemonic) else {
                DispatchQueue.main.async {
                    completion(nil, Error.keystoreGeneFailed)
                }
                return
            }
            
            let wallet = Wallet(name: walletName, keystoreObject: keystore)
            
            DispatchQueue.main.async {
                
                do{
                    try self.saveToDB(wallet: wallet)
                }catch Error.walletAlreadyExists {
                    completion(nil, Error.walletAlreadyExists)
                    return
                }catch {
                    completion(nil, Error.keystoreFileSaveFailed)
                    return
                }
                
                completion(wallet, nil)
            }
            
        }
        
    }
    
    
    /// importWalletFromPrivateKey
    ///
    /// - Parameters:
    ///   - privateKey: <#privateKey description#>
    ///   - walletName: <#walletName description#>
    ///   - walletPassword: <#walletPassword description#>
    /// - Returns: <#return value description#>
    /// - Throws: <#throws value description#>
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
            
            let wallet = Wallet(name: walletName, keystoreObject: keystore)
            
            DispatchQueue.main.async {
                
                do{
                    try self.saveToDB(wallet: wallet)
                }catch Error.walletAlreadyExists {
                    completion(nil, Error.walletAlreadyExists)
                    return
                }catch {
                    completion(nil, Error.keystoreFileSaveFailed)
                    return
                }
                
                completion(wallet, nil)
            }
            
        }
        
    }
    
    
    /// importWalletFromKeystoreFile
    ///
    /// - Parameters:
    ///   - keystore: <#keystore description#>
    ///   - walletName: <#walletName description#>
    ///   - password: <#password description#>
    /// - Returns: <#return value description#>
    /// - Throws: <#throws value description#>
    public func `import`(keystore: String, walletName: String, password: String, completion: @escaping (Wallet?, Error?) -> Void) {
        
        guard let keystoreObj = try? JSONDecoder().decode(Keystore.self, from: keystore.data(using: .utf8)!) else {
            
            completion(nil, Error.invalidKeystore)
            return
        }
        
        walletQueue.async {
            
            let wallet = Wallet(name: walletName, keystoreObject: keystoreObj)
            
            self.exportPrivateKey(wallet: wallet, password: password, completion: { (privateKey, error) in
                
                if error != nil && privateKey == nil {
                    completion(nil, error)
                    return
                }
                
                wallet.updateInfoFromPrivateKey(privateKey!)
                
                do{
                    try self.saveToDB(wallet: wallet)
                    
                }catch Error.walletAlreadyExists {
                    completion(nil, Error.walletAlreadyExists)
                    return
                }catch {
                    completion(nil, Error.keystoreFileSaveFailed)
                    return
                }
                
                completion(wallet, nil)
                
            })
            
        }
        
    }
    
    
    /// exportPrivateKey
    ///
    /// - Parameters:
    ///   - wallet: <#wallet description#>
    ///   - password: <#password description#>
    /// - Returns: <#return value description#>
    /// - Throws: <#throws value description#>
    public func exportPrivateKey(wallet: Wallet, password: String, completion: @escaping (String?, Error?) -> Void) {
        
        guard let keystore = wallet.key else {
            completion(nil, Error.invalidWallet)
            return
        }
        
        walletQueue.async {
            
            guard let privateKeyData = try? keystore.decrypt(password: password) else {
                
                DispatchQueue.main.async {
                    completion(nil, Error.invalidWalletPassword)
                }
                return
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
    ///
    /// - Parameters:
    ///   - wallet: <#wallet description#>
    ///   - password: <#password description#>
    /// - Returns: <#return value description#>
    /// - Throws: <#throws value description#>
    public func exportKeystore(wallet: Wallet, password: String = "") -> (keystore:String?, error:Error?) {
        
        guard var keystore = wallet.key else {
            return (nil, Error.invalidWallet)
        }
        
//        var privateData: Data
//        do {
//            privateData = try keystore.decrypt(password: password)
//        } catch  {
//            throw Error.invalidWalletPassword
//        }
//        
//        guard WalletUtil.isValidPrivateKeyData(privateData) else {
//            throw Error.invalidKey
//        }
        let tempPublicKey = keystore.publicKey
        keystore.publicKey = nil
//        let tempMnemonic = keystore.mnemonic
//        keystore.mnemonic = nil
        guard let keystoreJson = String(bytes: try! JSONEncoder().encode(keystore), encoding: .utf8) else { return (nil, Error.invalidWallet) }
        keystore.publicKey = tempPublicKey
//        keystore.mnemonic = tempMnemonic
        return (keystoreJson, nil)
    }
    
    public func exportMnemonic(wallet: Wallet, password: String, completion: @escaping (String?, Error?) -> Void) {
        
        guard let keystore = wallet.key else {
            completion(nil, Error.invalidWallet)
            return
        }
        guard let encryptedMnemonic = keystore.mnemonic else {
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
    
    public func afterBackupMnemonic(wallet: Wallet) {
        guard var keystore = wallet.key else {
            return
        }
        keystore.mnemonic = nil
        guard let json = try? JSONEncoder().encode(keystore) else {
            return
        }
        let fileURL = keystoreFolderURL.appendingPathComponent(wallet.keystorePath)
        try? json.write(to: fileURL, options: [.atomicWrite])
        
        let w = wallets.first { (item) -> Bool in
            item.uuid == wallet.uuid
        }
        w?.key?.mnemonic = nil
        
    }
    
    public func deleteWallet(_ wallet:Wallet) {
        
        NotificationCenter.default.post(name: NSNotification.Name(WillDeleateWallet_Notification), object: wallet)
        
        AssetService.sharedInstace.assets.removeValue(forKey: (wallet.key?.address)!)
        
        wallets.removeAll { (item) -> Bool in
            return item == wallet
        }
        walletStorge.delete(wallet: wallet)
        //issue mutiply thread access wallet object?
        if let selectedWallet = AssetVCSharedData.sharedData.selectedWallet as? Wallet{
            if (selectedWallet.key?.address.ishexStringEqual(other: wallet.key?.address))!{
                AssetVCSharedData.sharedData.selectedWallet = nil
            }
        } 
        
        //delete associated shared wallets
        SWalletService.sharedInstance.willOwnerWalletBeingDelete(ownerWallet: wallet)
        
    }
    
    public func updateWalletName(_ wallet: Wallet, name: String) {

        walletStorge.updateWalletName(wallet: wallet, name: name)
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
    
    private func saveToDB(wallet: Wallet) throws {
        
        guard let keystore = wallet.key else { 
            throw Error.invalidWallet
        }
        
        let sameUuidWallet = wallets.first { (item) -> Bool in
            item.uuid == wallet.uuid
        }
        
        if sameUuidWallet != nil {
            throw Error.walletAlreadyExists
        }
        
        let fileName = generateFileName(identifier: "\(keystore.address).json")
        
        let fileURL = keystoreFolderURL.appendingPathComponent(fileName)
        
        let json = try JSONEncoder().encode(keystore)
        do {
            try json.write(to: fileURL, options: [.atomicWrite])
        } catch  {
            throw WalletService.Error.keystoreFileSaveFailed
        }
        
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

        wallet.keystorePath = fileName
        
        guard walletStorge != nil else {
            fatalError("walletStorge must not be nil!")
        }
        
        walletStorge.save(wallet: wallet)
        
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
            }
        }
    }
}
