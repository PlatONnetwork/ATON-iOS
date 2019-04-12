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
    
    public static func doNodeULRStringMigration(_ old: MigrationObject?, _ new: MigrationObject?){
        if old != nil && new != nil{
            if let emptyURLString = old!["nodeURLStr"] as? String,emptyURLString == ""{
                new!["nodeURLStr"] = DefaultAlphaNodeURL
            }
        }
    }
}
