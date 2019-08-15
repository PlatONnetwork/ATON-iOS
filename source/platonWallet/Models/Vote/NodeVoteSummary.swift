//
//  NodeVoteSummary.swift
//  platonWallet
//
//  Created by Ned on 25/12/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import BigInt
import Localize_Swift



class MyVoteStatic {
    
    var locktotal = BigUInt("0")!
    var earnings = BigUInt("0")!
    
    var validNum = 0
    var inValidNum = 0
    
}

class NodeVote: Decodable {
    var nodeId: String?
    var name: String?
    var countryCode: String?
    var validNum: String?
    var totalTicketNum: String?
    var locked: String?
    var earnings: String?
    var transactionTime: String?
    var isValid: String?
    
    var invalidTicketNum: Int {
        get {
            guard let totalNum = Int(totalTicketNum ?? "0") else { return 0 }
            guard let validNum = Int(validNum ?? "0") else { return totalNum }
            return totalNum - validNum
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case nodeId
        case name
        case countryCode
        case validNum
        case totalTicketNum
        case locked
        case earnings
        case transactionTime
        case isValid
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        nodeId = try? container.decode(String.self, forKey: .nodeId)
        name = try? container.decode(String.self, forKey: .name)
        countryCode = try? container.decode(String.self, forKey: .countryCode)
        validNum = try? container.decode(String.self, forKey: .validNum)
        totalTicketNum = try? container.decode(String.self, forKey: .totalTicketNum)
        locked = try? container.decode(String.self, forKey: .locked)
        earnings = try? container.decode(String.self, forKey: .earnings)
        transactionTime = try? container.decode(String.self, forKey: .transactionTime)
        isValid = try? container.decode(String.self, forKey: .isValid)
        
    }
    
}

class NoteVoteResponse: Decodable {
    var errMsg: String = ""
    var code: Int = 0
    var data: [NodeVote] = []
    
    var voteStatic: MyVoteStatic {
        get {
            let totalLocked = data.reduce(BigUIntZero, { (result, next) -> BigUInt in
                return result + BigUInt.safeInit(str: next.locked)
            })
            
            let totalEarnings = data.reduce(BigUIntZero) { (result, next) -> BigUInt in
                return result + BigUInt.safeInit(str: next.earnings)
            }
            
            let totalValidNum = data.reduce(0) { (result, next) -> Int in
                return result + Int(next.validNum ?? "0")!
            }
            
            let totalTicketNum = data.reduce(0) { (result, next) -> Int in
                return result + Int(next.totalTicketNum ?? "0")!
            }
            
            let voteStatic = MyVoteStatic()
            voteStatic.locktotal = totalLocked
            voteStatic.earnings = totalEarnings
            voteStatic.validNum = totalValidNum
            voteStatic.inValidNum = totalTicketNum - totalValidNum
            
            return voteStatic
        }
    }
}

extension NodeVote {
    func getNodeCountryName() -> String? {
        guard let code = countryCode else { return nil }
        let path = Bundle.main.path(forResource: "PlatonAssets/country", ofType: "json")
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path!)), let json = try? JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, Any> else { return nil }
        guard let array = json?["countrys"] as? [Dictionary<String, Any>] else { return nil }
        
        let results = array.filter { ($0["_id"] as? String)! == code }
        if Localize.currentLanguage() == "en" {
            return results.first?["Name_en"] as? String
        } else {
            return results.first?["Name_zh"] as? String
        }
    }
}

class NodeVoteSummary {
    
    var CandidateId : String? = ""
    
    var singleVote: [SingleVote] = []
    
    var validCount : Int = 0
    
    var invalidCount: Int = 0
    
    var assetOflocked: String? = ""

    var voteEarnings: String? = ""    
    
    public class func parser(votes :[SingleVote]) -> [NodeVoteSummary]{
        if votes.count == 0{
            return []
        }
        var voteMap : Dictionary<String,[SingleVote]> = [:]
        
