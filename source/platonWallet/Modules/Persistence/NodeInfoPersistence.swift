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
    
    static let sharedInstance = NodeInfoPersistence()
    
    func initConfig() {
        let nodes = getAll()
        
        let nodeIdentifiers = nodes.map({$0.nodeURLStr})
        
        var existSelected = false
        for item in nodes {
            if item.isSelected {
                existSelected = true
                break
            }
        }
        
        var newNodes: [(nodeURL: String, desc: String, isSelected: Bool)] = []
        for node in AppConfig.NodeURL.defaultNodesURL {
            guard !nodeIdentifiers.contains(node.nodeURL) else { continue }
            newNodes.append(node)
        }
        
        if existSelected {
            for (index, item) in nodes.enumerated() {
                if index == 0 {
                    update(node: item, isSelected: true)
                } else {
                    update(node: item, isSelected: false)
                }
            }
            for node in newNodes {
                add(node: NodeInfo(nodeURLStr: node.nodeURL, desc: node.desc, isSelected: false, isDefault: true))
            }
        } else {
            if newNodes.count > 0 {
                for (index, node) in newNodes.enumerated() {
                    add(node: NodeInfo(nodeURLStr: node.nodeURL, desc: node.desc, isSelected: index == 0, isDefault: true))
                }
            } else {
                for item in nodes {
                    if item.nodeURLStr == AppConfig.NodeURL.defaultNodesURL.first!.nodeURL {
                        update(node: item, isSelected: true)
                        break
                    }
                }
            }
            
        }
    }
    
    func getAll() -> [NodeInfo] {
        let realm = try! Realm(configuration: RealmHelper.getConfig())
        let res = realm.objects(NodeInfo.self).sorted(byKeyPath: "id")
        if res.count > 0 {
            let array = Array(res)
            return array
        } else {
            return []
        }
    }
    
    func deleteList(_ list:[NodeInfo]) {
        let list = list.detached
        
        RealmWriteQueue.async {
            autoreleasepool(invoking: {
                let realm = try! Realm(configuration: RealmHelper.getConfig())
                
                try? realm.write {
                    for n in list {
                        let predicate = NSPredicate(format: "nodeURLStr == %@ && id == %d", SettingService.getCurrentNodeURLString(), n.id)
                        realm.delete(realm.objects(NodeInfo.self).filter(predicate))
                    }
                }
            })
            
        }
    }
    
    func add(node: NodeInfo) {
        let node = node.detached()
        RealmWriteQueue.async {
            autoreleasepool(invoking: {
                let realm = try! Realm(configuration: RealmHelper.getConfig())
                
                try? realm.write {
                    realm.add(node, update: true)
                }
            })
        }
    }
    
    func update(node: NodeInfo, isSelected:Bool) {
        let predicate = NSPredicate(format: "nodeURLStr == %@ && id == %d", node.nodeURLStr, node.id)
        RealmWriteQueue.async {
            autoreleasepool(invoking: {
                let realm = try! Realm(configuration: RealmHelper.getConfig())
                
                let r = realm.objects(NodeInfo.self).filter(predicate)
                try? realm.write {
                    for n in r {
                        n.isSelected = isSelected
                    }
                }
            })
        }
    }
    
    func delete(node: NodeInfo) {
        let predicate = NSPredicate(format: "nodeURLStr == %@ && id == %d", SettingService.getCurrentNodeURLString(), node.id)
        RealmWriteQueue.async {
            autoreleasepool(invoking: {
                let realm = try! Realm(configuration: RealmHelper.getConfig())
                
                try? realm.write {
                    realm.delete(realm.objects(NodeInfo.self).filter(predicate))
                }
            })
        }
    }
}
