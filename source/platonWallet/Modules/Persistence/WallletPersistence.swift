//
//  WallletPersistence.swift
//  platonWallet
//
//  Created by matrixelement on 19/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import RealmSwift

class WallletPersistence {
    
    let realm: Realm
    
    init(realm : Realm) { 
        self.realm = realm
    }
    
    func save(wallet: Wallet) {
        wallet.nodeURLStr = SettingService.getCurrentNodeURLString()
        try? realm.write {
            realm.add(wallet, update: true) 
        }

    }
    
    func delete(wallet: Wallet) {
        try? realm.write {
            realm.delete(wallet)
        }
    }
    
    func updateWalletName(wallet: Wallet, name: String) {
        try? realm.write({ 
            wallet.name = name
        })
    }
    
    // 0.6.2更新 增加余额缓存
    func updateWalletBalance(wallet: Wallet, balance: String) {
        try? realm.write {
            wallet.balance = balance
        }
    }
        
    func getAll() -> [Wallet] {

        let res = realm.objects(Wallet.self).sorted(byKeyPath: "createTime")
        var wallets = Array(res)
        wallets = wallets.filterArrayByCurrentNodeUrlString()
        for item in wallets {
            item.key = try? Keystore(contentsOf: URL(fileURLWithPath: keystoreFolderPath + "/\(item.keystorePath)"))
        }
        return wallets.filter { (item) -> Bool in
            return item.uuid != ""
        }
    }
    
    /*
    func get(for address: String) -> Wallet? {
        return realm.object(ofType: Wallet.self, forPrimaryKey: address)
    }
    */
    
    
}
