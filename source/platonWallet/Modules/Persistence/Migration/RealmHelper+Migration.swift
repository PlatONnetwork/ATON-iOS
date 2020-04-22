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
