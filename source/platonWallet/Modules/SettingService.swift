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
        var URLString : String = AppConfig.NodeURL.defaultNodesURL.first!.nodeURL
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
            return AppConfig.NodeURL.defaultNodesURL.first!.nodeURL
        }
        return nodeURL
    }
    
    
    static func getCentralizationURL() -> String {

        return AppFramework.sharedInstance.AppEnvConfig.getConfigURLInfo().CenterRPCURL

        /*
        let testCentralizationURL =  AppConfig.ServerURL.HOST.TESTNET + AppConfig.ServerURL.PATH
        let devCentralizationURL = AppConfig.ServerURL.HOST.DEVNET + AppConfig.ServerURL.PATH
        let uatCentralizationURL =  AppConfig.ServerURL.HOST.UATNET + AppConfig.ServerURL.PATH
        let productCentralizationURL =  AppConfig.ServerURL.HOST.PRODUCTNET + AppConfig.ServerURL.PATH
        
        let url = self.getCurrentNodeURLString()
        if url == AppConfig.NodeURL.DefaultNodeURL_Alpha_V071 {
            return testCentralizationURL
        } else if url == AppConfig.NodeURL.DefaultNodeURL_UAT {
            return uatCentralizationURL
        } else if url == AppConfig.NodeURL.DefaultNodeURL_PRODUCT {
            return productCentralizationURL
        } else {
            return devCentralizationURL
        }
         */

    }
    
    func getNodes() -> [NodeInfo] {
        return NodeInfoPersistence.sharedInstance.getAll()
    }
    
    func addOrUpdateNode(_ node: NodeInfo) {
        NodeInfoPersistence.sharedInstance.add(node: node)
    }
    
    func deleteNodeList(_ list: [NodeInfo]) {
        NodeInfoPersistence.sharedInstance.deleteList(list)
    }
    
    func updateSelectedNode(_ node: NodeInfo) {
        getNodes().forEach { (item) in
            if item.id == node.id {
                NodeInfoPersistence.sharedInstance.update(node: item, isSelected: true)
            }else {
                NodeInfoPersistence.sharedInstance.update(node: item, isSelected: false)
            }
        }
    }
    
    func deleteNode(_ node: NodeInfo) {
        NodeInfoPersistence.sharedInstance.delete(node: node)
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
