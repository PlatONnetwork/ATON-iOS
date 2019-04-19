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
 
//var RealmWriteQueue = DispatchQueue(label: "com.platon.RealmWriteQueue")
//var RealmReadeQueue = DispatchQueue(label: "com.platon.RealmReadQueue")

var RealmWriteQueue = DispatchQueue(label: "com.platon.RealmWriteQueue", qos: .userInitiated, attributes: .concurrent)
var RealmReadeQueue = DispatchQueue(label: "com.platon.RealmReadQueue", qos: .userInitiated, attributes: .concurrent)

class RealmHelper {
    
    private static var defaultRealm : Realm?
    
    public static var readInstance : Realm?
    
    public static var writeInstance : Realm?
    
    public class func getRealm() -> Realm?{
        return defaultRealm
    }
    
    public class func initReadRealm(){
        RealmReadeQueue.async {
            readInstance = try? Realm(configuration: self.getConfig())
        }
    }
    
    public class func initWriteRealm(){
        RealmWriteQueue.async {
            writeInstance = try? Realm(configuration: self.getConfig()) 
        }
    }
    
    public class func getNewRealm() -> Realm{
        let realm = try? Realm(configuration: self.getConfig())
        return realm!
    }
    
    public static func setDefaultInstance(r: Realm?){
        defaultRealm = r
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
                self.migrationBelow4(migration: migration, schemaVersion: schemaVersion, oldSchemaVersion: oldSchemaVersion)
            }
            
            if oldSchemaVersion < 6{ 
                RealmHelper.migrationBelow6(migration: migration, schemaVersion: schemaVersion, oldSchemaVersion: oldSchemaVersion)
            }
            
            
        })
        
        return config
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

