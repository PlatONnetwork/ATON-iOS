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

    var currentNodeChainId: String {
        let standard = UserDefaults.standard
        let defaultChainIds = AppConfig.NodeURL.defaultNodesURL.map { $0.chainId }
        guard
            let chainId = standard.string(forKey: AppConfig.LocalKeys.SelectedChainIdKey), defaultChainIds.contains(chainId) else {
            if let defaultNode = AppConfig.NodeURL.defaultNodesURL.first(where: { $0.isSelected == true }) {
                standard.set(defaultNode.chainId, forKey: AppConfig.LocalKeys.SelectedChainIdKey)
                standard.synchronize()
                return defaultNode.chainId
            } else {
                let chainId = AppConfig.NodeURL.defaultNodesURL.first!.chainId
                standard.set(chainId, forKey: AppConfig.LocalKeys.SelectedChainIdKey)
                standard.synchronize()
                return chainId
            }
        }
        return chainId
    }

    var remoteVersion: RemoteVersion?
    var remoteConfig: RemoteConfig?

    static let shareInstance = SettingService()

    func getCentralizationHost() -> String {
        let testHost =  AppConfig.ServerURL.HOST.TESTNET
        let devHost = AppConfig.ServerURL.HOST.DEVNET
        let uatHost =  AppConfig.ServerURL.HOST.UATNET
        let proHost =  AppConfig.ServerURL.HOST.PRODUCTNET

        let chainId = SettingService.shareInstance.currentNodeChainId
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

    func setCurrentNodeChainId(nodeChain: NodeChain) {
        let standard = UserDefaults.standard
        guard
            let chainId = standard.string(forKey: AppConfig.LocalKeys.SelectedChainIdKey),
            chainId != nodeChain.chainId
            else {
                return
        }
        standard.set(nodeChain.chainId, forKey: AppConfig.LocalKeys.SelectedChainIdKey)
        standard.synchronize()
    }
}
