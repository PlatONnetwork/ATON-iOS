//
//  AssetPersistence.swift
//  platonWallet
//
//  Created by matrixelement on 19/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation

class AssetPersistence {
    public class func add(addrInfo : AddressInfo){
        
        DispatchQueue.main.async {
            try? RealmInstance!.write {
                RealmInstance!.add(addrInfo)
                NSLog("AddressInfo add")
            }
        }
    }
    
    public class func getAll() -> [AddressInfo]{
        let r = RealmInstance!.objects(AddressInfo.self)
        let array = Array(r)
        return array
    }

}

