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

private let defalutNodes = [(nodeURL: DefaultNodeURL, desc: "SettingsVC_nodeSet_defaultMainNetwork_title", isSelected: true), (nodeURL: "192.168.9.73:6789", desc: "SettingsVC_nodeSet_defaultTestNetwork_title", isSelected: false)]

class NodeInfoPersistence {
    
    let realm: Realm
    
    init(realm: Realm) {
        self.realm = realm
        NodeInfo.realm = realm
        
        if getAll().count == 0 {
            for node in defalutNodes {
                add(node: NodeInfo(nodeURLStr: node.nodeURL, desc: node.desc, isSelected: node.isSelected, isDefault: true))
            }
        }
    }
    
    func getAll() -> [NodeInfo] {
        
        let res = realm.objects(NodeInfo.self).sorted(byKeyPath: "id")
        guard res.count > 0 else {
            return []
        }
        return Array(res)
    }
    
    func add(node: NodeInfo) {
        try? realm.write {
            realm.add(node, update: true)
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
