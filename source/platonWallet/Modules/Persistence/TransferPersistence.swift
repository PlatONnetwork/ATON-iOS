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
        DispatchQueue.main.async {
            try? RealmInstance!.write {
                RealmInstance!.add(tx)
                NSLog("TransferPersistence add")
            }
        }
    }
    
    
    public class func getAll() -> [Transaction]{
        let r = RealmInstance!.objects(Transaction.self).sorted(byKeyPath: "createTime", ascending: false)
        let array = Array(r)
        return array.filterArrayByCurrentNodeUrlString()
    }
    
    public class func getAllByAddress(from : String) -> [Transaction]{
        
        let predicate = NSPredicate(format: "from contains[cd] %@ OR to contains[cd] %@", from,from)
        let r = RealmInstance!.objects(Transaction.self).filter(predicate).sorted(byKeyPath: "createTime", ascending: false)
        let array = Array(r)
        return array.filterArrayByCurrentNodeUrlString()
    }
    
    public class func getUnConfirmedTransactions() -> [Transaction]{
        let predicate = NSPredicate(format: "txhash != %@ AND blockNumber == %@", "","")
        let r = RealmInstance!.objects(Transaction.self).filter(predicate).sorted(byKeyPath: "createTime")
        let array = Array(r)
        return array.filterArrayByCurrentNodeUrlString()
    }
    
    public class func getByTxhash(_ hash : String?) -> Transaction?{
        
        let predicate = NSPredicate(format: "txhash == %@", hash!)
        let r = RealmInstance!.objects(Transaction.self).filter(predicate).sorted(byKeyPath: "createTime")
        var array = Array(r)
        array = array.filterArrayByCurrentNodeUrlString()
        if array.count > 0{
            return array.first!
        }
        return nil
    }
}


