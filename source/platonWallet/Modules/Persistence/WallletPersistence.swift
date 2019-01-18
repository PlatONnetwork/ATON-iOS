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
        
    func getAll() -> [Wallet] {

        let res = realm.objects(Wallet.self).sorted(byKeyPath: "createTime")
        let wallets = Array(res)
        return wallets.filter { (item) -> Bool in
            return item.uuid != ""
        }
    }
    
    func get(for address: String) -> Wallet? {
        
        return realm.object(ofType: Wallet.self, forPrimaryKey: address)
        
    }
    
    
}
