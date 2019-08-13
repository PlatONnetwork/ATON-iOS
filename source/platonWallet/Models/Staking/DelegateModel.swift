//
//  DelegateModel.swift
//  platonWallet
//
//  Created by Admin on 9/8/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation

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
