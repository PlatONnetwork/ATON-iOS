//
//  NodeVoteSummary.swift
//  platonWallet
//
//  Created by Ned on 25/12/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import BigInt

class NodeVoteSummary {
    
    var CandidateId : String? = ""
    
    var tickets : [Ticket] = []
    
//    var candidateDetail: Candidate?
    
    var validCount : Int{
        get{
            return self.tickets.tickets_validCount
        }
    }
    
    var invalidCount: Int{
        get{
            return self.tickets.tickets_invalidCount
        }
    }
    
    var assetOflocked: String?{
        get{
            return self.tickets.tickets_assetOflocked
        }
    }
    

    var voteEarnings: String?{
        get{
            return self.tickets.tickets_voteEarnings
        }
    }
    
    
    
    public class func parser(votes :[SingleVote]) -> [NodeVoteSummary]{
        if votes.count == 0{
            return []
        }
        
        var voteMap : Dictionary<String,[Ticket]> = [:]

        
        let _ = votes.map { (singleVote) in
            guard let candidatedId = singleVote.candidateId else{
                assert(false, "no candidate")
                return
            }
            
            if var list = voteMap[candidatedId]{
                if singleVote.tickets.count > 0{
                    list.append(contentsOf: singleVote.tickets)
                    voteMap[candidatedId] = list
                }
                
            }else{
                var list : [Ticket] = []
                if singleVote.tickets.count > 0{
                    list.append(contentsOf: singleVote.tickets)
                }
                
                voteMap[candidatedId] = list
            }
        }
        
        let summaries = voteMap.map { item -> NodeVoteSummary in
            let nodevote = NodeVoteSummary()
            nodevote.CandidateId = item.key
            nodevote.tickets = item.value
            return nodevote
        }
        
        return summaries

    }
}
