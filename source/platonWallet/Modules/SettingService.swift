//
//  SettingService.swift
//  platonWallet
//
//  Created by matrixelement on 2018/11/2.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import Alamofire
import Localize_Swift

class SettingService {
    
    var nodeStorge: NodeInfoPersistence?
    
    var currentNodeURL : String?
    
    var currentVersion: RemoteVersion?
    
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
        var URLString : String = AppConfig.NodeURL.DefaultNodeURL_Alpha
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
        
        guard let nodeURL = SettingService.shareInstance.currentNodeURL else{
            return AppConfig.NodeURL.DefaultNodeURL_Alpha_V071
        }
        return nodeURL
    }
    
    
    static func getCentralizationURL() -> String {
        let CentralizationURL =  AppConfig.ServerURL.HOST.TESTNET + AppConfig.ServerURL.PATH
        let DebugCentralizationURL = AppConfig.ServerURL.HOST.DEVNET + AppConfig.ServerURL.PATH
        
        let url = self.getCurrentNodeURLString()
        if url == "http://192.168.9.190:1000/rpc" {
            return CentralizationURL
        } else {
            return DebugCentralizationURL
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
    
    
    public func getRemoteVersion(completion: PlatonCommonCompletion?) {
        let url = AppConfig.ServerURL.HOST.TESTNET +  "/config/aton-update.json"
        
        var request = URLRequest(url: try! url.asURL())
        request.httpMethod = "GET"
        request.timeoutInterval = requestTimeout
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        Alamofire.request(request).responseData { [weak self] response in
            switch response.result {
            case .success(let data):
                let decoder = JSONDecoder()
                let response = try? decoder.decode(RemoteVersionResponse.self, from: data)
                self?.currentVersion = response?.ios
                DispatchQueue.main.async {
                    completion?(.success, nil)
                }
            case .failure(_):
                DispatchQueue.main.async {
                    completion?(.fail(-1, nil), nil)
                }
            }
        }
    }
    
}
