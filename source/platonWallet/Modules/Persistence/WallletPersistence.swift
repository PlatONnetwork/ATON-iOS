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

    func save(wallet: Wallet, subWallets: [Wallet]? = nil) {
        let wallet = wallet.detached()

        RealmWriteQueue.async {
            autoreleasepool(invoking: {
                let realm = try! Realm(configuration: RealmHelper.getConfig())
                try? realm.write {
                    if subWallets != nil {
                        wallet.subWallets.append(objectsIn: subWallets!)
                    }
                    realm.add(wallet, update: .all)
                }
            })
        }
    }

    func save(wallets: [Wallet]) {
        let wallets = wallets.detached
        let walletList = List<Wallet>()
        wallets.forEach { (wallet) in
            walletList.append(wallet)
        }
        RealmWriteQueue.async {
            autoreleasepool(invoking: {
                let realm = try! Realm(configuration: RealmHelper.getConfig())
                try! realm.write {
                    realm.add(walletList)
                }
            })
        }
    }

    func delete(wallet: Wallet) {

        let predicate = NSPredicate(format: "primaryKeyIdentifier == %@", wallet.primaryKeyIdentifier)
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

        let predicate = NSPredicate(format: "primaryKeyIdentifier == %@", wallet.primaryKeyIdentifier)
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

    func updateWalletBackupStatus(wallet: Wallet, isBackup: Bool) {
        let predicate = NSPredicate(format: "primaryKeyIdentifier == %@", wallet.primaryKeyIdentifier)
        RealmWriteQueue.async {
            autoreleasepool(invoking: {
                let realm = try! Realm(configuration: RealmHelper.getConfig())
                try? realm.write {
                    let r = realm.objects(Wallet.self).filter(predicate)
                    for wal in r {
                        wal.isBackup = isBackup
                    }
                }
            })
        }
    }

    func updateWalletUserArrangementIndex(wallet: Wallet, userArrangementIndex: Int) {

        let predicate = NSPredicate(format: "primaryKeyIdentifier == %@", wallet.primaryKeyIdentifier)
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
        let predicate = NSPredicate(format: "primaryKeyIdentifier == %@", wallet.primaryKeyIdentifier)
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
        let predicate = NSPredicate(format: "primaryKeyIdentifier == %@", wallet.primaryKeyIdentifier)

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
    
    /// 更新钱包选中索引值（操作对象通常是HD母钱包）
    func updateWalletSelectedIndex(wallet: Wallet, selectedIndex: Int) {
        let predicate = NSPredicate(format: "primaryKeyIdentifier == %@", wallet.primaryKeyIdentifier)
        RealmWriteQueue.async {
            autoreleasepool(invoking: {
                let realm = try! Realm(configuration: RealmHelper.getConfig())

                try? realm.write {
                    let r = realm.objects(Wallet.self).filter(predicate)
                    for wal in r {
                        wal.selectedIndex = selectedIndex
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
