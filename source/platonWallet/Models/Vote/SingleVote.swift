//
//  SingleVote.swift
//  platonWallet
//
//  Created by Ned on 2/1/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import RealmSwift
import platonWeb3

class SingleVote: Object {
    
    var tickets = List<Ticket>()
    
    @objc dynamic var txHash: String = ""
    
    @objc dynamic var createTime = 0
    
    @objc dynamic var updateTime = 0
    
    @objc dynamic var candidateId : String? = ""
    
    @objc dynamic var candidateName: String? = ""
    
    @objc dynamic var owner : String = ""
    
//    @objc dynamic var ticketPrice: String = ""
    
    override public static func primaryKey() -> String? {
        return "txHash"
    }
    
    var walletName : String{
        if (owner.length) > 0{
            if let wallet = WalletService.sharedInstance.getWalletByAddress(address: self.owner){
                return wallet.name
            }
        }
        return ""
    }
    
    var validCount : Int{
        get{
            return Array(self.tickets).tickets_validCount
        }
    }
    
    var invalidCount: Int{
        get{
            return Array(self.tickets).tickets_invalidCount
        }
    }
    
    var assetOflocked: String?{
        get{
            return Array(self.tickets).tickets_assetOflocked
        }
    }
    
    var releaseOfVote: String?{
        get{
            return Array(self.tickets).tickets_releaseOfVote
        }
    }
    
    var voteEarnings: String?{
        get{
            return Array(self.tickets).tickets_voteEarnings
        }
    }
    
    //预计过期时间和实际过期时间，预期过期时间是可以知道的，实际过期时间是查不到的，你去查询这个票的时候(没达到预计过期时间就过期了)，实际过期时间就显示当前查询时间吧
    var expiredTime: String?{
        get{
            return ""
        }
    }
    
    
    
}
