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


class RealmHelper {
    public static var r : Realm?
    public class func getRealm() -> Realm?{
        return r
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
    
    public static func doNodeULRStringMigration_4_to_6(_ old: MigrationObject?, _ new: MigrationObject?){
        if old != nil && new != nil{
            new!["nodeURLStr"] = DefaultAlphaNodeURL
        }
    }
    
    public static func classicwalletdoPrimaryKeyMigration_4_to_6(_ old: MigrationObject?, _ new: MigrationObject?){
        if old != nil && new != nil{
            let path = old!["keystorePath"] as? String
            let keystore = try? Keystore(contentsOf: URL(fileURLWithPath: keystoreFolderPath + "/" + path!))
            if (path != nil && keystore != nil){
                new!["primaryKeyIdentifier"] = keystore!.address + DefaultAlphaNodeURL
            }
        }
    }
    
}
