//
//  RewardRecordModel.swift
//  platonWallet
//
//  Created by Admin on 3/1/2020.
//  Copyright © 2020 ju. All rights reserved.
//

import Foundation

struct RewardModel: Decodable {
    var address: String
    var totalReward: String
    var records: [RewardRecordModel]

    enum CodingKeys: String, CodingKey {
        case address
        case totalReward
        case records = "item"
    }
}

struct RewardRecordModel: Decodable {
    var nodeId: String?
    var nodeName: String?
    var reward: String?
}

extension RewardModel {
    var avatarImage: UIImage? {
        let localWallet = (AssetVCSharedData.sharedData.walletList as! [Wallet]).filter { $0.address.lowercased() == address.lowercased() }.first
        guard let wallet = localWallet else {
            return UIImage(named: "walletAvatar_1")
        }
        return wallet.image()
    }
}


