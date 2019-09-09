//
//  MigrateBelow6.swift
//  platonWallet
//
//  Created by Ned on 2019/4/17.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import RealmSwift

extension RealmHelper{
    
    public static func migrationBelow71(migration: Migration,schemaVersion: UInt64, oldSchemaVersion: UInt64){
        migration.renameProperty(onType: DelegateDetailDel.className(), from: "stakingBlockNum", to: "delegationBlockNum")
    }
    
    public static func migrationBelow7(migration: Migration,schemaVersion: UInt64, oldSchemaVersion: UInt64){
        migration.enumerateObjects(ofType: Wallet.className(), { (old, new) in
            RealmHelper.doNodeULRStringMigration_below_7(old, new)
            RealmHelper.classicwalletdoPrimaryKeyMigration_below_7(old, new)
        })
        migration.deleteData(forType: NodeInfo.className())
        
        migration.enumerateObjects(ofType: Transaction.className()) { (old, new) in
            if old != nil && new != nil{
                if let nodeURL = old!["nodeURLStr"] as? String, nodeURL == AppConfig.NodeURL.DefaultNodeURL_Alpha {
                    new!["nodeURLStr"] = AppConfig.NodeURL.DefaultNodeURL_Alpha_V071
                }
            }
        }
    }
    
    public static func migrationBelow6(migration: Migration,schemaVersion: UInt64, oldSchemaVersion: UInt64){
        
        migration.enumerateObjects(ofType: Wallet.className(), { (old, new) in
            RealmHelper.doNodeULRStringMigration_below_6(old, new)
            RealmHelper.classicwalletdoPrimaryKeyMigration_below_6(old, new)
        })
        
        /*
        migration.enumerateObjects(ofType: AddressInfo.className(), { (old, new) in
            RealmHelper.doNodeULRStringMigration_below_6(old, new)
        })
        
        migration.enumerateObjects(ofType: Transaction.className(), { (old, new) in  
            RealmHelper.doNodeULRStringMigration_below_6(old, new)
        })
        
        migration.enumerateObjects(ofType: SWallet.className(), { (old, new) in
            RealmHelper.doNodeULRStringMigration_below_6(old, new)
        })
        
        migration.deleteData(forType: SWallet.className())
        
        migration.enumerateObjects(ofType: STransaction.className(), { (old, new) in
            RealmHelper.doNodeULRStringMigration_below_6(old, new)
        })
        */
        
        //migration.deleteData(forType: AddressInfo.className())
        migration.deleteData(forType: Transaction.className())
        migration.deleteData(forType: SWallet.className())
        migration.deleteData(forType: STransaction.className())
        
        migration.enumerateObjects(ofType: NodeInfo.className()) { (old, new) in
            if old != nil && new != nil{
                if let nodeURL = old!["nodeURLStr"] as? String, nodeURL == AppConfig.NodeURL.DefaultNodeURL_Alpha_deprecated{
                    new!["nodeURLStr"] = AppConfig.NodeURL.DefaultNodeURL_Alpha
                    new!["desc"] = "SettingsVC_nodeSet_defaultTestNetwork_Amigo_des"
                }
            }
            
        } 
    }
    
    public static func doNodeULRStringMigration_below_7(_ old: MigrationObject?, _ new: MigrationObject?){
        if old != nil && new != nil{
            new!["nodeURLStr"] = AppConfig.NodeURL.DefaultNodeURL_Alpha_V071
        }
    }
    
    public static func classicwalletdoPrimaryKeyMigration_below_7(_ old: MigrationObject?, _ new: MigrationObject?){
        if old != nil && new != nil{
            let path = old!["keystorePath"] as? String
            let keystore = try? Keystore(contentsOf: URL(fileURLWithPath: keystoreFolderPath + "/" + path!))
            if (path != nil && keystore != nil){
                new!["primaryKeyIdentifier"] = keystore!.address + AppConfig.NodeURL.DefaultNodeURL_Alpha_V071
            }
        }
    }
    
    
    public static func doNodeULRStringMigration_below_6(_ old: MigrationObject?, _ new: MigrationObject?){
        if old != nil && new != nil{
            new!["nodeURLStr"] = AppConfig.NodeURL.DefaultNodeURL_Alpha
        }
    }
    
    public static func classicwalletdoPrimaryKeyMigration_below_6(_ old: MigrationObject?, _ new: MigrationObject?){
        if old != nil && new != nil{
            let path = old!["keystorePath"] as? String
            let keystore = try? Keystore(contentsOf: URL(fileURLWithPath: keystoreFolderPath + "/" + path!))
            if (path != nil && keystore != nil){
                new!["primaryKeyIdentifier"] = keystore!.address + AppConfig.NodeURL.DefaultNodeURL_Alpha
            }
        }
    }
}
