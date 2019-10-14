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
    var delegate: String?
    var redeem: String?
    var availableDelegationBalance: String?
}

public struct DelegateDetail: Decodable {
    var nodeId: String
    var stakingBlockNum: String
    var delegationBlockNum: String
    var nodeName: String
    var website: String?
    var url: String?
    var nodeStatus: NodeStatus
    var redeem: String?
    var locked: String?
    var unLocked: String?
    var released: String?
    var sequence: String?
    var isInit: Bool = false
}

class DelegateDetailDel: Object {
    @objc dynamic var walletAddress: String = "" {
        didSet {
            compoundKey = compoundKeyValue()
        }
    }
    @objc dynamic var nodeId: String = "" {
        didSet {
            compoundKey = compoundKeyValue()
        }
    }
    @objc dynamic var delegationBlockNum: String = ""
    @objc dynamic var compoundKey: String = ""
    // 不同的链
    @objc dynamic var chainUrl: String? = ""

    override static func primaryKey() -> String? {
        return "compoundKey"
    }

    func compoundKeyValue() -> String {
        return "\(walletAddress)\(nodeId)"
    }

    required init() {
        super.init()
    }

    required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }

    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }

    convenience init(
        walletAddress: String,
        nodeId: String,
        delegationBlockNum: String
        ) {
        self.init()
        self.walletAddress = walletAddress
        self.nodeId = nodeId
        self.delegationBlockNum = delegationBlockNum
        self.compoundKey = self.compoundKeyValue()
    }

}

public struct DelegationValue: Decodable {
    var stakingBlockNum: String?
    var redeem: String?
    var locked: String?
    var unLocked: String?
    var released: String?
}

extension DelegationValue {
    func getDelegationValueAmount(index: Int) -> BigUInt? {
        switch index {
        case 0:
            return (BigUInt(locked ?? "0") ?? BigUInt.zero) + (BigUInt(unLocked ?? "0") ?? BigUInt.zero)
        case 1:
            return BigUInt(unLocked ?? "0")
        case 2:
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
