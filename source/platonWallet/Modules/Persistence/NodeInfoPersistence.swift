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

/*
private let defalutNodes = [
    (nodeURL: DefaultNodeURL, desc: "SettingsVC_nodeSet_defaultMainNetwork_title", isSelected: true),
    (nodeURL: "192.168.9.73:6789", desc: "SettingsVC_nodeSet_defaultTestNetwork_title", isSelected: false)]
*/

private let defalutNodes = [
    (nodeURL: DefaultNodeURL, desc: "SettingsVC_nodeSet_defaultTestNetwork_title", isSelected: true)]

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
        
        //remove defaultMainNetwork while during test
        var nodes : [NodeInfo] = []
        var selectedExist = false
        for item in res{
            if item.nodeURLStr == "192.168.9.73:6789" && item.desc == "SettingsVC_nodeSet_defaultTestNetwork_title"{
                continue
            }
            if item.nodeURLStr == "https://syde.platon.network/test" && item.desc == "SettingsVC_nodeSet_defaultMainNetwork_title"{
                let tmp = NodeInfo(nodeURLStr: item.nodeURLStr, desc: "SettingsVC_nodeSet_defaultTestNetwork_title", isSelected: item.isSelected, isDefault: true)
                nodes.append(tmp)
                continue
            }
            nodes.append(item)
        }
        
        for item in nodes{
            if item.isSelected{
                selectedExist = true
            }
        }
        
        if !selectedExist{
            for item in nodes{
                if item.nodeURLStr == "https://syde.platon.network/test"{
                    try? realm.write {
                        item.isSelected = true
                    }
                    break
                }
            }
        }
        
        
        return nodes
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
