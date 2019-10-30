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

    var remoteVersion: RemoteVersion?
    var remoteConfig: RemoteConfig?

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

    func getCentralizationHost() -> String {
        let testHost =  AppConfig.ServerURL.HOST.TESTNET
        let devHost = AppConfig.ServerURL.HOST.DEVNET
        let uatHost =  AppConfig.ServerURL.HOST.UATNET
        let proHost =  AppConfig.ServerURL.HOST.PRODUCTNET

        let chainId = SettingService.shareInstance.getCurrentChainId()
        #if UAT
        if chainId == AppConfig.ChainID.PRODUCT {
            return testHost
        } else {
            return devHost
        }
        #else
        if chainId == AppConfig.ChainID.PRODUCT {
            return proHost
        } else {
            return uatHost
        }
        #endif
    }

    static func getCentralizationURL() -> String {
        return SettingService.shareInstance.getCentralizationHost() + AppConfig.ServerURL.PATH
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
}
