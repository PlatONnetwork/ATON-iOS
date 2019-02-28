//
//  SettingService.swift
//  platonWallet
//
//  Created by matrixelement on 2018/11/2.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation

class SettingService {
    
    var nodeStorge: NodeInfoPersistence!
    
    static let shareInstance = SettingService()
    private init() {
        
    }
    
    func getSelectedNodes() -> NodeInfo? {
        
        let list = getNodes()
         
        guard list.count > 0 else { return nil }
        
        guard let i = list.firstIndex(where: { (item) -> Bool in
            return item.isSelected
        }) else {
            return nil
        }
        
        return list[i]
    }
    
    func getNodes() -> [NodeInfo] {
        
        return nodeStorge.getAll()
        
    }
    
    func addOrUpdateNode(_ node: NodeInfo) {
        
        nodeStorge.add(node: node)
    }
    
    func deleteNodeList(_ list: [NodeInfo]) {
        nodeStorge.deleteList(list)
    }
    
//    func updateNode(_ node: NodeInfo, isSelected: Bool) {
//        
//        nodeStorge.update(node: node, isSelected: isSelected)
//    }
    
    func updateSelectedNode(_ node: NodeInfo) {
        getNodes().forEach { (item) in
            if item.nodeURLStr == node.nodeURLStr {
                nodeStorge.update(node: item, isSelected: true)
            }else {
                nodeStorge.update(node: item, isSelected: false)
            }
        }
    }
    
    func deleteNode(_ node: NodeInfo) {
        nodeStorge.delete(node: node)
    }
    
    
}
