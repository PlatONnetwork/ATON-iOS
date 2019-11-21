//
//  WallletPersistence.swift
//  platonWallet
//
//  Created by matrixelement on 19/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import RealmSwift

class WallletPersistence {

    static let sharedInstance = WallletPersistence()

    func save(wallet: Wallet) {
        let wallet = wallet.detached()

        RealmWriteQueue.async {
            autoreleasepool(invoking: {
                let realm = try! Realm(configuration: RealmHelper.getConfig())
                wallet.chainId = SettingService.shareInstance.currentNodeChainId
                try? realm.write {
                    realm.add(wallet, update: true)
                }
            })
        }
    }

    func delete(wallet: Wallet) {

        let predicate = NSPredicate(format: "chainId == %@ && primaryKeyIdentifier == %@", SettingService.shareInstance.currentNodeChainId, wallet.primaryKeyIdentifier)
        RealmWriteQueue.async {
            autoreleasepool(invoking: {
                let realm = try! Realm(configuration: RealmHelper.getConfig())
                try? realm.write {
                    realm.delete(realm.objects(Wallet.self).filter(predicate))
                }
            })
        }
    }

    func updateWalletName(wallet: Wallet, name: String) {

        let predicate = NSPredicate(format: "chainId == %@ && primaryKeyIdentifier == %@", SettingService.shareInstance.currentNodeChainId, wallet.primaryKeyIdentifier)
        RealmWriteQueue.async {
            autoreleasepool(invoking: {
                let realm = try! Realm(configuration: RealmHelper.getConfig())
                try? realm.write {
                    let r = realm.objects(Wallet.self).filter(predicate)
                    for wal in r {
                        wal.name = name
                    }
                }
            })
        }
    }

    func updateWalletUserArrangementIndex(wallet: Wallet, userArrangementIndex: Int) {

        let predicate = NSPredicate(format: "chainId == %@ && primaryKeyIdentifier == %@", SettingService.shareInstance.currentNodeChainId, wallet.primaryKeyIdentifier)
        RealmWriteQueue.async {
            autoreleasepool(invoking: {
                let realm = try! Realm(configuration: RealmHelper.getConfig())
                try? realm.write {
                    let r = realm.objects(Wallet.self).filter(predicate)
                    for wal in r {
                        wal.userArrangementIndex = userArrangementIndex
                    }
                }
            })
        }
    }

    // 0.6.2更新 增加余额缓存
    func updateWalletBalance(wallet: Wallet, balance: String) {
        let predicate = NSPredicate(format: "chainId == %@ && primaryKeyIdentifier == %@", SettingService.shareInstance.currentNodeChainId, wallet.primaryKeyIdentifier)
        RealmWriteQueue.async {
            autoreleasepool(invoking: {
                let realm = try! Realm(configuration: RealmHelper.getConfig())
                try? realm.write {
                    let r = realm.objects(Wallet.self).filter(predicate)
                    for wal in r {
                        wal.balance = balance
                    }
                }
            })
        }
    }

    // 0.7.0版本更新 增加锁仓余额缓存
    func updateWalletLockedBalance(wallet: Wallet, value: String) {
        let predicate = NSPredicate(format: "chainId == %@ && primaryKeyIdentifier == %@", SettingService.shareInstance.currentNodeChainId, wallet.primaryKeyIdentifier)

        RealmWriteQueue.async {
            autoreleasepool(invoking: {
                let realm = try! Realm(configuration: RealmHelper.getConfig())

                try? realm.write {
                    let r = realm.objects(Wallet.self).filter(predicate)
                    for wal in r {
                        wal.lockedBalance = value
                    }
                }
            })
        }
    }

    func getAll(detached: Bool = false) -> [Wallet] {
        let realm = try! Realm(configuration: RealmHelper.getConfig())

        let res = realm.objects(Wallet.self).sorted(byKeyPath: "createTime")
        var wallets : [Wallet] = []
        if detached {
            for item in Array(res) {
                wallets.append(item.detached())
            }
        } else {
            wallets = Array(res)
        }
        wallets = wallets.filterArrayByCurrentNodeUrlString().detached

        for item in wallets {
            item.key = try? Keystore(contentsOf: URL(fileURLWithPath: keystoreFolderPath + "/\(item.keystorePath)"))
        }
        let result = wallets.filter { (item) -> Bool in
            return item.uuid != ""
        }
        return result
    }
}
