//
//  AddressInfoPersistence.swift
//  platonWallet
//
//  Created by matrixelement on 29/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import RealmSwift

class AddressInfoPersistence {
    
    public class func add(addrInfo : AddressInfo){
        let addrInfo = addrInfo.detached()
        
        RealmWriteQueue.async {
            autoreleasepool(invoking: {
                let realm = try! Realm(configuration: RealmHelper.getConfig())
                try? realm.write {
                    realm.add(addrInfo, update: true)
                }
            })
        }
    }
    
    public class func replaceInto(addrInfo : AddressInfo){
        
        RealmWriteQueue.async {
            autoreleasepool(invoking: {
                let realm = try! Realm(configuration: RealmHelper.getConfig())
                let predicate = NSPredicate(format: "addressType = %d AND walletAddress = %@", AddressType_AddressBook,addrInfo.walletAddress!)
                let r = realm.objects(AddressInfo.self).filter(predicate)
                if r.count == 1{
                    let existedObj = r.first
                    try? realm.write {
                        existedObj?.walletName = addrInfo.walletName
                    }
                }else{
                    try? realm.write {
                        realm.add(addrInfo, update: true)
                    }
                }
            })
        }
    }
    
    public class func getAll() -> [AddressInfo] {
        let realm = try! Realm(configuration: RealmHelper.getConfig())
        let predicate = NSPredicate(format: "addressType = %d", AddressType_AddressBook)
        let r = realm.objects(AddressInfo.self).filter(predicate)
        let array = Array(r)
        return array
    }
    
    public class func delete(addrInfo: AddressInfo) {
        
        let predicate = NSPredicate(format: "nodeURLStr == %@ && uuid == %@", SettingService.getCurrentNodeURLString(), addrInfo.uuid)
        RealmWriteQueue.async {
            autoreleasepool(invoking: {
                let realm = try! Realm(configuration: RealmHelper.getConfig())
                try? realm.write {
                    realm.delete(realm.objects(AddressInfo.self).filter(predicate))
                }
            })
        }
    }
}
