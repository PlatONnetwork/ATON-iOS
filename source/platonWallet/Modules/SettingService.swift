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

    var currentNodeChainId: String?

    var currentVersion: RemoteVersion?

    static let shareInstance = SettingService()

    private init() {
        currentNodeChainId = getSelectedNodes()?.chainId
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

//    static func threadSafeGetCurrentNodeURLString() -> String {
//
//        if Thread.current == .main {
//            return self.getCurrentNodeURLString()
//        }
//
//        let semaphore = DispatchSemaphore(value: 0)
//        var URLString : String = AppConfig.NodeURL.defaultNodesURL.first!.nodeURL
//        DispatchQueue.main.async {
//            URLString = self.getCurrentNodeURLString()
//            semaphore.signal()
//        }
//        if semaphore.wait(timeout: .now() + 3) == DispatchTimeoutResult.timedOut {
//            return URLString
//        }
//
//        return URLString
//    }

    func getCurrentChainId() -> String {
        if let chainId = currentNodeChainId {
            return chainId
        }

        if let selectedNode = getSelectedNodes() {
            currentNodeChainId = selectedNode.chainId
            return selectedNode.chainId
        }

        if let defaultNode = AppConfig.NodeURL.defaultNodesURL.first(where: { $0.isSelected == true }) {
            currentNodeChainId = defaultNode.chainId
            return defaultNode.chainId
        }

        currentNodeChainId = AppConfig.NodeURL.defaultNodesURL.first!.chainId
        return currentNodeChainId!
    }

    static func getCentralizationURL() -> String {
        let testCentralizationURL =  AppConfig.ServerURL.HOST.TESTNET + AppConfig.ServerURL.PATH
        let devCentralizationURL = AppConfig.ServerURL.HOST.DEVNET + AppConfig.ServerURL.PATH
        let uatCentralizationURL =  AppConfig.ServerURL.HOST.UATNET + AppConfig.ServerURL.PATH
        let productCentralizationURL =  AppConfig.ServerURL.HOST.PRODUCTNET + AppConfig.ServerURL.PATH

        let chainId = SettingService.shareInstance.getCurrentChainId()
        #if UAT
        if chainId == AppConfig.ChainID.PRODUCT {
            return testCentralizationURL
        } else {
            return devCentralizationURL
        }
        #else
        if chainId == AppConfig.ChainID.PRODUCT {
            return productCentralizationURL
        } else {
            return uatCentralizationURL
        }
        #endif
    }

    func getNodes() -> [NodeInfo] {
        return NodeInfoPersistence.sharedInstance.getAll()
    }

    func addOrUpdateNode(_ node: NodeInfo) {
        NodeInfoPersistence.sharedInstance.add(node: node)
    }

    func updateSelectedNode(_ node: NodeInfo) {
        getNodes().forEach { (item) in
            if item.id == node.id {
                NodeInfoPersistence.sharedInstance.update(node: item, isSelected: true)
            } else {
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
            case .failure:
                DispatchQueue.main.async {
                    completion?(.fail(-1, nil), nil)
                }
            }
        }
    }

}
