//
//  AddressInfoPersistence.swift
//  platonWallet
//
//  Created by matrixelement on 29/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation

class AddressInfoPersistence {
    
    public class func add(addrInfo : AddressInfo){
        addrInfo.nodeURLStr = SettingService.getCurrentNodeURLString()
        try? RealmInstance!.write {
            RealmInstance!.add(addrInfo, update: true)
            NSLog("AddressInfo add")
        }
    }
    
    public class func replaceInto(addrInfo : AddressInfo){
        
        addrInfo.nodeURLStr = SettingService.getCurrentNodeURLString()
        let predicate = NSPredicate(format: "addressType = %d AND walletAddress = %@ AND nodeURLStr = %@", AddressType_AddressBook,addrInfo.walletAddress!,SettingService.getCurrentNodeURLString())
        let r = RealmInstance!.objects(AddressInfo.self).filter(predicate)
        if r.count == 1{
            let existedObj = r.first
            RealmInstance?.beginWrite()
            existedObj?.walletName = addrInfo.walletName
            try? RealmInstance?.commitWrite()
        }else{
            try? RealmInstance!.write {
                RealmInstance!.add(addrInfo, update: true)
                NSLog("AddressInfo add")
            }
        }

    }
    
    public class func getAll() -> [AddressInfo]{
        let predicate = NSPredicate(format: "addressType = %d", AddressType_AddressBook)
        //let r = RealmInstance!.objects(AddressInfo.self).filter(predicate).sorted(byKeyPath: "createTime")
        let r = RealmInstance!.objects(AddressInfo.self).filter(predicate)
        let array = Array(r)
        return array.filterArrayByCurrentNodeUrlString()
    }
    
    public class func delete(addrInfo: AddressInfo) {
        
        try? RealmInstance!.write {
            RealmInstance!.delete(addrInfo)
        }
        
    }
}
