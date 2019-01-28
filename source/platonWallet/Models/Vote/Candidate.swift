//
//  Candidate.swift
//  platonWallet
//
//  Created by Ned on 24/12/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import BigInt
import Localize_Swift

enum RankStatus {
    case candidateFirst100
    case alternativeFirst100
    
    func desc() -> String {
        switch self {
        case .candidateFirst100:
            return Localized("CandidateDetailVC_rankStatu_candidateFirst100")
        case .alternativeFirst100:
            return Localized("CandidateDetailVC_rankStatu_alternativeFirst100")
        }
    }
}

class CandidateExtra: Decodable {
    
    var nodeName: String = ""//节点名称
    var nodePortrait: String = ""//节点logo
    var nodeDiscription: String = ""//机构简介
    var nodeDepartment: String = ""//机构名称
    var officialWebsite: String = ""//官网
    var time: UInt64?//申请时间
    
}

class Candidate:NSObject, Decodable {
    
    //uint256 质押金额
    var deposit : BigUInt?
    
    //uint256 质押金更新的最新块高
    var blockNumber : BigUInt?
    
    //质押金退款地址
    var owner : String?
    
    //所在区块交易索引
    var txIndex : Int = 0
    
    //节点Id(公钥)
    var candidateId : String?
    
    //最新质押交易的发送方
    var from : String?
    
    //uint64 出块奖励佣金比，以10000为基数(eg：5%，则fee=500)
    var fee: UInt64?
    
    //节点IP
    var host: String?
    
    //节点P2P端口号
    var port: String?
    
    //附加数据(有长度限制，限制值待定)
    var extra: CandidateExtra?
    
    var area: IPGeoInfo?
    
    var tickets: UInt16?
    
    var rankStatus: RankStatus = .candidateFirst100
    
    var rankByDeposit: UInt16?
    
    public static func parser(data: Data) -> [Candidate]{
        return []
    }
    
    
    enum CodingKeys: String, CodingKey {
        case deposit = "Deposit"
        case blockNumber = "BlockNumber"
        case txIndex = "TxIndex"
        case candidateId = "CandidateId"
        case host = "Host"
        case port = "Port"
        case owner = "Owner"
        case from = "From"
        case extra = "Extra"
        case fee = "Fee"
    }
    
    required init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)
        let depositStr = try? container.decode(Decimal.self, forKey: .deposit)
        deposit = BigUInt(depositStr?.description ?? "")
        let blockNumberStr = try? container.decode(Decimal.self, forKey: .blockNumber)
        blockNumber = BigUInt(blockNumberStr?.description ?? "")
        txIndex = try container.decode(Int.self, forKey: .txIndex)
        candidateId = try container.decode(String.self, forKey: .candidateId)
        host = try container.decode(String.self, forKey: .host)
        port = try container.decode(String.self, forKey: .port)
        owner = try container.decode(String.self, forKey: .owner)
        from = try container.decode(String.self, forKey: .from)
        let extraStr = try container.decode(String.self, forKey: .extra)
        do {
            extra = try JSONDecoder().decode(CandidateExtra.self, from: extraStr.data(using: .utf8)!)
        } catch  {
            print(error.localizedDescription)
        }
        
        fee = try container.decode(UInt64.self, forKey: .fee)
    }
    
    @objc var countryName : String {
        get {
            return self.area?.localizeCountryName ?? Localized("IP_location_unknown")
        }
    }
    
    
    var avatar : UIImage? {
        get {
            let index = Int(extra?.nodePortrait ?? "1") ?? 1
            return UIImage(named: "nodeAvatar_\(index)")
        }
    }
    
    var avatarName : String {
        get {
            let index = Int(extra?.nodePortrait ?? "1") ?? 1
            return "nodeAvatar_\(index)"
        }
    }
    
}



