//
//  DelegateModel+Extension.swift
//  platonWallet
//
//  Created by Admin on 10/8/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import UIKit

extension Delegate {
    var walletName: String {
        return AssetVCSharedData.sharedData.getWalletName(for: walletAddress) ?? "--"
    }
    
    var balance: String {
        let localWallet = (AssetVCSharedData.sharedData.walletList as! [Wallet]).filter { $0.key?.address == walletAddress }.first
        return localWallet?.balance ?? "0.00"
    }
    
    var walletAvatar: UIImage? {
        let localWallet = (AssetVCSharedData.sharedData.walletList as! [Wallet]).filter { $0.key?.address == walletAddress }.first
        guard let avatarString = localWallet?.key?.address.walletAddressLastCharacterAvatar() else { return nil }
        return UIImage(named: avatarString)
    }
    
    var delegateValue: String {
        return delegate.vonToLAT
    }
    
    var redeemValue: String {
        return redeem.vonToLAT
    }
}

extension DelegateDetail {
    
    var status: (String, UIColor) {
        switch nodeStatus {
        case .Active:
            return (nodeStatus.description, status_blue_color)
        case .Candidate:
            return (nodeStatus.description, status_green_color)
        case .Exiting:
            return (nodeStatus.description, status_darkgray_color)
        case .Exited:
            return (nodeStatus.description, status_lightgray_color)
        }
    }
    
    var lockedString: String {
        return locked?.vonToLAT ?? "--"
    }
    
    var unlockedString: String {
        return unlocked?.vonToLAT ?? "--"
    }
    
    var releasedString: String {
        return released?.vonToLAT ?? "--"
    }
    
    var undelegateString: String {
        return redeem?.vonToLAT ?? "--"
    }
    
    
}

extension DelegateDetail {
    func delegateToNode() -> Node? {
        return Node(nodeId: nodeId, ranking: nil, name: nodeName, deposit: nil, url: url, ratePA: nil, nodeStatus: nodeStatus, isInit: false)
    }
}
