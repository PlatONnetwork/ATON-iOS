//
//  RealmHelper+Migration.swift
//  platonWallet
//
//  Created by Admin on 21/10/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import RealmSwift

extension RealmHelper {
    public static func migrationBelow076(migration: Migration, schemaVersion: UInt64, oldSchemaVersion: UInt64) {

        migration.renameProperty(onType: Node.className(), from: "ratePA", to: "delegatedRatePA")
    }

    public static func migrationBelow0130(migration: Migration, schemaVersion:UInt64, oldSchemaVersion: UInt64) {
        #if UAT
        #elseif PARALLELNET
        #else
        migration.deleteData(forType: AddressInfo.className())
        migration.enumerateObjects(ofType: Wallet.className()) { (oldObject, newObject) in
            guard oldObject != nil, newObject != nil else { return }
            // 旧钱包格式json不保存地址, 所以无需修改
            //Wallet {
            //	primaryKeyIdentifier = 0xBee4D8692caDdfAe2475e981541879AA8D830FEB101;
            //	uuid = 0xBee4D8692caDdfAe2475e981541879AA8D830FEB;
            //	keystorePath = UTC--2020-05-20T13-48-12.25960302348000--0xBee4D8692caDdfAe2475e981541879AA8D830FEB.json;
            //	createTime = 1589953692258;
            //	updateTime = 1589953692258;
            //	name = liyf;
            //	avatar = walletAvatar_7;
            //	chainId = 101;
            //	userArrangementIndex = -1;
            //	balance = ;
            //	lockedBalance = ;
            //	mnemonic = ca54fca945288e78de3573b1bd951894a4965d982999c7eec68b751f2bcc2c6f060ab4a91c2e28326682e33a351f034d5016de3e2c81f3ca81c1a3bfc8c2fedb10ae8a8bfca2;
            //	isBackup = 0;
            //	version = 1;
            //}

            /*guard let address = oldObject!["address"] as? String, (
                    WalletUtil.isValidAddress(address)
            ) else { return }
            newObject!["address"] = Keystore.Address(address: (oldObject!["address"] as? String)!, mainnetHrp: AppConfig.Hrp.LAT, testnetHrp: AppConfig.Hrp.LAX)*/
        }
        #endif
    }

    public static func migrationBelow0120(migration: Migration, schemaVersion:UInt64, oldSchemaVersion: UInt64) {
        #if UAT
        #elseif PARALLELNET
        #else
        migration.enumerateObjects(ofType: Wallet.className()) { (oldObject, newObject) in
            guard oldObject != nil, newObject != nil else { return }
            guard let chainId = oldObject!["chainId"] as? String, (chainId == AppConfig.ChainID.VERSION_074 
                    || chainId == AppConfig.ChainID.VERSION_0741
                    || chainId == AppConfig.ChainID.VERSION_076
                    || chainId == AppConfig.ChainID.VERSION_0110
            ) else { return }
            newObject!["chainId"] = AppConfig.ChainID.VERSION_MAINTESTNET
        }
        #endif
    }

    public static func migrationBelow091(migration: Migration, schemaVersion:UInt64, oldSchemaVersion: UInt64) {
        migration.enumerateObjects(ofType: Wallet.className()) { (oldObject, newObject) in
            guard oldObject != nil, newObject != nil else { return }
            newObject!["version"] = 0
        }
    }

    public static func migrationBelow080(migration: Migration, schemaVersion:UInt64, oldSchemaVersion: UInt64) {
        #if UAT
        #elseif PARALLELNET
        #else
        migration.enumerateObjects(ofType: Wallet.className()) { (oldObject, newObject) in
            guard oldObject != nil, newObject != nil else { return }
            guard let chainId = oldObject!["chainId"] as? String, (chainId == AppConfig.ChainID.VERSION_074 || chainId == AppConfig.ChainID.VERSION_0741 || chainId == AppConfig.ChainID.VERSION_076) else { return }
            newObject!["chainId"] = AppConfig.ChainID.VERSION_MAINTESTNET
        }
        #endif
    }

    public static func migrationBelow0741(migration: Migration, schemaVersion:UInt64, oldSchemaVersion: UInt64) {
        #if UAT
        #elseif PARALLELNET
        #else
        migration.enumerateObjects(ofType: Wallet.className()) { (oldObject, newObject) in
            guard oldObject != nil, newObject != nil else { return }
            guard let chainId = oldObject!["chainId"] as? String, (chainId == AppConfig.ChainID.VERSION_074) else { return }
            newObject!["chainId"] = AppConfig.ChainID.VERSION_0741
        }

        migration.enumerateObjects(ofType: Transaction.className()) { (oldObject, newObject) in
            guard oldObject != nil, newObject != nil else { return }
            guard let chainId = oldObject!["chainId"] as? String, (chainId == AppConfig.ChainID.VERSION_074) else { return }
            newObject!["chainId"] = AppConfig.ChainID.VERSION_0741
        }

        migration.enumerateObjects(ofType: AddressInfo.className()) { (oldObject, newObject) in
            guard oldObject != nil, newObject != nil else { return }
            guard let chainId = oldObject!["chainId"] as? String, (chainId == AppConfig.ChainID.VERSION_074) else { return }
            newObject!["chainId"] = AppConfig.ChainID.VERSION_0741
        }
        #endif
    }

    public static func migrationBelow073(migration: Migration, schemaVersion: UInt64, oldSchemaVersion: UInt64) {

        migration.renameProperty(onType: Transaction.className(), from: "nodeURLStr", to: "chainId")
        migration.renameProperty(onType: AddressInfo.className(), from: "nodeURLStr", to: "chainId")
        migration.renameProperty(onType: Wallet.className(), from: "nodeURLStr", to: "chainId")

        migration.enumerateObjects(ofType: Transaction.className()) { (oldObject, newObject) in
            guard oldObject != nil, newObject != nil else { return }
            let nodeURLStr = oldObject!["nodeURLStr"] as! String
            newObject!["chainId"] = nodeURLStr.chainid
        }

        migration.enumerateObjects(ofType: AddressInfo.className()) { (oldObject, newObject) in
            guard oldObject != nil, newObject != nil else { return }
            let nodeURLStr = oldObject!["nodeURLStr"] as! String
            newObject!["chainId"] = nodeURLStr.chainid
        }

        migration.enumerateObjects(ofType: Wallet.className()) { (oldObject, newObject) in
            guard oldObject != nil, newObject != nil else { return }
            let nodeURLStr = oldObject!["nodeURLStr"] as! String
            newObject!["chainId"] = nodeURLStr.chainid
        }
    }

    /// delete local table DelegateDetailDel
    /// version 0.7.0 set for del delegateRecord to filter data
    public static func migrationBelow0731(migration: Migration, schemaVersion: UInt64, oldSchemaVersion: UInt64) {
        migration.deleteData(forType: "DelegateDetailDel")
    }

    public static func migrationBelow0732(migration: Migration, schemaVersion: UInt64, oldSchemaVersion: UInt64) {
        migration.deleteData(forType: "NodeInfo")
    }
}
