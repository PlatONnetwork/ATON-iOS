//
//  VoteManager.swift
//  platonWallet
//
//  Created by Ned on 24/12/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import BigInt
import platonWeb3_local
import Localize_Swift

let reservePoolingContract = "0x1000000000000000000000000000000000000000"
let candidateContract = "0x1000000000000000000000000000000000000001"
let votePoolingContract = "0x1000000000000000000000000000000000000002"


//block or second
let TicketEffectivePeriod = 1536000

//block or second
let TicketPricePeriod = 3600

//number
let kTicketsPoolCapacity = 51200

//number
let kCandidateMinNumOfTickets = 100


class VoteManager: BaseService {

    static let sharedInstance = VoteManager()
    
    var timer : Timer?
    
    var ticketPrice : BigUInt?
    
    var ticketPoolRemainder: String?
    
    var ticketPoolUsageNum: Int? {
        guard let poolRemainder = Int(ticketPoolRemainder ?? "") else {
            return nil
        }
        return kTicketsPoolCapacity - poolRemainder
    }
    
    var ticketPoolUsageRate: Float? {
        guard ticketPoolUsageNum != nil else {
            return nil
        }
        return Float(ticketPoolUsageNum!) / Float(kTicketsPoolCapacity)
    }
    
    public override init(){
        super.init()
        if true {
            timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(ticketPoolPolling), userInfo: nil, repeats: true)
            timer?.fire()
        }
        
    }
    
    @objc func ticketPoolPolling(){
        
        self.GetTicketPrice(completion: nil)
        self.GetPoolRemainder(completion: nil)
    }
    
    func GetTicketPrice(completion: PlatonCommonCompletion?){
        
        var completion = completion
        let data = self.build_GetTicketPrice()
        
        web3CommonCall(contractAddress: votePoolingContract, data: data, completion: &completion) { (resp) in
            
            guard let price = BigUInt(resp) else {
                self.failCompletionOnMainThread(code: -2, errorMsg: "data parse Error", completion: &completion)
                return
            }
            self.ticketPrice = price
            self.successCompletionOnMain(obj: resp as AnyObject, completion: &completion)
            
        }

    }
    
    func GetPoolRemainder(completion: PlatonCommonCompletion?){
        
        var completion = completion
        let data = build_GetPoolRemainder()
        
        web3CommonCall(contractAddress: votePoolingContract, data: data, completion: &completion) { (resp) in
            self.ticketPoolRemainder = resp
            self.successCompletionOnMain(obj: resp as AnyObject, completion: &completion)
        }
    }
    
    func GetCandidateEpoch(candidateId: String, completion: PlatonCommonCompletion?) {
        
        var completion = completion
        
        let data = self.build_GetCandidateEpoch(candidateId: candidateId)
        
        web3CommonCall(contractAddress: votePoolingContract, data: data, completion: &completion) { (resp) in
            self.successCompletionOnMain(obj: resp as AnyObject, completion: &completion)
        }
        
    }

    func CandidateList(completion: PlatonCommonCompletion?)  {

        var completion = completion
        let data = self.build_CandidateList()
        
        web3CommonCall(contractAddress: candidateContract, data: data, completion: &completion) { (resp) in
            do{
                let list:[Candidate] =  try JSONDecoder().decode([Candidate].self, from: resp.data(using: .utf8)!) 
                self.successCompletionOnMain(obj: list as AnyObject, completion: &completion)
            }catch {
                self.failCompletionOnMainThread(code: -2, errorMsg: "data parse error!!!", completion: &completion)
            }
        }
        
    }
    
    func getMyVoteList(completion: PlatonCommonCompletion?){
        
        var completion = completion
        
        let summary = VotePersistence.getAllNodeVoteList()
        
        //key:ticketID value:candidateID
        var ticketids : Dictionary<String, String> = [:]
        
        //key:CandidateId value:NodeVoteSummary
        var summaryMap : Dictionary<String, NodeVoteSummary> = [:]
        
        //key:CandidateId value:[Ticket]
        var summaryTicketMap : Dictionary<String, [Ticket]> = [:]
        
        guard summary.count > 0 else {
            self.successCompletionOnMain(obj: nil, completion: &completion)
            return
        }
        
        let _ = summary.map { sum in
            let _ = sum.tickets.map({ ticket in
                ticketids[ticket.ticketId!] = sum.CandidateId
            })
            summaryMap[sum.CandidateId!] = sum
            summaryTicketMap[sum.CandidateId!] = []
        }
       
        self.GetBatchTicketDetail(ticketIds: Array(ticketids.keys)) { (result, data) in
            switch result{
                
            case .success:
                
                if let arr = data as? [Ticket] {
                    
                    VotePersistence.updateTickets(arr)
                    let knownIds = arr.map({$0.ticketId ?? ""})
                    let unknownIds = Set(ticketids.keys).subtracting(knownIds)
                    VotePersistence.updateUnknownStatusTickets(Array(unknownIds))

                    for candidateId in summaryMap.keys {
                        summaryMap[candidateId]!.tickets = VotePersistence.getAllTickets().filter({ (ticket) -> Bool in
                            return ticket.candidateId == candidateId
                        })
                    }
                    self.successCompletionOnMain(obj: Array(summaryMap.values) as AnyObject, completion: &completion)
                }else {
                    self.failCompletionOnMainThread(code: -1, errorMsg: "data parse error", completion: &completion)
                }
                
                    
            case .fail(let code, let errMsg):
                self.failCompletionOnMainThread(code: code!, errorMsg: errMsg!, completion: &completion)
            }
        }
        
    }
    
    func CandidateDetails(candidateId: String, completion: PlatonCommonCompletion?) {
        
        var completion = completion
        let data = build_CandidateDetails(candidateId: candidateId)
        
        web3CommonCall(contractAddress: candidateContract, data: data, completion: &completion) { (resp) in
            do{
                let desc: Candidate = try JSONDecoder().decode(Candidate.self, from: resp.data(using: .utf8)!) 
                self.successCompletionOnMain(obj: desc as AnyObject, completion: &completion)
            }catch {
                self.failCompletionOnMainThread(code: -2, errorMsg: "data parse error!!!", completion: &completion)
            }
        }
        
    }
        
    func GetTicketDetail(ticketId: String, completion: PlatonCommonCompletion?) {
        
        var completion = completion
        
        let data = self.build_GetTicketDetail(ticketId: ticketId)
        
        web3CommonCall(contractAddress: votePoolingContract, data: data, completion: &completion) { (resp) in
            do{
                
                let ticket = try JSONDecoder().decode(Ticket.self, from: resp.data(using: .utf8)!)
                
                self.successCompletionOnMain(obj: ticket as AnyObject, completion: &completion)
                
            }catch {
                self.failCompletionOnMainThread(code: -2, errorMsg: "data parse error:\(error.localizedDescription)", completion: &completion)
                
            }
        }
        
       
    }
        
    func GetBatchTicketDetail(ticketIds: [String], completion: PlatonCommonCompletion?){
        var completion = completion
        let data = self.build_GetBatchTicketDetail(ticketIds: ticketIds)
        web3CommonCall(contractAddress: votePoolingContract, data: data, completion: &completion) { (resp) in
            do{
                let arr = try JSONDecoder().decode([Ticket].self, from: resp.data(using: .utf8)!)
                self.successCompletionOnMain(obj: arr as AnyObject, completion: &completion)
                
            }catch {
                self.failCompletionOnMainThread(code: -2, errorMsg: "respData:\(resp) - parse error:\(error.localizedDescription)", completion: &completion)
                
            }
        }
        
    }
    
    func GetBatchCandidateDetail(ids:[String], completion: PlatonCommonCompletion?) {
        
        var completion = completion
        
        let data = build_GetBatchCandidateDetail(nodeIds: ids)
        
        web3CommonCall(contractAddress: candidateContract, data: data, completion: &completion) { (resp) in
            
            do{
                let arr:[Candidate] =  try JSONDecoder().decode([Candidate].self, from: resp.data(using: .utf8)!) 
                
                var resp:[String:Candidate] = [:]
                
                for candidate in arr {
                    resp[candidate.candidateId ?? ""] = candidate
                }
                
                self.successCompletionOnMain(obj: resp as AnyObject, completion: &completion)
            }catch {
                self.failCompletionOnMainThread(code: -2, errorMsg: "data parse error:\(error.localizedDescription)", completion: &completion)
                
            }
            
        }
            
    }
    
    func GetBatchCandidateTicketIds(candidateIds:[String], completion: PlatonCommonCompletion?) {
        
        var completion = completion
        
        let data = self.build_GetBatchCandidateTicketIds(nodeIds: candidateIds)
        
        web3CommonCall(contractAddress: votePoolingContract, data: data, completion: &completion) { (resp) in
            
            do{
                let dic:[String:[String]] =  try JSONDecoder().decode([String:[String]].self, from: resp.data(using: .utf8)!) 
                
                self.successCompletionOnMain(obj: dic as AnyObject, completion: &completion)
            }catch {
                self.failCompletionOnMainThread(code: -2, errorMsg: "data parse error:\(error.localizedDescription)", completion: &completion)
                
            }
        }
        
    }
    
    func GetBatchCandidateTicketCount(candidateIds:[String], completion: PlatonCommonCompletion?) {
        var completion = completion
        let data = build_GetBatchCandidateTicketCount(nodeIds: candidateIds)
        web3CommonCall(contractAddress: votePoolingContract, data: data, completion: &completion) { (resp) in
            do{
                let dic:[String:Int] =  try JSONDecoder().decode([String:Int].self, from: resp.data(using: .utf8)!) 
                
                self.successCompletionOnMain(obj: dic as AnyObject, completion: &completion)
            }catch {
                self.failCompletionOnMainThread(code: -2, errorMsg: "data parse error:\(error.localizedDescription)", completion: &completion)
                
            }
        }
    }
    
    func VoteTicket(count: UInt64, price: BigUInt, nodeId: String, sender: String, privateKey: String, gasPrice: BigUInt, gas: BigUInt, completion: PlatonCommonCompletion?){
        var completion = completion
        let data = self.build_VoteTicket(count: count, price: price, nodeId: nodeId)
        
        let value = EthereumQuantity(quantity: price.multiplied(by: BigUInt(count)))
        web3.eth.platonSendRawTransaction(contractAddress: votePoolingContract, data: data.bytes, sender: sender, privateKey: privateKey, gasPrice: gasPrice, gas: gas,value: value, estimated: false) { (result, data) in
            switch result{
                
            case .success:
                
                guard let txHashData = data else {
                    self.failCompletionOnMainThread(code: -1, errorMsg: "data parse error!", completion: &completion)
                    return
                }
                //add Transaction
                let tx = Transaction()
                tx.txhash = txHashData.toHexString().add0x()
                tx.createTime = Date().millisecondsSince1970
                tx.from = sender.add0x()
                tx.to = votePoolingContract
                tx.value = String(value.quantity)
                tx.gasPrice = String(gasPrice)
                tx.gas = String(gas)
                tx.transactionType = 2
                TransferPersistence.add(tx: tx)
                
                //add SingleVote
                let tickets = Ticket.generateTickets(txHash: txHashData, count: UInt32(count), owner: sender, candidateId: nodeId, price: String(price))
                
                let svote = SingleVote()
                svote.txHash = txHashData.toHexString().add0x()
                svote.candidateId = nodeId
//                svote.candidateName = nodeInfo.name
                svote.owner = sender
                if tickets.count > 0{
                    svote.tickets.append(objectsIn: tickets)
                }
                svote.createTime = Int(Date().timeIntervalSince1970)
                VotePersistence.add(singleVote: svote)
                
                self.successCompletionOnMain(obj: nil, completion: &completion)
                
//                web3.eth.platonGetTransactionReceipt(txHash: (data?.hexString)!, loopTime: 10, completion: { (receptionRes, data) in
//                    switch receptionRes{
//                        
//                    case .success:
//                        
//                        guard let receipt = data as? EthereumTransactionReceiptObject,receipt.logs.count > 0, receipt.logs[0].data.hex().count > 0 else{
//                            self.failCompletionOnMainThread(code: -1, errorMsg: "Can't parse transaction receipt log", completion: &completion)
//                            return
//                        }
//                        
//                        
//                        let logdata = receipt.logs[0].data
//                        let rlpItem = try? RLPDecoder().decode(logdata.bytes)
//                        
//                        guard let dic = try? JSONSerialization.jsonObject(with: Data(bytes: rlpItem!.array![0].bytes!), options: .mutableContainers) as? [String:Any] else{
//                            
//                            self.failCompletionOnMainThread(code: -2, errorMsg: "Can't parse transaction receipt log", completion: &completion)
//                            return 
//                        }
//                        
//                        let txHashData = Data(receipt.transactionHash.bytes)
//                        let countStr = dic!["Data"] as? String ?? "0"
//                        
//                        let tickets = Ticket.generateTickets(txHash: txHashData, count: UInt32(countStr) ?? 0, owner: sender, candidateId: nodeId, price: String(price))
//                        
//                        let svote = SingleVote()
//                        svote.txHash = txHashData.toHexString().add0x()
//                        svote.candidateId = nodeId
//                        svote.candidateName = ""
//                        svote.owner = sender
//                        if tickets.count > 0{
//                            svote.tickets.append(objectsIn: tickets)
//                        }
//                        svote.createTime = Int(Date().timeIntervalSince1970)
//                        
//                        VotePersistence.add(singleVote: svote)
//
//                        self.successCompletionOnMain(obj: nil, completion: &completion)
//                    case .fail(let code, let errMsg):
//                        self.failCompletionOnMainThread(code: code!, errorMsg: errMsg!, completion: &completion)
//                    }
//                })
            case .fail(let code, let errMsg):
                self.failCompletionOnMainThread(code: code!, errorMsg: errMsg!, completion: &completion)
            }
        }
        
    }
    
    //MARK: - 
    func checkMyWalletBalanceIsEnoughToVote() -> (canVote: Bool, errMsg: String) {
        
        let wallets = WalletService.sharedInstance.wallets
        
        guard wallets.count > 0 else {
            
            return (false, Localized("CandidateListVC_vote_noWallet_tips"))
        }
        
        var insufficientBalance = true
        for wallet in wallets {
            
            guard let balance = AssetService.sharedInstace.assets[wallet.key!.address] else {
                continue
            }
            if balance?.balance ?? BigUIntZero > ticketPrice ?? BigUIntZero {
                insufficientBalance = false
                break
            }
            
        }
        guard !insufficientBalance else {
            return (false, Localized("CandidateListVC_vote_insufficient_balance_tips"))
        }
        return (true, "")
    }
    
    //MARK: - Private Func
    private func web3CommonCall(contractAddress: String, data: Data, completion:inout PlatonCommonCompletion?, successCallback: @escaping ((String)->Void)) {
        
        var completion = completion
        
        web3.eth.platonCall(contractAddress: contractAddress, data: data, from: nil, gas: nil, gasPrice: nil, value: nil, outputs: [SolidityFunctionParameter(name: "", type: .string)]) { (res, data) in
            
            switch res{
            case .success:
                
                guard let dic = data as? [String:String], let resp = dic[""] else {
                    self.failCompletionOnMainThread(code: -2, errorMsg: "data parse Error", completion: &completion)
                    return
                }
                successCallback(resp)
                
            case .fail(let code, let msg):
                self.failCompletionOnMainThread(code: code ?? -1, errorMsg: msg ?? "failed", completion: &completion)
            }
            
        }
        
    }

}
