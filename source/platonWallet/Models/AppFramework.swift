//
//  AppFramework.swift
//  platonWallet
//
//  Created by matrixelement on 19/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import Localize_Swift
import RealmSwift
import BigInt
import Bugly
import platonWeb3

class AppFramework {
    
    static let sharedInstance = AppFramework()
    
    func initialize(){
        languageSetting()
        RealmConfiguration()
        modulesConfigure()
        initBugly()
        doSwizzle()
    }
    
    func initweb3(){
        Debugger.enableDebug(true)
    }
    
    func initBugly(){
        Bugly.start(withAppId: "e8f57be7d2")
    }
        
    
    func modulesConfigure(){
        let _ = AssetService.sharedInstace
        let _ = TransactionService.service
    }
     
    func languageSetting() {
        
        let defaullt = UserDefaults.standard.object(forKey: "LCLCurrentLanguageKey")
        if  defaullt == nil {
            let curlan = GetCurrentSystemSettingLanguage()
            if curlan == "cn"{
                Localize.setCurrentLanguage("zh-Hans")
            }else{
                Localize.setCurrentLanguage("en")
            }
        }
        
    }
    
    func RealmConfiguration() { 
        //v0.6.0 update scheme version to 6
        let schemaVersion: UInt64 = 6
        let config = Realm.Configuration(schemaVersion: schemaVersion, migrationBlock: { migration, oldSchemaVersion in
         
            if oldSchemaVersion < 4 {

                migration.enumerateObjects(ofType: NodeInfo.className(), { (old, new) in
                    if old != nil && new != nil{
                        if old!["nodeURLStr"] as! String == DefaultAlphaNodeURL {
                            new!["desc"] = "SettingsVC_nodeSet_defaultTestNetwork_title"
                            
                        }else if old!["nodeURLStr"] as! String == "192.168.9.73:6789" && old?["desc"] as? String == "SettingsVC_nodeSet_defaultTestNetwork_title"{
                            migration.delete(old!)
                        }
                    }
                    
                }) 
            }
            
            if oldSchemaVersion < 6{ 
                migration.enumerateObjects(ofType: Transaction.className(), { (old, new) in
                    RealmHelper.doNodeULRStringMigration_4_to_6(old, new)
                })
                
                migration.enumerateObjects(ofType: Wallet.className(), { (old, new) in
                    RealmHelper.doNodeULRStringMigration_4_to_6(old, new)
                    RealmHelper.classicwalletdoPrimaryKeyMigration_4_to_6(old, new)
                })
                
                migration.enumerateObjects(ofType: AddressInfo.className(), { (old, new) in
                    RealmHelper.doNodeULRStringMigration_4_to_6(old, new)
                })
                
                migration.enumerateObjects(ofType: SWallet.className(), { (old, new) in
                    RealmHelper.doNodeULRStringMigration_4_to_6(old, new)
                })
                
                migration.enumerateObjects(ofType: STransaction.className(), { (old, new) in
                    RealmHelper.doNodeULRStringMigration_4_to_6(old, new)
                })
                
            }
            
            
        })
        
        RealmHelper.r = try? Realm(configuration: config)
        //set node storage first
        let nodeStorge = NodeInfoPersistence(realm: RealmInstance!)
        SettingService.shareInstance.nodeStorge = nodeStorge
        
        let walletStorge = WallletPersistence(realm: RealmInstance!)
        WalletService.sharedInstance.walletStorge = walletStorge
        
        
    }
    
    func doSwizzle(){
        
        //RTRootNavigationController.doBadSwizzleStuff()
        UIViewController.doBadSwizzleStuff()
    }
}
