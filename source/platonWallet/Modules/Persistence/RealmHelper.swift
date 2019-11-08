//
//  RealmHelper.swift
//  platonWallet
//
//  Created by matrixelement on 19/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import RealmSwift

var RealmWriteQueue = DispatchQueue(label: "com.platon.RealmWriteQueue", qos: .userInitiated, attributes: .concurrent)

class RealmHelper {

    public static var writeInstance : Realm?

    public class func initWriteRealm() {
        RealmWriteQueue.async {
//            writeInstance = try? Realm(configuration: self.getConfig())
//            print("init write instance")
//            completion(writeInstance != nil)
        }
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

    public class func getConfig() -> Realm.Configuration {
        //v0.7.0 update scheme version to 8
        let schemaVersion: UInt64 = 25

        let config = Realm.Configuration(schemaVersion: schemaVersion, migrationBlock: { migration, oldSchemaVersion in
            if oldSchemaVersion < 23 {
                migrationBelow073(migration: migration, schemaVersion: schemaVersion, oldSchemaVersion: oldSchemaVersion)
            }

            if oldSchemaVersion < 24 {
                migrationBelow0731(migration: migration, schemaVersion: schemaVersion, oldSchemaVersion: oldSchemaVersion)
            }

            if oldSchemaVersion < 25 {
                migrationBelow0732(migration: migration, schemaVersion: schemaVersion, oldSchemaVersion: oldSchemaVersion)
            }
        },shouldCompactOnLaunch: {(totalBytes, usedBytes) in
            //set db max size as 500M
            let oneHundredMB = 500 * 1024 * 1024
            return (totalBytes > oneHundredMB) && (Double(usedBytes) / Double(totalBytes)) < 0.5
        })
        return config
    }

}

public extension Object {

    func detached() -> Self {

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

public extension Sequence where Iterator.Element:Object {

    var detached:[Element] {
        return self.map({ $0.detached() })
    }

}
