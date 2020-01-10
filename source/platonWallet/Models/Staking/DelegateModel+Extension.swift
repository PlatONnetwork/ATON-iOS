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

    var walletAvatar: UIImage? {
        let localWallet = (AssetVCSharedData.sharedData.walletList as! [Wallet]).filter { $0.address.lowercased() == walletAddress.lowercased() }.first
        guard let avatarString = localWallet?.address.walletAddressLastCharacterAvatar() else { return nil }
        return UIImage(named: avatarString)
    }

    var delegateValue: String {
        return delegated?.vonToLATString ?? "--"
    }

    var cumulativeRewardValue: String {
        return cumulativeReward?.vonToLATString ?? "--"
    }

    var withdrawRewardValue: String {
        return withdrawReward?.vonToLATString ?? "--"
    }

    var status: RewardStatus {
        let txs = TransferPersistence.getRewardPendingTransaction(address: walletAddress)
        if txs.count > 0 {
            return .claiming
        }

        if let withdrawRewardBigUInt = BigUInt(withdrawReward ?? "0"), withdrawRewardBigUInt > BigUInt.zero {
            return .unclaim
        }

        return .none
    }

    var freeBalanceBInt: BigUInt {
        guard
            let balance = AssetService.sharedInstace.balances.first(where: { $0.addr.lowercased() == walletAddress.lowercased() }),
            let freeBInt = BigUInt(balance.free ?? "0") else {
                return BigUInt.zero
        }
        return freeBInt
    }

    var freeBalanceValue: String {
        return Localized("claim_comfirm_balance") + "：" + (freeBalanceBInt.description.vonToLATString ?? "0.00").ATPSuffix()
    }
}

extension DelegateDetail {

    var status: (String, UIColor) {
        switch nodeStatus {
        case .Active:
            return isConsensus ? (Localized("node_status_consensus"), status_orange_color) : (nodeStatus.description, status_blue_color)
        case .Candidate:
            return (nodeStatus.description, status_green_color)
        case .Exiting:
            return (nodeStatus.description, status_darkgray_color)
        case .Exited:
            return (nodeStatus.description, status_lightgray_color)
        }
    }

    var delegatedString: String {
        if delegated == "0" {
            return "--"
        }
        return delegated?.vonToLATString ?? "--"
    }

    var releasedString: String {
        if released == "0" {
            return "--"
        }
        return released?.vonToLATString ?? "--"
    }

    func isExistWallet(address: String) -> Bool {
        let localWallet = (AssetVCSharedData.sharedData.walletList as! [Wallet]).filter { $0.address.lowercased() == address.lowercased() }.first
        return localWallet != nil
    }


}

extension DelegateDetail {
    func delegateToNode() -> Node? {
        return Node(nodeId: nodeId, ranking: nil, name: nodeName, deposit: nil, url: url, ratePA: nil, nStatus: nodeStatus, isInit: false, isConsensus: isConsensus, delegateSum: nil, delegate: nil)
    }
}

extension DelegationValue {
    var deposit: String {
        let depositBigInt = BigUInt(delegated ?? "0")!
        return String(depositBigInt)
    }
}
