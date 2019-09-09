//
//  MigrateBelow4.swift
//  platonWallet
//
//  Created by Ned on 2019/4/17.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import RealmSwift

extension RealmHelper{
    
    public static func migrationBelow4(migration: Migration,schemaVersion: UInt64, oldSchemaVersion: UInt64){
        migration.enumerateObjects(ofType: NodeInfo.className(), { (old, new) in
            if old != nil && new != nil{
                if old!["nodeURLStr"] as! String == AppConfig.NodeURL.DefaultNodeURL_Alpha_deprecated {
                    new!["desc"] = "SettingsVC_nodeSet_defaultTestNetwork_title"
                    
                }else if old!["nodeURLStr"] as! String == "192.168.9.73:6789" && old?["desc"] as? String == "SettingsVC_nodeSet_defaultTestNetwork_title"{
                    migration.delete(old!)
                }
            }
            
        })
    }
}
