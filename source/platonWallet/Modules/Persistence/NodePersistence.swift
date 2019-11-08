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

    public class func getAll(isRankingSorted: Bool = true) -> [Node] {
        let sortPropertis = [
            SortDescriptor(keyPath: isRankingSorted ? "ranking" : "ratePA", ascending: isRankingSorted ? true : false),
            SortDescriptor(keyPath: isRankingSorted ? "ratePA" : "ranking", ascending: isRankingSorted ? true : false)
        ]
        let realm = try! Realm(configuration: RealmHelper.getConfig())
        let r = realm.objects(Node.self).sorted(by: sortPropertis)
        let array = Array(r)
        return array
    }

    public class func getActiveNode(isRankingSorted: Bool = true) -> [Node] {
        let predicate = NSPredicate(format: "nodeStatus == 'Active'")
        let sortPropertis = [
            SortDescriptor(keyPath: isRankingSorted ? "ranking" : "ratePA", ascending: isRankingSorted ? true : false),
            SortDescriptor(keyPath: isRankingSorted ? "ratePA" : "ranking", ascending: isRankingSorted ? true : false)
        ]
        let realm = try! Realm(configuration: RealmHelper.getConfig())
        let r = realm.objects(Node.self).filter(predicate).sorted(by: sortPropertis)
        let array = Array(r)
        return array
    }

    public class func getCandiateNode(isRankingSorted: Bool = true) -> [Node] {
        let predicate = NSPredicate(format: "nodeStatus == 'Candidate'")
        let sortPropertis = [
            SortDescriptor(keyPath: isRankingSorted ? "ranking" : "ratePA", ascending: isRankingSorted ? true : false),
            SortDescriptor(keyPath: isRankingSorted ? "ratePA" : "ranking", ascending: isRankingSorted ? true : false)
        ]
        let realm = try! Realm(configuration: RealmHelper.getConfig())
        let r = realm.objects(Node.self).filter(predicate).sorted(by: sortPropertis)
        let array = Array(r)
        return array
    }
}
