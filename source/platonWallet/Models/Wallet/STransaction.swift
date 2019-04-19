//
//  STransaction.swift
//  platonWallet
//
//  Created by matrixelement on 14/11/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import RealmSwift
import Localize_Swift
import platonWeb3
import BigInt

enum OperationAction : Int{
    case undetermined
    case revoke
    case approval
}

class DeterminedResult : AddressInfo{
    
    @objc dynamic var operation = 0
    
    var operationEnum : OperationAction{
        get{
            return OperationAction(rawValue: operation)!
        }
    }
    
}

enum TransanctionCategory : Int {
    case ATPTransfer
    case JointWalletCreation
    case JointWalletExecution
    case JointWalletSubmit
    case JointWalletApprove
    case JointWalletRevoke
    
     
    public var localizedDesciption: String? {
        
        switch self {
        case .ATPTransfer:
            return Localized("STranctionType_execute")
        case .JointWalletCreation:
            return Localized("TransactionListVC_JointWalletCreation")
        case .JointWalletExecution:
            return Localized("TransactionListVC_JointWalletExecution")
        case .JointWalletSubmit:
            return Localized("TransactionListVC_JointWalletExecution")
        case .JointWalletApprove:
            return Localized("TransactionListVC_JointWalletExecution")
        case .JointWalletRevoke:
            return Localized("TransactionListVC_JointWalletExecution")

        }
    }
}


enum SignStatus : Int{
    case voting
    case reachApproval
    case reachRevoke
}

enum ReadTag : Int{
    case Readed
    case UnRead
}

enum DeleteTag : Int{
    case NO
    case YES
}

class STransaction: Object {
    
    @objc dynamic var transactionID: String = ""
    
    @objc dynamic var transactionType = 0
     
    var transanctionTypeLazy : TransanctionType?{
        get{
            return TransanctionType(rawValue: transactionType)
        }
    }
    
    @objc dynamic var transactionCategory = 0
    
    var transanctionCategoryLazy : TransanctionCategory?{
        get{
            return TransanctionCategory(rawValue: transactionCategory)
        }
    }
    
    @objc dynamic var uuid: String = NSUUID().uuidString
    
    @objc dynamic var contractAddress: String = ""
    
    @objc dynamic var ownerWalletAddress: String = ""

    var determinedResult = List<DeterminedResult>()
    
    //sponsor, local db stored variable
    @objc dynamic var sponsor : String?
    
    //shread wallet contractAddress
    @objc dynamic var from : String?
    
    //actual receive
    @objc dynamic var to : String?
    
    @objc dynamic var fee : String?
    
    @objc dynamic var value : String?
    
    @objc dynamic var memo : String?
    
    @objc dynamic var data: Data? = nil
    
    @objc dynamic var createTime = Date().millisecondsSince1970
    
    @objc dynamic var updateTime = Date().millisecondsSince1970
    
    @objc dynamic var confirmTimes = 0
    
    @objc dynamic var pending = false
    
    @objc dynamic var executed = false
    
    @objc dynamic var blockHash : String?  = ""
    
    @objc dynamic var blockNumber : String?  = ""
    
    @objc dynamic var nodeURLStr: String = ""
    
    // txhash refers to the hash of confirmTransaction or revokeConfirmation
    @objc dynamic var txhash: String? = ""
    
    @objc dynamic var gasUsed : String? = ""
    
    @objc dynamic var gas : String? = ""
    
    @objc dynamic var gasPrice : String? = ""
    
    @objc dynamic var required = 0
    
    
    @objc dynamic var readTag = 0{
        didSet{
            if readTag == 1{
            }
        }
    }
    
    //if shared wallet has been delete, swalletDelete = 1
    @objc dynamic var swalletDelete = 0
    
    //if txHash length > 0, it indicate the transaction was sign and submit by one of existed classic wallets
    var isWaitForConfirmation : Bool{
        if txhash != nil && (txhash?.count)! > 0 && self.blockNumber != nil && ((self.blockNumber?.count)! == 0){
            return true
        }
        return false
    }
    
    var signStatus : SignStatus{
        get{
            var approveNum = 0
            var revokeNum = 0
            for item in self.determinedResult{
                if item.operation == OperationAction.approval.rawValue{
                    approveNum = approveNum + 1
                }else if item.operation == OperationAction.revoke.rawValue{
                    revokeNum = revokeNum + 1
                }
            }
            let swallet = SWalletService.sharedInstance.getSWalletByContractAddress(contractAddress: self.contractAddress)
            if swallet != nil && approveNum >= (swallet?.required)!{
                return SignStatus.reachApproval
            }
            
            if swallet != nil && ((swallet?.owners.count)! - revokeNum) < (swallet?.required)!{
                return SignStatus.reachRevoke
            }
            
            return SignStatus.voting
        }
    }
    
    
    var approveNumber : Int{
        get{
            var i = 0
            for item in determinedResult{
                if item.operation == OperationAction.approval.rawValue{
                    i = i + 1
                }
            }
            return i
        }
    }
    
