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

    public class func add(tx : Transaction) {
        let tx = tx.detached()

        tx.chainId = SettingService.shareInstance.currentNodeChainId
        RealmWriteQueue.async {
            autoreleasepool(invoking: {
                let realm = try! Realm(configuration: RealmHelper.getConfig())
                try? realm.write {
                    realm.add(tx, update: true)
                }
            })
        }
    }

    public class func update(txhash: String, status: Int) {
        RealmWriteQueue.async {
            autoreleasepool(invoking: {
                let realm = try! Realm(configuration: RealmHelper.getConfig())
                let predicate = NSPredicate(format: "txhash == %@ AND chainId == %@", txhash, SettingService.shareInstance.currentNodeChainId)

                try? realm.write {
                    let r = realm.objects(Transaction.self).filter(predicate)
                    for tx in r {
                        tx.txReceiptStatus = status
                    }
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
                let realm = try! Realm(configuration: RealmHelper.getConfig())

                let predicate = NSPredicate(format: "txhash == %@ AND chainId == %@", txhash, SettingService.shareInstance.currentNodeChainId)

                guard let transaction = realm.objects(Transaction.self).filter(predicate).first else {
                    completion?()
                    return
                }

                do {
                    try realm.write {
                        transaction.txReceiptStatus = status
                        transaction.blockNumber = blockNumber
                        transaction.gasUsed = gasUsed
                        completion?()
                    }
                } catch let e {
                    print("fatal error:\(e)")
                }

            })
        }
    }

    public class func getAll() -> [Transaction] {
        let realm = try! Realm(configuration: RealmHelper.getConfig())

        let wallets = AssetVCSharedData.sharedData.walletList.filterClassicWallet
        let addresses = wallets.map { w -> String in
            return w.address.lowercased()
        }
        let predicate = NSPredicate(format: "chainId == %@", SettingService.shareInstance.currentNodeChainId)
        let r = realm.objects(Transaction.self).filter(predicate).sorted(byKeyPath: "createTime", ascending: false)
        let array = Array(r)
        let result = array.filter { t -> Bool in
            return addresses.contains(t.from?.lowercased() ?? "")
        }
        return result.detached
    }

    public class func getTransactionsByAddress(from: String, status: TransactionReceiptStatus, detached: Bool = false) -> [Transaction] {
        let realm = try! Realm(configuration: RealmHelper.getConfig())
        let predicate = NSPredicate(format: "(from contains[cd] %@ OR to contains[cd] %@) AND chainId == %@ AND blockNumber == %@ AND txhash != %@ AND txReceiptStatus = %d",
                                    from,
                                    from,
                                    SettingService.shareInstance.currentNodeChainId,
                                    "",
                                    "",
                                    status.rawValue)
        let r = realm.objects(Transaction.self).filter(predicate).sorted(byKeyPath: "createTime", ascending: false)
        var array : [Transaction] = []
        if detached {
            array = Array(r).detached
        } else {
            array = Array(r).detached
        }
        return array
    }

    public class func getUnConfirmedTransactions() -> [Transaction] {
        let realm = try! Realm(configuration: RealmHelper.getConfig())

        let predicate = NSPredicate(format: "txhash != %@ AND blockNumber == %@ AND chainId == %@ AND txReceiptStatus == %d", "","",SettingService.shareInstance.currentNodeChainId, TransactionReceiptStatus.pending.rawValue)
        let r = realm.objects(Transaction.self).filter(predicate).sorted(byKeyPath: "createTime")
        let array = Array(r).detached
        return array
    }

    public class func getByTxhash(_ hash : String?) -> Transaction? {
        let realm = try! Realm(configuration: RealmHelper.getConfig())

        let predicate = NSPredicate(format: "txhash == %@ AND chainId == %@", hash!,SettingService.shareInstance.currentNodeChainId)
        let r = realm.objects(Transaction.self).filter(predicate).sorted(byKeyPath: "createTime")
        let array = Array(r)

        if array.count > 0 {
            return array.first!.detached()
        } else {
            return nil
        }
    }

    public class func delete(_ txhash: String) {
        RealmWriteQueue.async {
            autoreleasepool(invoking: {
                let realm = try! Realm(configuration: RealmHelper.getConfig())
                let predicate = NSPredicate(format: "txhash == %@", txhash)
                try? realm.write {
                    realm.delete(realm.objects(Transaction.self).filter(predicate))
                }
            })
        }
    }

    public class func deleteConfirmedTransaction() {
        RealmWriteQueue.async {
            autoreleasepool(invoking: {
                let realm = try! Realm(configuration: RealmHelper.getConfig())
                let predicate = NSPredicate(format: "txhash != %@ AND (txReceiptStatus == %@ OR txReceiptStatus == %@)", "",NSNumber(value: TransactionReceiptStatus.sucess.rawValue),NSNumber(value: TransactionReceiptStatus.businessCodeError.rawValue))
                try? realm.write {
                    realm.delete(realm.objects(Transaction.self).filter(predicate))
                }
            })
        }
    }

    public class func getRewardPendingTransaction(address: String) -> [Transaction] {
        let realm = try! Realm(configuration: RealmHelper.getConfig())
        let transactionType = Int(TxType.claimReward.rawValue) ?? 5000
        let predicate = NSPredicate(format: "transactionType == %@ AND from CONTAINS[cd] %@ AND chainId == %@ AND txReceiptStatus == %@", NSNumber(value: transactionType), address, SettingService.shareInstance.currentNodeChainId, NSNumber(value: TransactionReceiptStatus.pending.rawValue))
        let r = realm.objects(Transaction.self).filter(predicate)
        let array = Array(r).detached
        return array
    }

    public class func getDelegateCreatePendingTransaction(address: String, nodeId: String) -> [Transaction] {
        let realm = try! Realm(configuration: RealmHelper.getConfig())
        let transactionType = Int(TxType.delegateCreate.rawValue) ?? 1004
        let predicate = NSPredicate(format: "transactionType == %@ AND from CONTAINS[cd] %@ AND nodeId == %@ AND chainId == %@ AND txReceiptStatus == %@", NSNumber(value: transactionType), address, nodeId, SettingService.shareInstance.currentNodeChainId, NSNumber(value: TransactionReceiptStatus.pending.rawValue))
        let r = realm.objects(Transaction.self).filter(predicate)
        let array = Array(r).detached
        return array
    }

    public class func getDelegateWithdrawPendingTransaction(address: String, nodeId: String) -> [Transaction] {
        let realm = try! Realm(configuration: RealmHelper.getConfig())
        let transactionType = Int(TxType.delegateWithdraw.rawValue) ?? 1005
        let predicate = NSPredicate(format: "transactionType == %@ AND from CONTAINS[cd] %@ AND nodeId == %@ AND chainId == %@ AND txReceiptStatus == %@", NSNumber(value: transactionType), address, nodeId, SettingService.shareInstance.currentNodeChainId, NSNumber(value: TransactionReceiptStatus.pending.rawValue))
        let r = realm.objects(Transaction.self).filter(predicate)
        let array = Array(r).detached
        return array
    }

    public class func getTransferPendingTransaction(address: String) -> [Transaction] {
        let realm = try! Realm(configuration: RealmHelper.getConfig())
        let transactionType = Int(TxType.transfer.rawValue) ?? 0
        let predicate = NSPredicate(format: "transactionType == %@ AND from CONTAINS[cd] %@ AND chainId == %@ AND txReceiptStatus == %@", NSNumber(value: transactionType), address, SettingService.shareInstance.currentNodeChainId, NSNumber(value: TransactionReceiptStatus.pending.rawValue))
        let r = realm.objects(Transaction.self).filter(predicate)
        let array = Array(r).detached
        return array
    }

    public class func getPendingTransaction(address: String) -> [Transaction] {
        let realm = try! Realm(configuration: RealmHelper.getConfig())
        let predicate = NSPredicate(format: "from CONTAINS[cd] %@ AND chainId == %@ AND txReceiptStatus == %@", address, SettingService.shareInstance.currentNodeChainId, NSNumber(value: TransactionReceiptStatus.pending.rawValue))
        let r = realm.objects(Transaction.self).filter(predicate).sorted(byKeyPath: "createTime", ascending: false)
        let array = Array(r).detached
        return array
    }
}
