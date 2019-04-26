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
        RealmWriteQueue.async {
            autoreleasepool(invoking: {
                assert((singleVote.candidateId != nil), "candidate should not be empty")
                singleVote.nodeURLStr = SettingService.getCurrentNodeURLString()
                let realm = RealmHelper.getNewRealm()
                try? realm.write {
                    realm.add(singleVote) 
                    NSLog("Tickets add")
                }
            })
        }
        
    }
    
    public class func getAllSingleVotes() -> [SingleVote]{
        var predicate : NSPredicate?
        predicate = NSPredicate(format: "nodeURLStr = %@", SettingService.getCurrentNodeURLString())
        let r = RealmInstance!.objects(SingleVote.self).filter(predicate!).sorted(byKeyPath: "createTime", ascending: false)
        let array = Array(r)
        return array
    }
    
    public class func getSingleVotesByCandidate(candidateId: String) -> [SingleVote]{
        var predicate : NSPredicate?
        predicate = NSPredicate(format: "candidateId = %@ AND nodeURLStr = %@", candidateId,SettingService.getCurrentNodeURLString())
        let r = RealmInstance!.objects(SingleVote.self).filter(predicate!).sorted(byKeyPath: "createTime", ascending: false)
        let array = Array(r)
        return array
    }
    
    public class func getSingleVotesByTxHash(_ txHash: String) -> SingleVote? {

        return RealmInstance?.object(ofType: SingleVote.self, forPrimaryKey: txHash.add0x())
    }
    
    public class func addCandidateInfo(_ candidate: CandidateBasicInfo) {
        RealmWriteQueue.async {
            autoreleasepool(invoking: {
                let realm = RealmHelper.getNewRealm()
                candidate.nodeURLStr = SettingService.getCurrentNodeURLString()
                try? realm.write {
                    realm.add(candidate, update: true)
                }
            })
        }
        
    }
    
    
    public class func getCandidateInfoWithId(_ id: String) -> CandidateBasicInfo {
        return RealmInstance!.object(ofType: CandidateBasicInfo.self, forPrimaryKey: id) ?? CandidateBasicInfo()
    }
    
}
