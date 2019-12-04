//
//  TwoHourTransactionPersistence.swift
//  platonWallet
//
//  Created by Admin on 4/12/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import RealmSwift

class TwoHourTransactionPersistence {
    class func add(tx: TwoHourTransaction) {
        let tx = tx.detached()

        tx.chainId = SettingService.shareInstance.currentNodeChainId
        RealmWriteQueue.async {
            autoreleasepool(invoking: {
                let realm = try! Realm(configuration: RealmHelper.getConfig())
                try? realm.write {
                    realm.add(tx)
                }
            })
        }
    }

    class func getTwoHourTransactions(from: String, to: String, value: String) -> [TwoHourTransaction] {
        let realm = try! Realm(configuration: RealmHelper.getConfig())

        let predicate = NSPredicate(format: "from == %@ AND to == %@ AND value == %@ AND chainId == %@", from.lowercased(), to.lowercased(), value, SettingService.shareInstance.currentNodeChainId)
        let r = realm.objects(TwoHourTransaction.self).filter(predicate).sorted(byKeyPath: "createTime", ascending: false)
        let array = Array(r).detached
        return array
    }

    class func deleteOverTwoHourTransaction() {
        RealmWriteQueue.async {
            autoreleasepool(invoking: {
                let realm = try! Realm(configuration: RealmHelper.getConfig())
                let predicate = NSPredicate(format: "createTime < %@", NSNumber(integerLiteral: Date().millisecondsSince1970 - AppConfig.OvertimeTranction.overtime))
                let r = realm.objects(TwoHourTransaction.self).filter(predicate)
                try? realm.write {
                    realm.delete(realm.objects(TwoHourTransaction.self).filter(predicate))
                }
            })
        }
    }
}