    var revokeNumber : Int{
        get{
            var i = 0
            for item in determinedResult{
                if item.operation == OperationAction.revoke.rawValue{
                    i = i + 1
                }
            }
            return i
        }
    }
    
    var isInOwnerList : Bool{

        let swallet = SWalletService.sharedInstance.getSWalletByContractAddress(contractAddress: contractAddress)
        if swallet == nil{
            return false
        }
        for item in (swallet?.owners)!{
            if ((item.walletAddress?.ishexStringEqual(other: swallet?.walletAddress)))!{
                return true
            }
        }
        return false
    }
    
    
    func labelDesciptionAndColor(_ completion: ((_ des: String,_ color: UIColor) -> () )?){
        let detached = self
        DispatchQueue.main.async {
            var des : String = ""
            var color : UIColor = .white 
            
            if detached.transactionCategory == TransanctionCategory.ATPTransfer.rawValue{
                if (detached.txhash?.length)! > 0{
                    
                    if (detached.blockNumber?.length)! > 0{
                        let ret = STransaction.labelDesciptionAndColorWithMinedTx(detached)
                        des = ret.0
                        color = ret.1
                    }else{
                        des = Localized("walletDetailVC_tx_status_pending")
                        color = cell_Transaction_pending_color
                    }
                    
                }else{ 
                    let ret = STransaction.labelDesciptionAndColorWithMinedTx(detached)
                    des = ret.0
                    color = ret.1
                }
            }else if (detached.transactionCategory == TransanctionCategory.JointWalletCreation.rawValue ||
                detached.transactionCategory == TransanctionCategory.JointWalletExecution.rawValue ||
                detached.transactionCategory == TransanctionCategory.JointWalletSubmit.rawValue ||
                detached.transactionCategory == TransanctionCategory.JointWalletApprove.rawValue ||
                detached.transactionCategory == TransanctionCategory.JointWalletRevoke.rawValue) {
                
                if detached.isWaitForConfirmation{
                    des = Localized("walletDetailVC_tx_status_pending")
                    color = cell_Transaction_pending_color
                }else{
                    //success
                    des = Localized("walletDetailVC_tx_status_success")
                    color = cell_Transaction_success_color
                }
            }
            
            DispatchQueue.main.async {
                if completion != nil{
                    completion!(des,color)
                }
            }
        }
        
       
    }
    
    public class func labelDesciptionAndColorWithMinedTx(_ tx: STransaction) -> (String,UIColor) {
        var des : String = ""
        var color : UIColor = .white
        if tx.executed{
            //success
            des = Localized("walletDetailVC_tx_status_success")
            color = cell_Transaction_success_color
        }else{
            if tx.signStatus == .reachRevoke{
                //remain undetermind member can't reach the approve required number
                des = Localized("Transaction.Fail")
                color = cell_Transaction_fail_color
            }else if tx.signStatus == .reachApproval{
                //contract transfer fail
                des = Localized("Transaction.Fail")
                color = cell_Transaction_fail_color
            }else if tx.signStatus == .voting{
                //signning(n/m)
                var approveNumber = 0
                for item in tx.determinedResult{
                    if item.operation == OperationAction.approval.rawValue{
                        approveNumber = approveNumber + 1
                    }
                }
                des = String(format: "%@(%d/%d)", Localized("walletDetailVC_no_transactions_Signing"),approveNumber,tx.required)
                color = cell_Transaction_pending_color
            }
        }
        
        return (des,color)
    }
    
    override public static func primaryKey() -> String? {
        return "uuid"
    }
    
