//
//  NodeVoteSummary.swift
//  platonWallet
//
//  Created by Ned on 25/12/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import BigInt

class MyVoteStatic {
    
    var locktotal = BigUInt("0")!
    var earnings = BigUInt("0")!
    
    var validNum = 0
    var inValidNum = 0
    
    
    static func parserAllNodeSummary(mapArray: [Dictionary<String,Any>]) -> MyVoteStatic{
        
        //let jsond = try? JSONSerialization.data(withJSONObject: mapArray, options: [])
        //let s = String(data: jsond!, encoding: .utf8)
        
        let node = MyVoteStatic()
        var total_locked = BigUInt("0")!
        var total_earnings = BigUInt("0")!
        var total_TicketNum = 0
        var total_validNum = 0
        
        for item in mapArray{
            
            let locked = BigUInt.safeInit(str: item["locked"] as? String)
            let earnings = BigUInt.safeInit(str: item["earnings"] as? String)
            let totalTicketNum = Int(item["totalTicketNum"] as? String ?? "0")!
            let validNum = Int(item["validNum"] as? String ?? "0")!
            
            total_locked.multiplyAndAdd(locked, 1)
            total_earnings.multiplyAndAdd(earnings, 1)
            total_TicketNum += totalTicketNum
            total_validNum += validNum
        }
        
        node.locktotal = total_locked
        node.earnings = total_earnings
        node.validNum = total_validNum
        node.inValidNum = total_TicketNum - total_validNum
         
        return node
        
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
