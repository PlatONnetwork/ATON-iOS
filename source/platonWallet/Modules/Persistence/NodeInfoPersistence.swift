//
//  NodeInfoPersistence.swift
//  platonWallet
//
//  Created by matrixelement on 2018/11/2.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import RealmSwift
import Localize_Swift


//private let defalutNodes = [
//    (nodeURL: AppConfig.NodeURL.DefaultNodeURL_Alpha_V071, desc: "SettingsVC_nodeSet_defaultTestNetwork_Amigo_des", isSelected: true),
//]
//
//private let defalutNodes = [
//    (nodeURL: AppConfig.NodeURL.DefaultNodeURL_UAT, desc: "SettingsVC_nodeSet_defaultTestNetwork_des", isSelected: true),
//    (nodeURL: AppConfig.NodeURL.DefaultNodeURL_PRODUCT, desc: "SettingsVC_nodeSet_defaultProductNetwork_des", isSelected: true)
//]

class NodeInfoPersistence {
    
    let realm: Realm
    
    init(realm: Realm) {
        self.realm = realm
        NodeInfo.realm = realm
        let nodes = getAll()
        let nodeIdentifiers = nodes.map({$0.nodeURLStr})
        
        for node in AppConfig.NodeURL.defaultNodesURL {
            guard !nodeIdentifiers.contains(node.nodeURL) else{
                continue
            }
            add(node: NodeInfo(nodeURLStr: node.nodeURL, desc: node.desc, isSelected: node.isSelected, isDefault: true))
        }
        
        var existSelected = false
        for item in nodes {
            if item.isSelected {
                existSelected = true
                break
            }
        }
        
        if !existSelected {
            for item in nodes {
                if item.nodeURLStr == AppConfig.NodeURL.defaultNodesURL.first!.nodeURL {
                    try? realm.write {
                        item.isSelected = true
                    }
                    break
                }
            }
        }
    }
    
    func getAll() -> [NodeInfo] {
        
        let res = RealmHelper.getNewRealm().objects(NodeInfo.self).sorted(byKeyPath: "id")
        guard res.count > 0 else {
            return []
        }
        
        return Array(res)
    }
    
    func deleteList(_ list:[NodeInfo]) {
        try? realm.write {
            realm.delete(list)
        }
    }
    
    func add(node: NodeInfo) {
        try? self.realm.write {
            self.realm.add(node, update: true)
        }
    }
    
    func update(node: NodeInfo, isSelected:Bool) {
        try? realm.write {
            node.isSelected = isSelected
//            realm.add(node, update: true)
        }
    }
    
    func delete(node: NodeInfo) {
        try? realm.write {
            realm.delete(node)
        }
    }

}
