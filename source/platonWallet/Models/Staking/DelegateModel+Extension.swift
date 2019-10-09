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
        guard let abalance = availableDelegationBalance else {
            return "--"
        }
        return abalance.vonToLATString ?? "--"
    }
    
    var walletAvatar: UIImage? {
        let localWallet = (AssetVCSharedData.sharedData.walletList as! [Wallet]).filter { $0.address.lowercased() == walletAddress.lowercased() }.first
        guard let avatarString = localWallet?.address.walletAddressLastCharacterAvatar() else { return nil }
        return UIImage(named: avatarString)
    }
    
    var delegateValue: String {
        return delegate?.vonToLATString ?? "0"
    }
    
    var redeemValue: String {
        return redeem?.vonToLATString ?? "0"
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
        if locked == "0" {
            return "--"
        }
        return locked?.vonToLATString ?? "--"
    }
    
    var unlockedString: String {
        if unLocked == "0" {
            return "--"
        }
        return unLocked?.vonToLATString ?? "--"
    }
    
    var releasedString: String {
        if released == "0" {
            return "--"
        }
        return released?.vonToLATString ?? "--"
    }
    
    var undelegateString: String {
        if redeem == "0" {
            return "--"
        }
        return redeem?.vonToLATString ?? "--"
    }
    
    func getDelegateButtonIsEnable(address: String) -> Bool {
        let localWallet = (AssetVCSharedData.sharedData.walletList as! [Wallet]).filter { $0.address.lowercased() == address.lowercased() }.first
        return localWallet != nil
    }
    
    // 第一个值为是否显示赎回
    var rightButtonStatus: (Bool, Bool) {
        if (locked == nil || locked == "0") && (unLocked == nil || unLocked == "0") && (released == nil || released == "0") && (redeem == nil || redeem == "0") {
            return (false, true)
        } else {
            if (locked == nil || locked == "0") && (unLocked == nil || unLocked == "0") && (released == nil || released == "0") {
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
