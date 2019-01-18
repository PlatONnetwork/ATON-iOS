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

let ETHToWeiMultiplier = "1000000000000000000"
let GMultiplier = "1000000000"

let THE8powerof10 = "100000000"
let THE9powerof10 = "1000000000"
let THE18powerof10 = "1000000000000000000"


enum TransanctionType : Int {
    case Send
    case Receive
    
    public var localizedDesciption: String? {
        switch self {
        case .Send:
            return Localized("walletDetailVC_tx_type_send")
        case .Receive:
            return Localized("walletDetailVC_tx_type_receive")
        }
    }
}

enum TransferStatus{
    case pending
    case confiming
    case success
    case fail
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
    
    var transanctionTypeLazy : TransanctionType?{
        get{
            return TransanctionType(rawValue: transactionType)
        }
    }

    func labelDesciptionAndColor() -> (String,UIColor) {
        var des : String = ""
        var color : UIColor = .white
        if (self.blockNumber?.length)! > 0 {
            //return self.transactionReachTrustworthyStatus()
            des = Localized("walletDetailVC_tx_status_success")
            color = UIColor(rgb: 0x41d325)
        }else{
            //pending
            des = Localized("walletDetailVC_tx_status_pending")
            color = UIColor(rgb: 0xFFED54)
            
        }
        
        return (des,color)
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
                color = UIColor(rgb: 0x41d325)
            }else{
                //block confirming or chain data rollback(debug)
                des = String(format: "%@(%d/%d)", Localized("walletDetailVC_tx_status_confirming"),blockDiff,MinTransactionConfirmations)
                color = UIColor(rgb: 0xFFED54)
            }
        }else{
            //network unreachable
            des = "--"
        }
        return (des,color)
    }
    
    override public static func ignoredProperties() ->[String] {
        return ["sharedWalletOwners","sharedWalletConOwners","sharedWalletRejectOwners","valueDescription"]
    }
    
    override public static func primaryKey() -> String? {
        return "txhash"
    }
    
}
