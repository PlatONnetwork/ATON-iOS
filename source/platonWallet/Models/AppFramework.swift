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
        let schemaVersion: UInt64 = 0
        let config = Realm.Configuration(schemaVersion: schemaVersion, migrationBlock: { migration, oldSchemaVersion in
        })
        RealmHelper.r = try? Realm(configuration: config)
        let walletStorge = WallletPersistence(realm: RealmInstance!)
        WalletService.sharedInstance.walletStorge = walletStorge
        let nodeStorge = NodeInfoPersistence(realm: RealmInstance!)
        SettingService.shareInstance.nodeStorge = nodeStorge
    }
}
