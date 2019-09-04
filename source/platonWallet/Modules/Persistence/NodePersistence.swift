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
        let _ = nodes.map { $0.chainUrl = SettingService.getCurrentNodeURLString() }
        
        RealmWriteQueue.async {
            autoreleasepool(invoking: {
                let realm = RealmHelper.getNewRealm()
                realm.beginWrite()
                realm.delete(realm.objects(Node.self))
                realm.add(nodes, update: true)
                try? realm.commitWrite()
                DispatchQueue.main.async {
                    completion?()
                }
            })
        }
    }
    
    public class func getAll(isRankingSorted: Bool = true) -> [Node] {
        let sortPropertis = [
            SortDescriptor(keyPath: isRankingSorted ? "ranking" : "ratePA", ascending: true),
            SortDescriptor(keyPath: isRankingSorted ? "ratePA" : "ranking", ascending: true)
        ]
        RealmInstance!.refresh()
        let r = RealmInstance!.objects(Node.self).sorted(by: sortPropertis)
        return Array(r)
    }
    
    public class func getActiveNode(isRankingSorted: Bool = true) -> [Node] {
        RealmInstance!.refresh()
        let predicate = NSPredicate(format: "nodeStatus == 'Active'")
        let sortPropertis = [
            SortDescriptor(keyPath: isRankingSorted ? "ranking" : "ratePA", ascending: true),
            SortDescriptor(keyPath: isRankingSorted ? "ratePA" : "ranking", ascending: true)
        ]
        let r = RealmInstance!.objects(Node.self).filter(predicate).sorted(by: sortPropertis)
        return Array(r)
    }
    
    public class func getCandiateNode(isRankingSorted: Bool = true) -> [Node] {
        RealmInstance!.refresh()
        let predicate = NSPredicate(format: "nodeStatus == 'Candidate'")
        let sortPropertis = [
            SortDescriptor(keyPath: isRankingSorted ? "ranking" : "ratePA", ascending: true),
            SortDescriptor(keyPath: isRankingSorted ? "ratePA" : "ranking", ascending: true)
        ]
        let r = RealmInstance!.objects(Node.self).filter(predicate).sorted(by: sortPropertis)
        return Array(r)
    }
}
