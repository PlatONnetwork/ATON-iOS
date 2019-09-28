//
//  EvnConfig.swift
//  platonWallet
//
//  Created by Ned on 2019/9/17.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation

struct ConfigURLInfo {
    var CenterRPCURL: String = ""
    var NodeRPCURL: String = ""
    var chainID: String = ""
}

enum EnvConfig {
    case Dev
    case Test
    case Production_Test
    case Production_main
    
    func getConfigURLInfo() -> ConfigURLInfo {
        switch self {
        case .Dev:
            let CenterRPCURL = ""
            let NodeRPCURL = ""
            let chainId = ""
            return ConfigURLInfo(CenterRPCURL: CenterRPCURL,
                             NodeRPCURL: NodeRPCURL,
                                 chainID: chainId)
        case .Test:
            let CenterRPCURL = ""
            let NodeRPCURL = ""
            let chainId = ""
            return ConfigURLInfo(CenterRPCURL: CenterRPCURL,
                                 NodeRPCURL: NodeRPCURL,
                                 chainID: chainId)
        case .Production_Test:
            let CenterRPCURL = ""
            let NodeRPCURL = ""
            let chainId = ""
            return ConfigURLInfo(CenterRPCURL: CenterRPCURL,
                                 NodeRPCURL: NodeRPCURL,
                                 chainID: chainId)
        case .Production_main:
            let CenterRPCURL = ""
            let NodeRPCURL = ""
            let chainId = ""
            return ConfigURLInfo(CenterRPCURL: CenterRPCURL,
                                 NodeRPCURL: NodeRPCURL,
                                 chainID: chainId)
        }
    }
    
}
