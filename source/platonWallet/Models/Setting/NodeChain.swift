//
//  NodeChain.swift
//  platonWallet
//
//  Created by Admin on 7/11/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation

struct NodeChain {
    var nodeURLStr: String = ""
    var desc: String = ""
    var chainId: String = ""
    var hrp: String = ""
}

extension NodeChain {
    var isSelected: Bool {
        return chainId == SettingService.shareInstance.currentNodeChainId
    }
}
