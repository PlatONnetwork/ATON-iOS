//
//  Web3Helper.swift
//  platonWallet
//
//  Created by matrixelement on 25/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import platonWeb3


var web3 = Web3(rpcURL: Web3Helper.getRpcURL(), chainId: "101")

struct Web3Helper {
    
    static func switchRpcURL(_ url: String, completion:@escaping (_ success: Bool)->Void) {
        
        let newWeb3 = Web3(rpcURL: url, chainId: "101")
        var isCallback = false
        newWeb3.platon.blockNumber { (resp) in
            
            DispatchQueue.main.async {
                
                if isCallback {
                    return
                }
                
                if resp.status.isSuccess {
                    web3 = newWeb3
                    completion(true)
                }else {
                    completion(false)
                }
                isCallback = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            
            if isCallback {
                return
            }
            completion(false)
            isCallback = true
        }
        
    }
    
    static func switchRpcURL(_ url: String, succeedCb:@escaping ()->Void, failedCb:@escaping ()->Void) {
        
        let newWeb3 = Web3(rpcURL: url, chainId: "101")
         
        var isCallback = false 
        
        newWeb3.platon.blockNumber { (resp) in
            
            DispatchQueue.main.async {
                
                if isCallback {
                    return
                }
                
                if resp.status.isSuccess {
                    web3 = newWeb3
                    succeedCb()
                }else {
                    failedCb()
                }
                isCallback = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            
            if isCallback {
                return
            }
            
            failedCb()
            isCallback = true
        }
    }
    
    static func getRpcURL() -> String {
        if AppFramework.sharedInstance.AppEnvConfig == .Dev ||
            AppFramework.sharedInstance.AppEnvConfig == .Test ||
            AppFramework.sharedInstance.AppEnvConfig == .Production_Test ||
            AppFramework.sharedInstance.AppEnvConfig == .Production_main{
            return AppFramework.sharedInstance.AppEnvConfig.getConfigURLInfo().NodeRPCURL
        }
        guard let node = SettingService.shareInstance.getSelectedNodes() else { return "" }
        return node.nodeURLStr
    }
    
}