        let _ = votes.map { (singleVote) in
            guard let candidatedId = singleVote.candidateId else{
                assert(false, "no candidate")
                return
            }
            
            if var list = voteMap[candidatedId]{
                list.append(singleVote)
            }else{
                var list : [SingleVote] = []
                list.append(singleVote)
                voteMap[candidatedId] = list
            }
        }
        
        let summaries = voteMap.map { item -> NodeVoteSummary in
            let nodevote = NodeVoteSummary()
            nodevote.singleVote = item.value
            nodevote.CandidateId = item.key
            return nodevote
        }
        
        return summaries
    }
    

    static func parserWithDicArray(mapArray: [Dictionary<String,Any>]) -> [NodeVoteSummary]{
        
        var summaries : Array<NodeVoteSummary> = []
        
        //key candidateID value [SingleVote]
        var nodeVoteMap : Dictionary<String,[SingleVote]> = [:]
        //enum - get SingleVote map
        for item in mapArray{
            let sv = SingleVote()
            sv.txHash = item["TransactionHash"] as? String ?? ""
            sv.candidateId = item["candidateId"] as? String ?? ""
            sv.owner = item["owner"] as? String ?? ""
            sv.voteEarnings = item["earnings"] as? String ?? ""
            sv.createTime = Int((item["transactiontime"] as? String ?? "").GreenwichTimeStamp())
            sv.deposit = item["deposit"] as? String ?? ""
            sv.totalTicketNum = item["totalTicketNum"] as? String ?? ""
            sv.validNum = item["validNum"] as? String ?? ""
            
            var array = nodeVoteMap[sv.candidateId ?? ""]
            if array == nil{
                var newArray : [SingleVote] = []
                newArray.append(sv)
                nodeVoteMap[sv.candidateId!] = newArray
            }else{
                array?.append(sv)
                nodeVoteMap[sv.candidateId!] = array
            }
        }
        
        for (key,element) in nodeVoteMap{
            var profit = BigUInt("0")!
            var voteStaked = BigUInt("0")!
            var validTicketCount = 0
            var totalTicketCount = 0
            
            for sv in element{
                
                profit.multiplyAndAdd(BigUInt.safeInit(str: sv.voteEarnings), 1)
                let singleStaked = BigUInt(sv.validNum)?.multiplied(by: BigUInt.safeInit(str: sv.deposit))
                voteStaked.multiplyAndAdd(singleStaked ?? BigUInt("0")!, 1)
                validTicketCount = validTicketCount + (Int(sv.validNum) ?? 0)
                totalTicketCount = totalTicketCount + (Int(sv.totalTicketNum) ?? 0)
            }
            let invalidTicketCount = totalTicketCount - validTicketCount
            
            let sum = NodeVoteSummary()
            sum.voteEarnings = String(profit)
            sum.assetOflocked = String(voteStaked)
            sum.validCount = validTicketCount
            sum.invalidCount = invalidTicketCount
            if key.hasPrefix("0x") && key.length > 2{
                sum.CandidateId = key.substr(2, key.length - 2)
            }else{
                sum.CandidateId = key
            }
            
            var svproperty : [SingleVote] = []
            
            svproperty.append(contentsOf: element)
            svproperty.sort { (v1, v2) -> Bool in
                return v1.createTime > v2.createTime
            }
            sum.singleVote = svproperty
            
            /*
            element.reduce(initialResult) { (tmp, vote) -> BigUInt in
                return tmp.multiplyAndAdd(BigUInt(vote.voteEarnings ?? "0")!, 1)
            }
             */
            summaries.append(sum)
        }
        
        summaries.sort { (s1, s2) -> Bool in
            guard s1.singleVote.count > 0, s2.singleVote.count > 0, let singleV1 = s1.singleVote.first, let singleV2 = s2.singleVote.first else{
                return true
            }
            return singleV1.createTime > singleV2.createTime
        }
        
        
        return summaries
    }
    
    
}
