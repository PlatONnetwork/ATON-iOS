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
    
    func addNode(_ node: NodeInfo) {
        
        nodeStorge.add(node: node)
        
    }
    
    func updateNode(_ node: NodeInfo, isSelected: Bool) {
        nodeStorge.update(node: node, isSelected: isSelected)
    }
    
    func deleteNode(_ node: NodeInfo) {
        nodeStorge.delete(node: node)
    }
    
    
}
