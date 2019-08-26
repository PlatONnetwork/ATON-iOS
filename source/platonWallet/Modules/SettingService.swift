//
//  SettingService.swift
//  platonWallet
//
//  Created by matrixelement on 2018/11/2.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation

class SettingService {
    
    static let debugBaseURL = "http://192.168.9.190:443/app-203/v0700/"
    
    var nodeStorge: NodeInfoPersistence?
    
    var currentNodeURL : String?
    
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
        
        let semaphore = DispatchSemaphore(value: 0)
        var URLString : String = DefaultNodeURL_Alpha
        DispatchQueue.main.async {
            URLString = self.getCurrentNodeURLString()
            semaphore.signal()
        }
        if semaphore.wait(timeout: .now() + 3) == DispatchTimeoutResult.timedOut{
            return URLString
        }
        
        return URLString
    }
    
    static func getCurrentNodeURLString() -> String{
        
        if SettingService.shareInstance.currentNodeURL == nil{
            SettingService.shareInstance.currentNodeURL = SettingService.shareInstance.getSelectedNodes()?.nodeURLStr
        }
        
        guard SettingService.shareInstance.currentNodeURL != nil else{
            return DefaultNodeURL_Alpha_deprecated
        }
        
        return SettingService.shareInstance.currentNodeURL!
    }
    
    
    static func getCentralizationURL() -> String {
        let DEBUG_CentralizationURL = "http://192.168.9.190:10061/app-203/v060"
        let DefaultCentralizationURL = "https://aton.platon.network/"
        
        let url = self.getCurrentNodeURLString()
        if url == DefaultNodeURL_Alpha{
            return DefaultCentralizationURL + "app-" + self.getChainID() + "/v060"
        }else if url == DefaultNodeURL_Beta{
            return DefaultCentralizationURL + "app-" + self.getChainID() + "/v060"
        }else if url == "http://192.168.120.81:6789"{
            return DEBUG_CentralizationURL
        }
        return DefaultCentralizationURL + "app-" + self.getChainID() + "/v060"
    }
    
    // v0.6.2 新增获取链ID
    static func getChainID() -> String {
        let url = getCurrentNodeURLString()
        switch url {
        case DefaultNodeURL_Alpha:
            return "103"
        case DefaultNodeURL_Beta:
            return "104"
        default:
            return "203"
        }
    }
    
    func getNodes() -> [NodeInfo] {
        return nodeStorge?.getAll() ?? []
        
    }
    
    func addOrUpdateNode(_ node: NodeInfo) {
        
        nodeStorge?.add(node: node)
    }
    
    func deleteNodeList(_ list: [NodeInfo]) {
        nodeStorge?.deleteList(list)
    }
    
    func updateSelectedNode(_ node: NodeInfo) {
        getNodes().forEach { (item) in
            if item.id == node.id {
                nodeStorge?.update(node: item, isSelected: true)
            }else {
                nodeStorge?.update(node: item, isSelected: false)
            }
        }
    }
    
    func deleteNode(_ node: NodeInfo) {
        nodeStorge?.delete(node: node)
    }
    
    
}
