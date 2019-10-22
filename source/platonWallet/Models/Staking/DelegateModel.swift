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

public struct JSONResponse<T: Decodable>: Decodable {
    var data: T
}

public struct Delegate: Decodable {
    var walletAddress: String
    var delegated: String?
    var availableDelegationBalance: String?
}

public struct DelegateDetail: Decodable {
    var nodeId: String
    var nodeName: String
    var website: String?
    var url: String?
    var nodeStatus: NodeStatus
    var delegated: String?
    var released: String?
    var sequence: String?
    var isInit: Bool = false
}

public struct DelegationValue: Decodable {
    var stakingBlockNum: String?
    var delegated: String?
    var released: String?
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
