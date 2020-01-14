//
//  NodePersistence.swift
//  platonWallet
//
//  Created by Admin on 14/8/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import RealmSwift

class NodePersistence {

    public class func add(nodes: [Node], _ completion: (() -> Void)?) {
        let nodes = nodes.detached
        _ = nodes.map { $0.chainUrl = SettingService.shareInstance.currentNodeChainId }

        RealmWriteQueue.async {
            autoreleasepool(invoking: {
               let realm = try! Realm(configuration: RealmHelper.getConfig())

                try? realm.write {
                    realm.delete(realm.objects(Node.self))
                    realm.add(nodes, update: true)
                    completion?()
                }
            })
        }
    }

    public class func getAll(sort: NodeSort) -> [Node] {
        let realm = try! Realm(configuration: RealmHelper.getConfig())
        let r = realm.objects(Node.self).sorted(by: sort.sortArray)
        let array = Array(r).detached
        return array
    }

    public class func getActiveNode(sort: NodeSort) -> [Node] {
        let predicate = NSPredicate(format: "nodeStatus == 'Active'")
        let realm = try! Realm(configuration: RealmHelper.getConfig())
        let r = realm.objects(Node.self).filter(predicate).sorted(by: sort.sortArray)
        let array = Array(r).detached
        return array
    }

    public class func getCandiateNode(sort: NodeSort) -> [Node] {
        let predicate = NSPredicate(format: "nodeStatus == 'Candidate'")
        let realm = try! Realm(configuration: RealmHelper.getConfig())
        let r = realm.objects(Node.self).filter(predicate).sorted(by: sort.sortArray)
        let array = Array(r).detached
        return array
    }

    class func searchNodes(text: String, type: NodeControllerType, sort: NodeSort) -> [Node] {
        var predicate: NSPredicate!
        if type == .all {
            predicate = NSPredicate(format: "name CONTAINS[cd] %@", text)
        } else {
            predicate = NSPredicate(format: "nodeStatus == %@ AND name CONTAINS[cd] %@", type == .active ? "Active" : "Candidate", text)
        }

        let realm = try! Realm(configuration: RealmHelper.getConfig())
        let r = realm.objects(Node.self).filter(predicate).sorted(by: sort.sortArray)
        let array = Array(r).detached
        return array
    }
}
