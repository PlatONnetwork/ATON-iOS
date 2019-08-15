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

class VoteTransaction: Decodable {
    var nodeId: String?
    var name: String?
    var validNum: String?
    var deadLine: String?
    var totalTicketNum: String?
    var locked: String?
    var earnings: String?
    var transactionTime: String?
    var countryCode: String?
    var sequence: String?
    var price: String?
    var walletAddress: String?
    
    var invalidNumber: Int{
        get{
            if let total = Int(totalTicketNum ?? "0"), let valid = Int(validNum ?? "0"){
                return total - valid
            }
            return 0
        }
    }
    
    var walletName : String{
        guard let walletAddr = walletAddress else { return "" }
        if (walletAddr.length) > 0{
            if let wallet = WalletService.sharedInstance.getWalletByAddress(address: walletAddr){
                return wallet.name
            }
        }
        return ""
    }
}

class VoteTransactionResponse: Decodable {
    var errMsg: String = ""
    var code: Int = 0
    var data: [VoteTransaction]
}

class SingleVote: Object {
    
    @objc dynamic var txHash: String = ""
    
    @objc dynamic var createTime = 0
    
    @objc dynamic var updateTime = 0
    
    @objc dynamic var candidateId : String? = ""
    
    @objc dynamic var deposit : String? = ""
    
    @objc dynamic var owner : String = ""
    
    @objc dynamic var totalTicketNum : String = ""
    
    @objc dynamic var validNum : String = ""
    
    @objc dynamic var nodeURLStr: String = ""
    
    @objc dynamic var isLocalData = false    
    
    var invalidNumber: Int{
        get{
            if let total = Int(totalTicketNum), let valid = Int(validNum){
                return total - valid
            }
            return 0
        }
    }
    
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
    
    var voteEarnings: String? = ""
    
//    var ticketPrice : String = ""
//    
//    var validCount : Int = 0
//    
//    var invalidCount: Int = 0
//    
//    var assetOflocked: String? = ""
//    
//    var releaseOfVote: String? = ""
//    
    
//    
//    var expiredTime: String? = ""
    
    
    
}
