//
//  AssetPersistence.swift
//  platonWallet
//
//  Created by matrixelement on 19/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import RealmSwift

class AssetPersistence {
    public class func add(addrInfo : AddressInfo){
        let addrInfo = addrInfo.detached()
        
        RealmWriteQueue.async {
            autoreleasepool(invoking: {
                let realm = try! Realm(configuration: RealmHelper.getConfig())
                try? realm.write {
                    realm.add(addrInfo)
                }
            })
        }
    }
    
    public class func getAll() -> [AddressInfo] {
        let realm = try! Realm(configuration: RealmHelper.getConfig())
        let r = realm.objects(AddressInfo.self)
        let array = Array(r)
        return array
    }
}

