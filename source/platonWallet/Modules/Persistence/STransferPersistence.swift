//
//  STransferPersistence.swift
//  platonWallet
//
//  Created by matrixelement on 27/11/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation

class STransferPersistence {
    
    public class func add(tx : STransaction){
        
        tx.from = tx.from?.lowercased()
        tx.to = tx.to?.lowercased()
        tx.nodeURLStr = SettingService.getCurrentNodeURLString()

        
        if tx.transactionCategory == TransanctionCategory.ATPTransfer.rawValue{    
            //deprecated business requirements
            //let _ = tx.initAsUnread
            
            let forCheckOutward = tx.contractAddress + "_" + tx.transactionID
            let predicate = NSPredicate(format: "transactionID = %@ AND transactionCategory = %d AND contractAddress contains[c] %@",
                                        tx.transactionID,
                                        tx.transactionType,
                                        tx.contractAddress
            )
            let r = RealmInstance!.objects(STransaction.self).filter(predicate).sorted(byKeyPath: "createTime", ascending: false)
            if r.count == 1 {
                let existed = r.first
                RealmInstance?.beginWrite()
                if SWalletService.sharedInstance.outwardHash.contains(forCheckOutward) && existed?.readTag == ReadTag.UnRead.rawValue{
                    //update outward mutisign transaction as readed
                    existed?.readTag = ReadTag.Readed.rawValue
                }
                
                if (tx.blockNumber?.length)! > 0{
                    existed?.blockNumber = tx.blockNumber
                }

                if (tx.txhash?.length)! > 0{
                    existed?.txhash = tx.txhash
                }
                
                if tx.contractAddress.length != 0 && existed?.contractAddress.length == 0{
                    existed?.contractAddress = tx.contractAddress
                }
                
                var dic: Dictionary<String,DeterminedResult> = [:]
                for item in tx.determinedResult{
                    dic[(item.walletAddress?.lowercased())!] = item
                }
                
                for item in (existed?.determinedResult)!{
                    if (item.walletAddress != nil && !(item.walletAddress?.hasPrefix("0x"))!){
                        item.walletAddress = "0x" + item.walletAddress!
                    }
                    guard let newItem = dic[item.walletAddress!.lowercased()] else{
                        continue
                    }
                    item.operation = newItem.operation
                } 
                 
                existed?.pending = tx.pending
                existed?.executed = tx.executed
                try? RealmInstance?.commitWrite()

            }else{
                if SWalletService.sharedInstance.outwardHash.contains(forCheckOutward){
                    //update outward mutisign transaction as readed
                    tx.readTag = ReadTag.Readed.rawValue
                }else{
                    tx.readTag = ReadTag.UnRead.rawValue
                }
                addWithoutDeduplication(tx: tx)
            }
            
        }else{
            tx.readTag = ReadTag.Readed.rawValue
            addWithoutDeduplication(tx: tx)
        }
    }
    
    public class func addWithoutDeduplication(tx : STransaction){
        let txCopy = STransaction.init(value: tx)
        RealmWriteQueue.async {
            let realm = RealmHelper.getWriteRealm()
            try? realm.write {
                realm.add(txCopy)
                NSLog("STransaction add")
            }
        }
    }
    
    public class func update(tx : STransaction){
        try? RealmInstance!.write {
            RealmInstance?.add(tx, update: true)
        }
    }
    
    public class func updateAsRead(tx : STransaction){
        RealmInstance?.beginWrite()
        tx.readTag = ReadTag.Readed.rawValue
        try? RealmInstance?.commitWrite()
    }
    
    public class func updateJointWalletCreation(contractAddress: String,hash: String){
        let predicate = NSPredicate(format: "txhash contains[c] %@",hash)
        let r = RealmInstance!.objects(STransaction.self).filter(predicate).sorted(byKeyPath: "createTime", ascending: false)
        if r.count > 0{
            let s = r.first
            RealmInstance?.beginWrite()
            if !contractAddress.hasPrefix("0x"){
                s?.contractAddress = "0x" + contractAddress
                s?.to = s?.contractAddress
            }else{
                s?.contractAddress = contractAddress
                s?.to = s?.contractAddress
            }
            
            try? RealmInstance?.commitWrite()
        }else{
            //not found, sharedWallet sponsor a transfer
        }
    }
    
    public class func updateByTransactionId(tx: STransaction, hash: String){
        let predicate = NSPredicate(format: "uuid = %@",tx.uuid)
        let r = RealmInstance!.objects(STransaction.self).filter(predicate).sorted(byKeyPath: "createTime", ascending: false)
        if r.count > 0{
            let s = r.first
            RealmInstance?.beginWrite()
            if !hash.hasPrefix("0x"){
                s?.txhash = "0x" + hash
            }else{
                s?.txhash = hash
            }
            
            try? RealmInstance?.commitWrite()
        }else{
            //not found, sharedWallet sponsor a transfer
        }
    }
    
//    public class func getAll() -> [STransaction]{
//        let predicate = NSPredicate(format: "nodeURLStr == %@", SettingService.getCurrentNodeURLString())
//        let r = RealmInstance!.objects(STransaction.self).filter(predicate).sorted(byKeyPath: "createTime", ascending: false)
//        let array = Array(r)
//        return array
//    }
    
    public class func getAllTransactionForTransactionList() -> [STransaction]{
       
        let predicate = NSPredicate(format: "nodeURLStr == %@", SettingService.getCurrentNodeURLString())
        let r = RealmInstance!.objects(STransaction.self).filter(predicate).sorted(byKeyPath: "createTime", ascending: false)

