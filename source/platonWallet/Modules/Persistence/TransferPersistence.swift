//
//  TransferPersistence.swift
//  platonWallet
//
//  Created by matrixelement on 19/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation

class TransferPersistence {
    
    public class func add(tx : Transaction){
        tx.nodeURLStr = SettingService.getCurrentNodeURLString()        
        RealmWriteQueue.async {
            let realm = RealmHelper.getWriteRealm()
            try? realm.write {
                realm.add(tx)
                NSLog("TransferPersistence add")
            }
        }
    }
    
    public class func getAll() -> [Transaction]{
        let predicate = NSPredicate(format: "nodeURLStr == %@", SettingService.getCurrentNodeURLString())
        let r = RealmInstance!.objects(Transaction.self).filter(predicate).sorted(byKeyPath: "createTime", ascending: false)
        let array = Array(r)
        return array
    }
    
    public class func getAllByAddress(from : String) -> [Transaction]{
        
        let predicate = NSPredicate(format: "(from contains[cd] %@ OR to contains[cd] %@) AND nodeURLStr == %@", from,from,SettingService.getCurrentNodeURLString())
        let r = RealmInstance!.objects(Transaction.self).filter(predicate).sorted(byKeyPath: "createTime", ascending: false)
        let array = Array(r)
        return array
    }
    
    public class func getUnConfirmedTransactions() -> [Transaction]{
        let predicate = NSPredicate(format: "txhash != %@ AND blockNumber == %@ AND nodeURLStr == %@", "","",SettingService.getCurrentNodeURLString())
        let r = RealmInstance!.objects(Transaction.self).filter(predicate).sorted(byKeyPath: "createTime")
        let array = Array(r)
        return array
    }
    
    public class func getByTxhash(_ hash : String?) -> Transaction?{
        
        let predicate = NSPredicate(format: "txhash == %@ AND nodeURLStr == %@", hash!,SettingService.getCurrentNodeURLString())
        let r = RealmInstance!.objects(Transaction.self).filter(predicate).sorted(byKeyPath: "createTime")
        let array = Array(r)
        if array.count > 0{
            return array.first!
        }
        return nil
    }
}


