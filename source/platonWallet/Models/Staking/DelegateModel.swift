//
//  DelegateModel.swift
//  platonWallet
//
//  Created by Admin on 9/8/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import Localize_Swift
import BigInt
import platonWeb3

struct JSONResponse<T: Decodable>: Decodable {
    var data: T
}

struct Delegate: Decodable {
    var walletAddress: String
    var delegated: String?
    var cumulativeReward: String?
    var withdrawReward: String?
}

struct TotalDelegate: Decodable {
    var availableDelegationBalance: String?
    var delegated: String?
    var item: [DelegateDetail]?

    var availableDelegationBalanceValue: String {
        return availableDelegationBalance?.vonToLATString ?? "--"
    }

    var delegatedValue: String {
        return delegated?.vonToLATString ?? "--"
    }
}

struct DelegateDetail: Decodable {
    var nodeId: String
    var nodeName: String
    var website: String?
    var url: String?
    var nodeStatus: NodeStatus
    var delegated: String?
    var released: String?
    var sequence: String?
    var isInit: Bool = false
    var isConsensus: Bool = false
    var withdrawReward: String?

    var withdrawRewardValue: String {
        return withdrawReward?.vonToLATString ?? "--"
    }

    var withdrawRewardBInt: BigUInt {
        return BigUInt(withdrawReward ?? "0") ?? BigUInt.zero
    }

    var releasedBInt: BigUInt {
        return BigUInt(released ?? "0") ?? BigUInt.zero
    }
}

struct Delegation: Decodable {
    var minDelegation: String?
    var deleList: [DelegationValue]
}

extension Delegation {
    var minDelegationBInt: BigUInt {
        guard let minDelegationString = minDelegation else { return BigUInt(10).multiplied(by: PlatonConfig.VON.LAT) }
        return BigUInt(minDelegationString) ?? BigUInt(10).multiplied(by: PlatonConfig.VON.LAT)
    }
}

struct DelegationValue: Decodable {
    var stakingBlockNum: String?
    var delegated: String?
    var released: String?
    var gasLimit: String?
    var gasPrice: String?

    var gasLimitBInt: BigUInt {
        return BigUInt(gasLimit ?? "0") ?? BigUInt.zero
    }

    var gasPriceBInt: BigUInt {
        return BigUInt(gasPrice ?? "0") ?? BigUInt.zero
    }

    var gasUsedBInt: BigUInt {
        return gasLimitBInt.multiplied(by: gasPriceBInt)
    }

    var gasUsed: String {
        return gasUsedBInt.description
    }
}

extension DelegationValue {
    func getDelegationValueAmount(index: Int) -> BigUInt? {
        switch index {
        case 0:
            return BigUInt(delegated ?? "0")
        case 1:
            return BigUInt(released ?? "0")
        default:
            return nil
        }
    }
}

// 是否能委托response
public struct CanDelegation: Decodable {
    var free: String?
    var lock: String?
    var canDelegation: Bool = true
    var message: Message?
    var minDelegation: String?

    public enum Message: String, Decodable {
        case amountGreaterZero = "1"
        case nodeExitingOrExited = "2"
        case nodeAssociationWallet = "3"
        case balanceZero = "4"

        public var localizedDesciption: String? {
            switch self {
            case .amountGreaterZero:
                return Localized("delegate_error_result_amountzero")
            case .nodeExitingOrExited:
                return Localized("delegate_error_result_nodeexit")
            case .nodeAssociationWallet:
                return Localized("delegate_error_result_associate")
            case .balanceZero:
                return Localized("delegate_error_result_balancezero")
            }
        }
    }
}

extension CanDelegation {
    var minDelegationBInt: BigUInt {
        guard let minDelegationString = minDelegation else { return BigUInt(10).multiplied(by: PlatonConfig.VON.LAT) }
        return BigUInt(minDelegationString) ?? BigUInt(10).multiplied(by: PlatonConfig.VON.LAT)
    }

    var freeBigUInt: BigUInt {
        guard let freeString = free else { return BigUInt.zero }
        return BigUInt(freeString) ?? BigUInt.zero
    }
}

// 委托记录
public struct DelegateRecord: Decodable {
    var delegateTime: String
    var url: String
    var walletAddress: String
    var nodeName: String
    var nodeAddress: String
    var number: Int
    var sequence: Int
    var delegateStatus: DelegateStatus
}

// 委托交易状态
public enum DelegateStatus: String, Decodable {
    case confirm
    case delegateSucc
    case delegateFail
    case redeem
    case redeemSucc
    case redeemFail
}

enum RewardStatus {
    case none // 无可用领取
    case unclaim // 待领取
    case claiming // 领取中
}
