//
//  NodeSettingViewModel.swift
//  platonWallet
//
//  Created by juzix on 2019/2/21.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import UIKit

private let nodeURLReg = "^(http(s?)://)?([A-Z0-9a-z._%+-/:]{1,50})/rpc$"

class NodeStoreService {

    static let didSwitchNodeNotification = "didSwitchNodeNotification"

    static let share = NodeStoreService()

    var nodeList: [NodeChain] {
        let arr = AppConfig.NodeURL.defaultNodesURL.map { (tup) -> NodeChain in
            let nc = NodeChain(nodeURLStr: tup.nodeURL, desc: tup.desc, chainId: tup.chainId)
            return nc
        }
        return arr
    }

    private init() {

        //default setting

    }

    func switchNode(node: NodeChain) {
        SettingService.shareInstance.setCurrentNodeChainId(nodeChain: node)

        nodeWillSuccessSwitch()
        NotificationCenter.default.post(name: Notification.Name(NodeStoreService.didSwitchNodeNotification), object: self, userInfo: ["node": node])
    }

    func nodeWillSuccessSwitch() {
        WalletService.sharedInstance.refreshDB()

        if AssetVCSharedData.sharedData.walletList.count == 0 {
            (UIApplication.shared.delegate as? AppDelegate)?.gotoWalletCreateVC()
        }
    }
}
