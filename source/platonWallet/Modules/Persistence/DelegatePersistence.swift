//
//  DelegatePersistence.swift
//  platonWallet
//
//  Created by Admin on 15/8/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import RealmSwift

class DelegatePersistence {
    public class func add(delegates: [DelegateDetailDel]) {
        let _ = delegates.map { $0.chainUrl = SettingService.getCurrentNodeURLString() }
        
        RealmWriteQueue.async {
            autoreleasepool(invoking: {
                let realm = RealmHelper.getNewRealm()
                try? realm.write {
                    realm.add(delegates, update: true)
                }
            })
        }
    }
    
    // 只返回blocknum，不要在这里进行blocknum判断
    public class func isDeleted(_ walletAddress: String, _ delegateDetail: DelegateDetail) -> Bool {
        let predicate = NSPredicate(format: "compoundKey == %@ AND chainUrl == %@", "\(walletAddress)\(delegateDetail.nodeId)", SettingService.getCurrentNodeURLString())
        let r = RealmInstance!.objects(DelegateDetailDel.self).filter(predicate)
        let result = Array(r)
        guard result.count > 0 else {
            return false
        }
        
        if result.first?.stakingBlockNum != delegateDetail.stakingBlockNum {
            DelegatePersistence.delete(walletAddress, delegateDetail.nodeId)
            return false
        } else {
            return true
        }
    }
    
    public class func delete(_ walletAddress: String, _ nodeId: String) {
        RealmWriteQueue.async {
            autoreleasepool(invoking: {
                let realm = RealmHelper.getNewRealm()
                
                let predicate = NSPredicate(format: "compoundKey == %@ AND chainUrl == %@", "\(walletAddress)\(nodeId)", SettingService.getCurrentNodeURLString())
                try? realm.write {
                    realm.delete(realm.objects(DelegateDetailDel.self).filter(predicate))
                }
            })
        }
    }
}
