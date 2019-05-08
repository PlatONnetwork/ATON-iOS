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
import RealmSwift

enum RankStatus : Int{
    case candidateFirst100
    case alternativeFirst100
    case validator
    
    func desc() -> String {
        switch self {
        case .candidateFirst100:
            return Localized("CandidateDetailVC_rankStatu_candidateFirst100")
        case .alternativeFirst100:
            return Localized("CandidateDetailVC_rankStatu_alternativeFirst100")
        case .validator:
            return Localized("CandidateDetailVC_rankStatu_Validator")
        }
    }
}

class CandidateExtra:Decodable {
    
    var nodeName: String? = ""          //节点名称
    var nodePortrait: String? = ""      //节点logo
    var nodeDiscription: String? = ""   //机构简介
    var nodeDepartment: String? = ""    //机构名称
    var officialWebsite: String? = ""   //官网
    var time: UInt64? = 0               //申请时间 
    
    
    enum CodingKeys: String, CodingKey {
        case nodeName = "nodeName"
        case nodePortrait = "nodePortrait"
        case nodeDiscription = "nodeDiscription"
        case nodeDepartment = "nodeDepartment"
        case officialWebsite = "officialWebsite"
        case time = "time"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        officialWebsite = try? container.decode(String.self, forKey: .officialWebsite)
        nodeName = try? container.decode(String.self, forKey: .nodeName)
        nodeDiscription = try? container.decode(String.self, forKey: .nodeDiscription)
        nodeDepartment = try? container.decode(String.self, forKey: .nodeDepartment)
        
        time = try? container.decode(UInt64.self, forKey: .time)
        do{
            nodePortrait = try container.decode(String.self, forKey: .nodePortrait)
        }catch{
            //var tmp : UInt64 = 1
            //tmp = try? container.decode(UInt64.self, forKey: .nodePortrait)
            //nodePortrait = String(format: "%d", tmp)
        }
    }
    
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
    
    var rankStatus: RankStatus = .alternativeFirst100
    
    var rankByDeposit: UInt16?
    
    //like: 80%
    var rewardRate: String {
        get {
            let rate = Float(10000 - (fee ?? 0))/Float(100)
            return String(format: "%d%%", Int(rate))
        }
        
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
        candidateId = try? container.decode(String.self, forKey: .candidateId)
        host = try? container.decode(String.self, forKey: .host)
        port = try? container.decode(String.self, forKey: .port)
        owner = try? container.decode(String.self, forKey: .owner)
        from = try? container.decode(String.self, forKey: .from)
        let extraStr = try container.decode(String.self, forKey: .extra) 
        do {
            txIndex = try container.decode(Int.self, forKey: .txIndex)
            extra = try JSONDecoder().decode(CandidateExtra.self, from: extraStr.data(using: .utf8)!)
        } catch  {
            print("candidate Extra filed:" + error.localizedDescription)
            return
        }
        
        fee = try container.decode(UInt64.self, forKey: .fee)
        
        let info = CandidateBasicInfo()
        info.id = candidateId ?? ""
        info.name = extra?.nodeName
        info.avatar = extra?.nodePortrait
        info.host = host
        info.port = port
        info.owner = owner
        VotePersistence.addCandidateInfo(info)
    }
    
    
}



class CandidateBasicInfo: Object {
    
    @objc dynamic var id: String = ""
    @objc dynamic var name: String? = ""
    @objc dynamic var avatar: String? = ""
    @objc dynamic var host: String? = ""
    @objc dynamic var port: String? = ""
    @objc dynamic var owner: String? = ""
    @objc dynamic var nodeURLStr: String = ""
    override public static func primaryKey() -> String? {
        return "id"
    }
    
    
    var getAvatar : UIImage? {
        get {
            let index = Int(avatar ?? "1") ?? 1
            return UIImage(named: "nodeAvatar_\(index)")
        }
    }
    
}
