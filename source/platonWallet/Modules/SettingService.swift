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
    
    static func threadSafeGetCurrentNodeURLString() -> String{
        
        if Thread.current == .main{
            return self.getCurrentNodeURLString()
        }
        
        let semaphore = DispatchSemaphore(value: 1)
        var URLString : String = ""
        if semaphore.wait(timeout: .now() + 3) == DispatchTimeoutResult.timedOut{
            return URLString
        }
        DispatchQueue.main.async {
            URLString = self.getCurrentNodeURLString()
            semaphore.signal()
        }
        return URLString
    }
    
    static func getCurrentNodeURLString() -> String{
        if let urlString = SettingService.shareInstance.getSelectedNodes()?.nodeURLStr{
            return urlString
        }
        return DefaultAlphaNodeURL
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
            if item.id == node.id {
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
