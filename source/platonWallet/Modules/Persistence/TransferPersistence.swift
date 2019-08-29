//
//  TransferPersistence.swift
//  platonWallet
//
//  Created by matrixelement on 19/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import RealmSwift

class TransferPersistence {
    
    public class func add(tx : Transaction){
//        tx.nodeURLStr = SettingService.getCurrentNodeURLString()
        RealmWriteQueue.async {
            autoreleasepool(invoking: {
                let realm = RealmHelper.getNewRealm()
                try? realm.write {
                    realm.add(tx)
                    NSLog("TransferPersistence add")
                }
            })
            
        }
    }
    
    public class func update(
        txhash: String,
        status: Int,
        blockNumber: String,
        gasUsed: String,
        _ completion: (() -> Void)?) {
        RealmWriteQueue.async {
            autoreleasepool(invoking: {
                
                let realm = RealmHelper.getNewRealm()
                let predicate = NSPredicate(format: "txhash == %@", txhash)
                
                guard let transaction = realm.objects(Transaction.self).filter(predicate).first else {
                    completion?()
                    return
                }
                
                try? realm.write {
                    transaction.txReceiptStatus = (status == 1) ? 0 : 1
                    transaction.blockNumber = blockNumber
                    transaction.gasUsed = gasUsed
                    completion?()
                }
            })
        }
    }
    
    public class func add(tx: Transaction, _ completion: (() -> Void)?) {
        
        
        RealmWriteQueue.async {
            autoreleasepool(invoking: {
                let realm = RealmHelper.getNewRealm()
                realm.beginWrite()
                realm.delete(realm.objects(Transaction.self))
                realm.add(tx, update: true)
                try? realm.commitWrite()
                DispatchQueue.main.async {
                    completion?()
                }
            })
        }
    }
    
    public class func getAll() -> [Transaction]{
        let wallets = AssetVCSharedData.sharedData.walletList.filterClassicWallet
        let addresses = wallets.map { w -> String in
            return (w.key?.address)!.lowercased()
        }
        let r = RealmInstance!.objects(Transaction.self).sorted(byKeyPath: "createTime", ascending: false)
        let array = Array(r)
        return array.filter { t -> Bool in
            return addresses.contains(t.from?.lowercased() ?? "")
        }
    }
    
    public class func getAllByAddress(from : String) -> [Transaction]{
        
        let predicate = NSPredicate(format: "(from contains[cd] %@ OR to contains[cd] %@)", from,from)
        let r = RealmInstance!.objects(Transaction.self).filter(predicate).sorted(byKeyPath: "createTime", ascending: false)
        let array = Array(r)
        return array
    }
    
    public class func getUnConfirmedTransactions(_ completion: @escaping ([Transaction]) -> () ){
        RealmReadeQueue.async {
            let predicate = NSPredicate(format: "txhash != %@ AND blockNumber == %@", "","")
            let realm = RealmHelper.getNewRealm()
            let r = realm.objects(Transaction.self).filter(predicate).sorted(byKeyPath: "createTime")
            let array = Array(r)
            completion(array)
        }
    }
    
    public class func getByTxhash(_ hash : String?) -> Transaction?{
        let predicate = NSPredicate(format: "txhash == %@", hash!,SettingService.getCurrentNodeURLString())
        let r = RealmInstance!.objects(Transaction.self).filter(predicate).sorted(byKeyPath: "createTime")
        let array = Array(r)
        if array.count > 0{
            return array.first!
        }
        return nil
    }
    
    public class func deleteByTxHashs(_ txHashs: [String]) {
        
        RealmWriteQueue.async {
            autoreleasepool(invoking: {
                let realm = RealmHelper.getNewRealm()
                
                let predicate = NSPredicate(format: "txhash IN %@", txHashs)
                try? realm.write {
                    realm.delete(realm.objects(Transaction.self).filter(predicate))
                }
            })
        }
    }
    
    public class func delete(_ transaction: Transaction) {
        deleteArr([transaction])
    }
    
    public class func deleteArr(_ transactions: [Transaction]) {
        try? RealmInstance?.write {
            RealmInstance!.delete(transactions)
        }
    }
}


