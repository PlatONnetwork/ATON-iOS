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

class NodeInfoPersistence {

    static let sharedInstance = NodeInfoPersistence()

    func initConfig() {
        let nodes = getAll()

        let nodeIdentifiers = nodes.map({$0.nodeURLStr})

        var existSelected = false
        for item in nodes where item.isSelected == true {
            existSelected = true
            break
        }

        var newNodes: [(nodeURL: String, desc: String, chainId: String, isSelected: Bool)] = []
        for node in AppConfig.NodeURL.defaultNodesURL {
            guard !nodeIdentifiers.contains(node.nodeURL) else { continue }
            newNodes.append(node)
        }

        if existSelected {
            for node in newNodes {
                add(nodeURLStr: node.nodeURL, desc: node.desc, chainId: node.chainId, isSelected: false, isDefault: true)
            }
        } else {
            if newNodes.count > 0 {
                for (index, node) in newNodes.enumerated() {
                    add(nodeURLStr: node.nodeURL, desc: node.desc, chainId: node.chainId, isSelected: index == 0, isDefault: true)
                    if index == 0 {
                        SettingService.shareInstance.currentNodeChainId = node.chainId
                    }
                }
            } else {
                for item in nodes where item.nodeURLStr == AppConfig.NodeURL.defaultNodesURL.first!.nodeURL {
                    update(node: item, isSelected: true)
                    SettingService.shareInstance.currentNodeChainId = item.chainId
                    break
                }
            }
        }
    }

    func getAll() -> [NodeInfo] {
        let realm = try! Realm(configuration: RealmHelper.getConfig())
        let res = realm.objects(NodeInfo.self)
        if res.count > 0 {
            let array = Array(res)
            return array
        } else {
            return []
        }
    }

    func add(nodeURLStr: String, desc: String, chainId: String, isSelected: Bool, isDefault: Bool) {
        RealmWriteQueue.async {
            autoreleasepool(invoking: {
                let node = NodeInfo(nodeURLStr: nodeURLStr, desc: desc, chainId: chainId, isSelected: isSelected, isDefault: isDefault)
                let realm = try! Realm(configuration: RealmHelper.getConfig())

                try? realm.write {
                    realm.add(node, update: true)
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
        let predicate = NSPredicate(format: "nodeURLStr == %@ && id == %@", node.nodeURLStr, node.id)
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
        let predicate = NSPredicate(format: "nodeURLStr == %@ && id == %@", node.nodeURLStr, node.id)
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
