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

public struct JSONResponse<T: Decodable>: Decodable {
    var data: T
}

public struct Delegate: Decodable {
    var walletAddress: String
    var delegate: String
    var redeem: String
}

public struct DelegateDetail: Decodable {
    var nodeId: String
    var stakingBlockNum: String
    var nodeName: String
    var website: String?
    var url: String?
    var nodeStatus: NodeStatus
    var redeem: String?
    var locked: String?
    var unlocked: String?
    var released: String?
    var sequence: String?
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
    @objc dynamic var stakingBlockNum: String = ""
    @objc dynamic var compoundKey: String = ""
    // 不同的链
    @objc dynamic var chainUrl: String? = SettingService.getCurrentNodeURLString()
    
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
        stakingBlockNum: String
        ) {
        self.init()
        self.walletAddress = walletAddress
        self.nodeId = nodeId
        self.stakingBlockNum = stakingBlockNum
        self.compoundKey = self.compoundKeyValue()
    }
    
}

public struct DelegationValue: Decodable {
    var redeem: String?
    var locked: String?
    var unLocked: String?
    var released: String?
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