    var valueDescription : String?{
        get{
            if self.transanctionCategoryLazy == .ATPTransfer{
                guard value != nil else{
                    return "0.00"
                }
                return BigUInt(value!)?.divide(by: ETHToWeiMultiplier, round: 8)
            }else{
                return "0.00"
            }
            

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
    
    var typeLocalization : String?{
        get{
            switch self.transanctionCategoryLazy {
            case .ATPTransfer?:
                if signStatus == .reachRevoke || signStatus == .reachApproval{
                    return Localized("TransactionListVC_Sent")
                }else {
                    return Localized("TransactionListVC_Sending")
                }
            case .some(.JointWalletCreation):
                return Localized("TransactionListVC_JointWalletCreation")
            case .some(.JointWalletExecution):
                return Localized("TransactionListVC_JointWalletExecution")
            case .some(.JointWalletSubmit):
                return Localized("TransactionListVC_JointWalletExecution")
            case .some(.JointWalletApprove):
                return Localized("TransactionListVC_JointWalletExecution")
            case .some(.JointWalletRevoke):
                return Localized("TransactionListVC_JointWalletExecution")
            case .none:
                return ""
            }
        }
    }
    
    static func stransactionConfirmsParser(tx: STransaction, concatenated : String) -> STransaction{
        var fixedCon = concatenated.replacingOccurrences(of: ":,", with: ":")
        fixedCon = fixedCon.replacingOccurrences(of: ",:", with: ":")
        let txStatusComponets = fixedCon.components(separatedBy: ":") 
        
        if txStatusComponets.count < 3{
            return tx
        }
        
        assert(tx.determinedResult.count > 0, "sTransactionParse tx.determinedResult.count")
        for item in tx.determinedResult{
            let trim0xAddr = item.walletAddress?.replacingOccurrences(of: "0x", with: "").lowercased()
            if txStatusComponets[1].lowercased().range(of: trim0xAddr!)?.lowerBound != nil{
                item.operation = 2
            }else if txStatusComponets[2].lowercased().range(of: trim0xAddr!)?.lowerBound != nil{
                item.operation = 1
            }else{
                item.operation = 0
            }
        }
        return tx
    }
    
    static func sTrsancationParser(concatenated : String,contractAddress : String,swallet: SWallet?) -> [STransaction]{
        var txs : [STransaction] = []
        let txComponents = concatenated.components(separatedBy: ":")
        if swallet == nil{
            //shared wallet may been deleted
            return []
        }
        for item in txComponents{
            if item.length == 0{
                continue
            }
            let tx = STransaction(swallet: swallet!)
            tx.transactionCategory = TransanctionCategory.ATPTransfer.rawValue
            let subItems = item.components(separatedBy: "|")
            if subItems.count >= 9{
                
                if subItems[0].hasPrefix("0x"){
                    tx.from = subItems[0]
                }else{
                    tx.from = "0x" + subItems[0]
                }
                
                if subItems[1].hasPrefix("0x"){
                    tx.to = subItems[1]
                }else{
                    tx.to = "0x" + subItems[1]
                }
                
                tx.value = subItems[2]
                tx.createTime = Int(TimeInterval(subItems[3])!)
                
                if subItems[4].length > 0{
                    tx.data = subItems[4].data(using: .utf8)
                    tx.memo = subItems[4]
                }
                tx.fee = subItems[5]
                
                if subItems[6] == "1"{
                    tx.pending = true
                }else{
                    tx.pending = false
                }
                if subItems[7] == "1"{
                    tx.executed = true
                }else{
                    tx.executed = false
                }
                
                tx.transactionID = subItems[8]
            }
            txs.append(tx)
        }
        return txs
    }
    
    static func sTransactionParse(txs : [STransaction], concatenated : String) -> [STransaction]{
        
        let txComponets = concatenated.components(separatedBy: "|")
        if txComponets.count > 1{
            var dic: Dictionary<String,STransaction> = [:]
            for item in txs{ 
                dic[item.transactionID] = item
            }  
            for item in txComponets{
                let txStatusComponets = item.components(separatedBy: ":")
                guard txStatusComponets.count >= 3, dic[txStatusComponets[0]] != nil else{
                    continue
                }
                let _ = self.stransactionConfirmsParser(tx: dic[txStatusComponets[0]]!, concatenated: item)
            }
            
        }else if (txComponets.count == 1 && txs.count == 1){
            //only one  tx
            let tx = txs[0]
            let _ = self.stransactionConfirmsParser(tx: tx, concatenated: concatenated)
        }
        
        return txs
        
    }
    
    var initAsUnread : Bool{
        
        //set tx as unread if tx not executed and tx in ownerlists and voting
        var undetermined = false
        for item in self.determinedResult{
            if !(item.walletAddress?.ishexStringEqual(other: self.ownerWalletAddress))!{
                continue
            }
            if item.operation == OperationAction.undetermined.rawValue{
                undetermined = true
                break
            }
        }
        if self.isInOwnerList && undetermined && (self.signStatus == SignStatus.voting){
            self.readTag = ReadTag.UnRead.rawValue
        }else{
            self.readTag = ReadTag.Readed.rawValue
        }
        
        //from myself regard it as been read
        if (self.from?.ishexStringEqual(other: self.ownerWalletAddress))!{
            self.readTag = ReadTag.Readed.rawValue
        }
        
        return true
    }
    
    //MARK: - Constructor

    required convenience init(swallet : SWallet){
        self.init()
        self.contractAddress = swallet.contractAddress
        self.ownerWalletAddress = swallet.walletAddress
        self.required = swallet.required
        for item in swallet.owners {
            let result = DeterminedResult()
            result.operation = 0;
            result.walletName = item.walletName
            result.walletAddress = item.walletAddress
            determinedResult.append(result)
        }
    }
 
    public func remakeUUID(){
        if self.transanctionCategoryLazy == .ATPTransfer{
            self.uuid = self.contractAddress + "_" + self.transactionID
        }
    }

    
}

