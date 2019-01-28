//
//  VotePersistence.swift
//  platonWallet
//
//  Created by Ned on 25/12/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation

class VotePersistence {
    
    public class func add(singleVote : SingleVote){
        
        assert((singleVote.candidateId != nil), "candidate should not be empty")
        
        try? RealmInstance!.write {
            RealmInstance!.add(singleVote)
            NSLog("Tickets add")
        }
    }
    
    public class func getAllNodeVoteList() -> [NodeVoteSummary]{
        let r = RealmInstance!.objects(SingleVote.self)
        return NodeVoteSummary.parser(votes: Array(r))
    }
    
    public class func getSingleVotesByCandidate(candidateId: String) -> [SingleVote]{
        var predicate : NSPredicate?
        predicate = NSPredicate(format: "CandidateId = %@", candidateId)
        let r = RealmInstance!.objects(SingleVote.self).filter(predicate!).sorted(byKeyPath: "createTime", ascending: false)
        let array = Array(r)
        return array
    }
    
    public class func getSingleVotesByTxHash(_ txHash: String) -> SingleVote? {

        return RealmInstance?.object(ofType: SingleVote.self, forPrimaryKey: txHash.add0x())
    }
    
    
    public class func updateTickets(_ tickets: [Ticket]) {
        
        for ticket in tickets {
            try? RealmInstance!.write {
                RealmInstance!.add(ticket, update: true)
            }
        }
        
        
        
    }
    
}
