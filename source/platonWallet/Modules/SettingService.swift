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
import platonWeb3

class SettingService {
    var currentNodeHrp: String {
        let standard = UserDefaults.standard
        let defaultHrps = AppConfig.NodeURL.defaultNodesURL.map { $0.hrp }
        guard
            let hrp = standard.string(forKey: LocalKeys.SelectedHrpKey), defaultHrps.contains(hrp) else {
                if let defaultNode = AppConfig.NodeURL.defaultNodesURL.first(where: { $0.isSelected == true }) {
                    standard.set(defaultNode.hrp, forKey: LocalKeys.SelectedHrpKey)
                    standard.synchronize()
                    return defaultNode.hrp
                } else {
                    let hrp = AppConfig.NodeURL.defaultNodesURL.first!.hrp
                    standard.set(hrp, forKey: LocalKeys.SelectedHrpKey)
                    standard.synchronize()
                    return hrp
                }
        }
        return hrp
    }
    
    var currentNodeChainId: String {
        let standard = UserDefaults.standard
        let defaultChainIds = AppConfig.NodeURL.defaultNodesURL.map { $0.chainId }
        guard
            let chainId = standard.string(forKey: LocalKeys.SelectedChainIdKey), defaultChainIds.contains(chainId) else {
                if let defaultNode = AppConfig.NodeURL.defaultNodesURL.first(where: { $0.isSelected == true }) {
                    standard.set(defaultNode.chainId, forKey: LocalKeys.SelectedChainIdKey)
                    standard.synchronize()
                    return defaultNode.chainId
                } else {
                    let chainId = AppConfig.NodeURL.defaultNodesURL.first!.chainId
                    standard.set(chainId, forKey: LocalKeys.SelectedChainIdKey)
                    standard.synchronize()
                    return chainId
                }
        }
        return chainId
    }
    
    var currentNetworkDesc: String {
        let currentNode = AppConfig.NodeURL.defaultNodesURL.first(where: { $0.chainId == currentNodeChainId })
        guard let desc = currentNode?.desc else {
            return ""
        }
        return desc
    }
    
    var currentNetworkName: String {
        return Localized(currentNetworkDesc)
    }
    
    var remoteVersion: RemoteVersion?
    var remoteConfig: RemoteConfig?
    
    static let shareInstance = SettingService()
    
    func getCentralizationHost() -> String {
        let chainId = SettingService.shareInstance.currentNodeChainId
        #if ENVIROMENT_DEV // 对应0.13.0及以前的UAT
        if chainId == AppConfig.ChainID.TEST1 {
            return AppConfig.ServerURL.HOST.TESTNET
        } else {
            return AppConfig.ServerURL.HOST.DEVNET
        }
        #elseif ENVIROMENT_UAT // 对应0.13.0及以前的PARALLELNET
        return AppConfig.ServerURL.HOST.UATNET
        #else
        if chainId == AppConfig.ChainID.VERSION_MAINTESTNET {
            return AppConfig.ServerURL.HOST.MAINTESTNET
        } else {
            return AppConfig.ServerURL.HOST.MAINNET
        }
        #endif
    }
    
    static func getCentralizationURL() -> String {
        return SettingService.shareInstance.getCentralizationHost() + AppConfig.ServerURL.PATH
    }
    
    func setCurrentNodeChainId(nodeChain: NodeChain) {
        let standard = UserDefaults.standard
        guard
            let chainId = standard.string(forKey: LocalKeys.SelectedChainIdKey),
            chainId != nodeChain.chainId
            else {
                return
        }
        standard.set(nodeChain.chainId, forKey: LocalKeys.SelectedChainIdKey)
        standard.synchronize()
    }
    
    func setCurrentNodeHrp(nodeChain: NodeChain) {
        let standard = UserDefaults.standard
        guard
            let hrp = standard.string(forKey: LocalKeys.SelectedHrpKey),
            hrp != nodeChain.hrp
            else {
                return
        }
        standard.set(nodeChain.hrp, forKey: LocalKeys.SelectedHrpKey)
        standard.synchronize()
    }
    
    var thresholdValue: BigUInt {
        get {
            if let value = UserDefaults.standard.object(forKey: LocalKeys.ReminderThresholdValue) as? String {
                return BigUInt(stringLiteral: value)
            }
            UserDefaults.standard.set((BigUInt(1000)*PlatonConfig.VON.LAT).description, forKey: LocalKeys.ReminderThresholdValue)
            UserDefaults.standard.synchronize()
            return BigUInt(1000)*PlatonConfig.VON.LAT
        }
        set {
            UserDefaults.standard.set(newValue.description, forKey: LocalKeys.ReminderThresholdValue)
            UserDefaults.standard.synchronize()
        }
    }
    
    var isResendReminder: Bool {
        get {
            if let value = UserDefaults.standard.object(forKey: LocalKeys.isOpenResendReminder) as? Bool {
                return value
            }
            UserDefaults.standard.set(true, forKey: LocalKeys.isOpenResendReminder)
            UserDefaults.standard.synchronize()
            return true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: LocalKeys.isOpenResendReminder)
            UserDefaults.standard.synchronize()
        }
    }
}