        var filterArray = Array<STransaction>()
        let all = Array(r)
        for item in all{
            if item.transanctionCategoryLazy == .ATPTransfer{
                if (item.signStatus == .reachApproval || item.signStatus == .reachRevoke){
                    filterArray.append(item)
                }
            }else{
                filterArray.append(item)
            }
        }
        return filterArray
    }
    
    public class func getAllATPTransferByContractAddress(_ contractAddress : String?) -> [STransaction]{
        var predicate : NSPredicate?
        if contractAddress == nil{
            //predicate = NSPredicate(format: "transactionCategory = %d", TransanctionCategory.ATPTransfer.rawValue)
            predicate = NSPredicate(format: "transactionCategory >= 0 AND nodeURLStr == %@",SettingService.getCurrentNodeURLString())
        }else{
            predicate = NSPredicate(format: "transactionCategory = %d AND contractAddress contains[c] %@ AND nodeURLStr == %@", TransanctionCategory.ATPTransfer.rawValue, (contractAddress)!,SettingService.getCurrentNodeURLString())
        }
        let r = RealmInstance!.objects(STransaction.self).filter(predicate!).sorted(byKeyPath: "createTime", ascending: false)
        let array = Array(r)
        return array
    }
    
    public class func getAllATPTransferByReceiveAddress(_ receiveAddress : String) -> [STransaction]{
        let predicate = NSPredicate(format: "transactionCategory = %d AND to contains[c] %@ AND nodeURLStr == %@", TransanctionCategory.ATPTransfer.rawValue, receiveAddress,SettingService.getCurrentNodeURLString())
        let r = RealmInstance!.objects(STransaction.self).filter(predicate).sorted(byKeyPath: "createTime", ascending: false)
        let array = Array(r)
        return array
    }
    
    public class func getAllByWalletOwner(address : String) -> [STransaction]{
    
        /*
        let predicate = NSPredicate(format: "(ownerWalletAddress contains[c] %@ OR to contains[c] %@)",
                                    address,address)
        */
        let predicate = NSPredicate(format: "(ownerWalletAddress contains[c] %@ OR (ANY determinedResult.walletAddress contains[c] %@ AND transactionCategory = %d)) AND nodeURLStr == %@",
                                    address,
                                    address,
                                    TransanctionCategory.ATPTransfer.rawValue,
                                    SettingService.getCurrentNodeURLString())
        
        let r = RealmInstance!.objects(STransaction.self).filter(predicate).sorted(byKeyPath: "createTime", ascending: false)
        var array : [STransaction] = []
        for item in r{
            let cw = SWalletService.sharedInstance.getATPWalletByAddress(address: item.ownerWalletAddress)
            let jw = SWalletService.sharedInstance.getSWalletByContractAddress(contractAddress: item.contractAddress)
            if cw != nil && jw != nil{
                array.append(item)
            }
        }
        return array
    }
    
    public class func getUnConfirmedTransactions() -> [STransaction]{
        //ignore delpoy contract transaction
        let predicate = NSPredicate(format: "txhash != %@ AND blockNumber == %@ AND nodeURLStr == %@",
                                    "",
                                    "",
                                    SettingService.getCurrentNodeURLString())
        let r = RealmInstance!.objects(STransaction.self).filter(predicate).sorted(byKeyPath: "createTime")
        let array = Array(r)
        return array
    }
    
    public class func getByTxhash(_ hash : String?) -> STransaction?{
        //only return transaction which hash exsited
        if hash?.count == 0{
            return nil
        }
        let predicate = NSPredicate(format: "txhash == %@", hash!)
        let r = RealmInstance!.objects(STransaction.self).filter(predicate).sorted(byKeyPath: "createTime")
        let array = Array(r)
        if array.count > 0{
            return array.first!
        }
        return nil
    }
    
    public class func deleteByContractAddress(_ contractAddress : String?){
        let predicate = NSPredicate(format: "contractAddress contains[c] %@",contractAddress!)
        let r = RealmInstance!.objects(STransaction.self).filter(predicate).sorted(byKeyPath: "createTime", ascending: false)
        for item in r{
            try! RealmInstance!.write {
                RealmInstance!.delete(item)
            }
        }
    }
    
    
    public class func updateSharedWalletDeleteTag(contractAddress : String, deleted: DeleteTag){
        let predicate = NSPredicate(format: "contractAddress = %@",contractAddress)
        let r = RealmInstance!.objects(STransaction.self).filter(predicate).sorted(byKeyPath: "createTime", ascending: false)
        for item in r{
            try! RealmInstance!.write {
                item.swalletDelete = deleted.rawValue
            }
        }
    }
    
    public class func unreadMessageExisted() -> Bool{
        let predicate = NSPredicate(format: "transactionCategory = %d AND readTag = %d AND swalletDelete = %d",
                                    TransanctionCategory.ATPTransfer.rawValue,
                                    ReadTag.UnRead.rawValue,
                                    DeleteTag.NO.rawValue
        )
        let r = RealmInstance!.objects(STransaction.self).filter(predicate).sorted(byKeyPath: "createTime")
        if r.count > 0{
            return true
        }
        return false
    }
    
    public class func unreadMessageExistedWithContractAddress(_ contractAddrss: String) -> Bool{
        let predicate = NSPredicate(format: "transactionCategory = %d AND readTag = %d AND contractAddress = %@ AND swalletDelete = %d",
                                    TransanctionCategory.ATPTransfer.rawValue,
                                    ReadTag.UnRead.rawValue,
                                    contractAddrss,
                                    DeleteTag.NO.rawValue
        )
        let r = RealmInstance!.objects(STransaction.self).filter(predicate).sorted(byKeyPath: "createTime")
        if r.count > 0{
            return true
        }
        return false
    }
    
}
