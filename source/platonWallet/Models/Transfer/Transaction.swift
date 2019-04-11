//
//  Transaction.swift
//  platonWallet
//
//  Created by matrixelement on 19/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import BigInt
import RealmSwift
import Localize_Swift

let oneMultiplier = "1"
let ETHToWeiMultiplier = "1000000000000000000"
let GMultiplier = "1000000000"

let THE8powerof10 = "100000000"
let THE9powerof10 = "1000000000"
let THE18powerof10 = "1000000000000000000"


enum TransanctionType: Int {
    case Send
    case Receive
    case Vote
    
    public var localizedDesciption: String? {
        switch self {
        case .Send:
            return Localized("walletDetailVC_tx_type_send")
        case .Receive:
            return Localized("walletDetailVC_tx_type_receive")
        case .Vote:
            return Localized("walletDetailVC_tx_type_vote")
        }
    }
}

enum TransferStatus{
    case pending
    case confiming
    case success
    case fail
}

enum TransactionStatus {
    case sending
    case sendSucceed
    case sendFailed
    case receiving
    case receiveSucceed
    case receiveFailed
    case voting
    case voteSucceed
    case voteFailed
    
    var localizeTitle : String {
        switch self {
        case .sending:
            return Localized("TransactionStatus_sending_title")
        case .sendSucceed:
            return Localized("TransactionStatus_sendSucceed_title")
        case .sendFailed:
            return Localized("TransactionStatus_sendFailed_title")
        case .receiving:
            return Localized("TransactionStatus_receiving_title")
        case .receiveSucceed:
            return Localized("TransactionStatus_receiveSucceed_title")
        case .receiveFailed:
            return Localized("TransactionStatus_receiveFailed_title")
        case .voting:
            return Localized("TransactionStatus_voting_title")
        case .voteSucceed:
            return Localized("TransactionStatus_voteSucceed_title")
        case .voteFailed:
            return Localized("TransactionStatus_voteFailed_title")
        }
    }
    
    var localizeDescAndColor : (String, UIColor) {
        
        let succeedColor = cell_Transaction_success_color
        let pendingColor = cell_Transaction_pending_color
        let failedColor  = cell_Transaction_fail_color
        
        let pendingDesc = Localized("TransactionStatus_pending_desc")
        let succeedDesc = Localized("TransactionStatus_succeed_desc")
        let failedDesc = Localized("TransactionStatus_failed_desc")
        
        switch self {
        case .sending, .receiving, .voting:
            return (pendingDesc, pendingColor)
        case .sendSucceed, .receiveSucceed, .voteSucceed:
            return (succeedDesc, succeedColor)
        case .sendFailed, .receiveFailed, .voteFailed:
            return (failedDesc, failedColor)
        }
    }
    
}

class Transaction : Object{
    
    @objc dynamic var txhash : String? = ""
    
    var nonce : CLongLong? = 0
    
    @objc dynamic var blockHash : String?  = ""
    
    @objc dynamic var blockNumber : String?  = ""
    
    @objc dynamic var from : String? = ""
    
    @objc dynamic var to : String?  = ""
    
    @objc dynamic var value : String? = ""
    
    @objc dynamic var gasPrice : String? = ""
    
    @objc dynamic var gas : String? = ""
    
    @objc dynamic var gasUsed : String? = ""
    
    @objc dynamic var memo : String? = ""
    
    @objc dynamic var input : String? = ""
    
    @objc dynamic var confirmTimes = 0

    @objc dynamic var createTime = 0
    
    @objc dynamic var transactionType = 0
    
    @objc dynamic var extra: String?
    
    //to confirm send or receive
    var senderAddress: String?
    
    var transactionStauts: TransactionStatus {
        get {
            switch transanctionTypeLazy {
            case .Send:
                if blockNumber?.length ?? 0 > 0 {
                    return .sendSucceed
                }else {
                    return .sending
                }
            case .Receive:
                if blockNumber?.length ?? 0 > 0 {
                    return .receiveSucceed
                }else {
                    return .receiving
                } 
            case .Vote:
                guard extra != nil else {
                    return .voting
                }
                guard let dic = try? JSONSerialization.jsonObject(with: extra!.data(using: .utf8) ?? Data(), options: .mutableContainers) as? [String:Any], let ret = dic?["Ret"] as? Bool else {
                    return .voting
                }
               
                if ret == true{
                    return .voteSucceed
                }
                return .voteFailed
            }
        }
    }
    
    var valueDescription : String?{
        get{
            guard value != nil else{
                return "0.00"
            }
            return BigUInt(value!)?.divide(by: ETHToWeiMultiplier, round: 8)
        }
    }
    
    var feeDescription : String?{
        get{
            var feeB : BigUInt?
            guard gasUsed != nil, gasUsed != "" ,gasPrice != nil, gasPrice != "" else{
                return "0.00"
            }
            
            
            feeB = BigUInt(gasUsed!)?.multiplied(by: BigUInt(gasPrice!)!)
            guard feeB != nil else{
                return "0.00"
            }
            return feeB!.divide(by: ETHToWeiMultiplier, round: 8)
            
        }
    }
    
    var transanctionTypeLazy : TransanctionType {
        get{
            let type = TransanctionType(rawValue: transactionType) ?? .Send
            if type == .Send {
                if senderAddress == from {
                    return .Send
                }else {
                    return .Receive
                }
            }else {
                return type
            }
        }
    }
    
    private func transactionReachTrustworthyStatus() -> (String,UIColor){
        var des : String = ""
        var color : UIColor = .white
        
        if (TransactionService.service.lastedBlockNumber != nil) && (TransactionService.service.lastedBlockNumber?.length)! > 0{
            let lastedBlockNumber = BigUInt(TransactionService.service.lastedBlockNumber!)
            let txBlockNumber = BigUInt((self.blockNumber)!)
            
            var lastedBlockNumberCopy = BigUInt(String((lastedBlockNumber!)))
            let overflow = lastedBlockNumberCopy?.subtractReportingOverflow(txBlockNumber!)
            if overflow! {
                return (des,color)
            }
            
            let blockDiff = BigUInt.safeSubStractToUInt64(a: lastedBlockNumber!, b: txBlockNumber!)
            if Int64(blockDiff) > MinTransactionConfirmations{
                //success
                des = Localized("walletDetailVC_tx_status_success")
                color = cell_Transaction_success_color
            }else{
                //block confirming or chain data rollback(debug)
                des = String(format: "%@(%d/%d)", Localized("walletDetailVC_tx_status_confirming"),blockDiff,MinTransactionConfirmations)
                color = cell_Transaction_success_color
            }
        }else{
            //network unreachable
            des = "--"
        }
        return (des,color)
    }
    
    override public static func ignoredProperties() ->[String] {
        return ["sharedWalletOwners","sharedWalletConOwners","sharedWalletRejectOwners","valueDescription","senderAddress"]
    }
    
    override public static func primaryKey() -> String? {
        return "txhash"
    }
    
}
