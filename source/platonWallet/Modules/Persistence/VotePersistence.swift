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
        predicate = NSPredicate(format: "candidateId = %@", candidateId)
        let r = RealmInstance!.objects(SingleVote.self).filter(predicate!).sorted(byKeyPath: "createTime", ascending: false)
        let array = Array(r)
        return array
    }
    
    public class func getSingleVotesByTxHash(_ txHash: String) -> SingleVote? {

        return RealmInstance?.object(ofType: SingleVote.self, forPrimaryKey: txHash.add0x())
    }
    
    public class func getAllTickets() -> [Ticket] {
        let r = RealmInstance!.objects(Ticket.self)
        return Array(r)
    }
    
    
    public class func updateTickets(_ tickets: [Ticket]) {
        
        try? RealmInstance!.write {
            for ticket in tickets {
                RealmInstance!.add(ticket, update: true)
            }
        }  
    }
    
    public class func updateUnknownStatusTickets(_ ticketIds: [String]) {
        try? RealmInstance!.write {
            for id in ticketIds {
                let ticket = RealmInstance?.object(ofType: Ticket.self, forPrimaryKey: id)
                ticket?.state = 0
            }
        }
    }
    
    public class func addCandidateInfo(_ candidate: CandidateBasicInfo) {
        
        try? RealmInstance!.write {
            RealmInstance!.add(candidate, update: true)
        }
    }
    
    
    public class func getCandidateInfoWithId(_ id: String) -> CandidateBasicInfo {
        return RealmInstance!.object(ofType: CandidateBasicInfo.self, forPrimaryKey: id) ?? CandidateBasicInfo()
    }
    
}
