//
//  RealmHelper.swift
//  platonWallet
//
//  Created by matrixelement on 19/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import RealmSwift

public let RealmInstance = RealmHelper.getRealm()
 
var RealmWriteQueue = DispatchQueue(label: "com.platon.RealmWriteQueue")

class RealmHelper {
    
    private static var readInstance : Realm?
    private static var writeInstance : Realm?
    

    
    public class func getRealm() -> Realm?{
        return readInstance
    }
    
    public class func getWriteRealm() -> Realm{
        let realm = try? Realm(configuration: self.getConfig())
        return realm!
    }
    
    public static func setReadInstance(r: Realm?){
        readInstance = r
    }
    
    public static func seWriteInstance(r: Realm?){
        writeInstance = r
    }
    
    /*
    public class func getRealm() -> Realm{
        let docPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as String
        let dbPath = docPath.appending("/defaultDB.realm")
        NSLog("realm path is \(dbPath)")
        let defaultRealm = try! Realm(fileURL: URL.init(string: dbPath)!)
        return defaultRealm
    }
     */
    
    
    public class func getConfig() -> Realm.Configuration{
        //v0.6.0 update scheme version to 6
        let schemaVersion: UInt64 = 6
        let config = Realm.Configuration(schemaVersion: schemaVersion, migrationBlock: { migration, oldSchemaVersion in
            
            if oldSchemaVersion < 4 {
                
                migration.enumerateObjects(ofType: NodeInfo.className(), { (old, new) in
                    if old != nil && new != nil{
                        if old!["nodeURLStr"] as! String == DefaultNodeURL_Alpha {
                            new!["desc"] = "SettingsVC_nodeSet_defaultTestNetwork_title"
                            
                        }else if old!["nodeURLStr"] as! String == "192.168.9.73:6789" && old?["desc"] as? String == "SettingsVC_nodeSet_defaultTestNetwork_title"{
                            migration.delete(old!)
                        }
                    }
                    
                }) 
            }
            
            if oldSchemaVersion < 6{ 
                migration.enumerateObjects(ofType: Transaction.className(), { (old, new) in  
                    RealmHelper.doNodeULRStringMigration_below_6(old, new)
                })
                
                migration.enumerateObjects(ofType: Wallet.className(), { (old, new) in
                    RealmHelper.doNodeULRStringMigration_below_6(old, new)
                    RealmHelper.classicwalletdoPrimaryKeyMigration_below_6(old, new)
                })
                
                migration.enumerateObjects(ofType: AddressInfo.className(), { (old, new) in
                    RealmHelper.doNodeULRStringMigration_below_6(old, new)
                })
                
                migration.enumerateObjects(ofType: SWallet.className(), { (old, new) in
                    RealmHelper.doNodeULRStringMigration_below_6(old, new)
                })
                
                migration.enumerateObjects(ofType: STransaction.className(), { (old, new) in
                    RealmHelper.doNodeULRStringMigration_below_6(old, new)
                })
                
            }
            
            
        })
        
        return config
    }
    
    public static func doNodeULRStringMigration_below_6(_ old: MigrationObject?, _ new: MigrationObject?){
        if old != nil && new != nil{
            new!["nodeURLStr"] = DefaultNodeURL_Alpha
        }
    }
    
    public static func classicwalletdoPrimaryKeyMigration_below_6(_ old: MigrationObject?, _ new: MigrationObject?){
        if old != nil && new != nil{
            let path = old!["keystorePath"] as? String
            let keystore = try? Keystore(contentsOf: URL(fileURLWithPath: keystoreFolderPath + "/" + path!))
            if (path != nil && keystore != nil){
                new!["primaryKeyIdentifier"] = keystore!.address + DefaultNodeURL_Alpha
            }
        }
    }
    
}


public extension Object {
    
    public func detached() -> Self {
        
        let detached = type(of: self).init()
        for property in objectSchema.properties {
            guard let value = value(forKey: property.name) else { continue }
            if let detachable = value as? Object {
                detached.setValue(detachable.detached(), forKey: property.name)
            } else {
                detached.setValue(value, forKey: property.name)
            }
        }
        return detached
    }
    
}

public extension Sequence where Iterator.Element:Object  {
    
    public var detached:[Element] {
        return self.map({ $0.detached() })
    }
    
}

