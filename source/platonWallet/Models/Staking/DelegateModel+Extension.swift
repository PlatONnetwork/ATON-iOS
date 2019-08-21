//
//  DelegateModel+Extension.swift
//  platonWallet
//
//  Created by Admin on 10/8/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import UIKit
import BigInt
import Localize_Swift

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
        return (delegate ?? "0").vonToLATString
    }
    
    var redeemValue: String {
        return (redeem ?? "0").vonToLATString
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
        return locked?.vonToLATString ?? "--"
    }
    
    var unlockedString: String {
        return unlocked?.vonToLATString ?? "--"
    }
    
    var releasedString: String {
        return released?.vonToLATString ?? "--"
    }
    
    var undelegateString: String {
        return redeem?.vonToLATString ?? "--"
    }
    
    func getLeftButtonIsEnable(address: String) -> Bool {
        let localWallet = (AssetVCSharedData.sharedData.walletList as! [Wallet]).filter { $0.key?.address.lowercased() == address.lowercased() }.first
        return localWallet != nil
    }
    
    // 第一个值为是否显示赎回
    var rightButtonStatus: (Bool, Bool) {
        if locked == nil && unlocked == nil && released == nil && redeem == nil {
            return (false, true)
        } else {
            if locked == nil && unlocked == nil && released == nil {
                return (true, false)
            } else {
                return (true, true)
            }
        }
    }
}

extension DelegateDetail {
    func delegateToNode() -> Node? {
        return Node(nodeId: nodeId, ranking: nil, name: nodeName, deposit: nil, url: url, ratePA: nil, nStatus: nodeStatus, isInit: false)
    }
}

extension DelegationValue {
    var deposit: String {
        let depositBigInt = BigUInt(locked ?? "0")! + BigUInt(unLocked ?? "0")!
        return String(depositBigInt)
    }
}
