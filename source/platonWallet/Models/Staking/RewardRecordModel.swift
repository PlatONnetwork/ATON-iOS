//
//  RewardRecordModel.swift
//  platonWallet
//
//  Created by Admin on 3/1/2020.
//  Copyright © 2020 ju. All rights reserved.
//

import Foundation

class RewardModel: Decodable {
    var address: String
    var totalReward: String
    var sequence: Int
    var records: [RewardRecordModel]
    var timestamp: String
    var isOpen: Bool = false

    init(address: String, totalReward: String, timestamp: String, sequence: Int, records: [RewardRecordModel], isOpen: Bool) {
        self.address = address
        self.totalReward = totalReward
        self.timestamp = timestamp
        self.sequence = sequence
        self.records = records
        self.isOpen = isOpen
    }

    enum CodingKeys: String, CodingKey {
        case address
        case totalReward
        case records = "item"
        case timestamp
        case sequence
    }
}

class RewardRecordModel: Decodable {
    var nodeId: String?
    var nodeName: String?
    var reward: String?

    init(nodeId: String, nodeName: String, reward: String) {
        self.nodeId = nodeId
        self.nodeName = nodeName
        self.reward = reward
    }
}

extension RewardModel {
    var avatarImage: UIImage? {
        let localWallet = (AssetVCSharedData.sharedData.walletList as! [Wallet]).filter { $0.address.lowercased() == address.lowercased() }.first
        guard let wallet = localWallet else {
            return UIImage(named: "walletAvatar_1")
        }
        return wallet.image()
    }

    var walletName: String? {
        let localWallet = (AssetVCSharedData.sharedData.walletList as! [Wallet]).filter { $0.address.lowercased() == address.lowercased() }.first
        return (localWallet?.name ?? "--")
    }

    var walletAddress: String? {
        return "(" + address.addressForDisplayShort() + ")"
    }

    var amountForDisplay: String {
        return "+" + (totalReward.vonToLATString ?? "0").balanceFixToDisplay(maxRound: 8).ATPSuffix()
    }

    var recordTime: String? {
        let format = DateFormatter()
        let date = Date(timeIntervalSince1970: TimeInterval((Int(timestamp) ?? 0)/1000))
        let localZone = NSTimeZone.local
        format.timeZone = localZone
        format.locale = NSLocale.current
        format.dateFormat = "#yyyy/MMdd HH:mm"
        let strDate = format.string(from: date)
        return strDate
    }
}

extension RewardRecordModel {
    var amountForDisplay: String {
        return "+" + (reward?.vonToLATString ?? "0").balanceFixToDisplay(maxRound: 8).ATPSuffix()
    }
}
