//
//  CandidateContract.swift
//  platonWeb3Demo
//
//  Created by Ned on 9/1/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import BigInt


class CandidateContract : Contract{
    
    private var web3 : Web3
    
    required init(web3: Web3) {
        self.web3 = web3
    }
    
    private let contractAddress = "0x1000000000000000000000000000000000000001"
    
    func CandidateDeposit(nodeId: String,
                          owner: String,
                          fee: UInt64,
                          host: String,
                          port: String,
                          extra: String,
                          sender: String,
                          privateKey: String,
                          gasPrice: BigUInt,
                          gas: BigUInt,
                          value: BigUInt,
                          completion: PlatonCommonCompletion?
                          ){
        
        let fee_d = Data.newData(unsignedLong: 500, bigEndian: true) //出块奖励佣金比，以10000为基数(eg：5%，则fee=500)

        let params = [
            nodeId.data(using: .utf8)!,
            owner.data(using: .utf8),
            fee_d,
            host.data(using: .utf8),
            port.data(using: .utf8),
            extra.data(using: .utf8)
            ]
        
        var completion = completion
        web3.eth.platonSendRawTransaction(code: ExecuteCode.CampaignPledge, contractAddress: contractAddress, functionName: "CandidateDeposit", params: params as! [Data], sender: sender, privateKey: privateKey, gasPrice: gasPrice, gas: gas, value: EthereumQuantity(quantity: value), estimated: false) { (result, data) in
            switch result{
            case .success:
                self.successCompletionOnMain(obj: data as AnyObject, completion: &completion)
            case .fail(let code, let errorMsg):
                self.failCompletionOnMainThread(code: code!, errorMsg: errorMsg!, completion: &completion)
            }
        }
        
    }
    
    func CandidateApplyWithdraw(nodeId: String,
                                withdraw: BigUInt,
                                sender: String,
                                privateKey: String,
                                gasPrice: BigUInt,
                                gas: BigUInt,
                                value: BigUInt?,
                                completion: PlatonCommonCompletion?){
        
        let v = SolidityWrappedValue(value: withdraw, type: .uint256)
        let withdraw_d = Data(hex: try! ABI.encodeParameter(v))
        
        let params = [nodeId.data(using: .utf8)!,withdraw_d]
        
        var completion = completion
        web3.eth.platonSendRawTransaction(code: ExecuteCode.CampaignPledge, contractAddress: contractAddress, functionName: "CandidateApplyWithdraw", params: params, sender: sender, privateKey: privateKey, gasPrice: gasPrice, gas: gas, value: EthereumQuantity(quantity: value ?? BigUInt(0)), estimated: false) { (result, data) in
            switch result{
            case .success:
                self.successCompletionOnMain(obj: data as AnyObject, completion: &completion)
            case .fail(let code, let errorMsg):
                self.failCompletionOnMainThread(code: code!, errorMsg: errorMsg!, completion: &completion)
            }
        }
    }
    
    func CandidateWithdraw(nodeId: String,
                           sender: String,
                           privateKey: String,
                           gasPrice: BigUInt,
                           gas: BigUInt,
                           value: BigUInt?,
                           completion: PlatonCommonCompletion?){
    
        var completion = completion
        let params = [nodeId.data(using: .utf8)!]
        
        web3.eth.platonSendRawTransaction(code: ExecuteCode.CampaignPledge, contractAddress: contractAddress, functionName: "CandidateWithdraw", params: params, sender: sender, privateKey: privateKey, gasPrice: gasPrice, gas: gas, value: EthereumQuantity(quantity: value ?? BigUInt(0)), estimated: false) { (result, data) in
            switch result{
            case .success:
                self.successCompletionOnMain(obj: data as AnyObject, completion: &completion)
            case .fail(let code, let errorMsg):
                self.failCompletionOnMainThread(code: code!, errorMsg: errorMsg!, completion: &completion)
            }
        }
    }
    
    func SetCandidateExtra(nodeId: String,
                           extra: String,
                           sender: String,
                           privateKey: String,
                           gasPrice: BigUInt,
                           gas: BigUInt,
                           value: BigUInt?,
                           completion: PlatonCommonCompletion?){
        var completion = completion
        let params = [nodeId.data(using: .utf8)!,extra.data(using: .utf8)!]
        
        web3.eth.platonSendRawTransaction(code: ExecuteCode.CampaignPledge, contractAddress: contractAddress, functionName: "SetCandidateExtra", params: params, sender: sender, privateKey: privateKey, gasPrice: gasPrice, gas: gas, value: EthereumQuantity(quantity: value ?? BigUInt(0)), estimated: false) { (result, data) in
            switch result{
            case .success:
                self.successCompletionOnMain(obj: data as AnyObject, completion: &completion)
            case .fail(let code, let errorMsg):
                self.failCompletionOnMainThread(code: code!, errorMsg: errorMsg!, completion: &completion)
            }
        }
    }
    
    
    func CandidateWithdrawInfos(nodeId: String, completion: PlatonCommonCompletion?){
        
        var completion = completion
        let paramter = SolidityFunctionParameter(name: "whateverkey", type: .string)
        
        web3.eth.platonCall(code: ExecuteCode.ContractExecute, contractAddress: contractAddress, functionName: "CandidateWithdrawInfos", from: nil, params: [nodeId.data(using: .utf8)!], outputs: [paramter]) { (result, data) in
            switch result{
            case .success:
                if let dic = data as? Dictionary<String, String>{
                    self.successCompletionOnMain(obj: dic["whateverkey"] as AnyObject, completion: &completion)
                }else{
                    self.successCompletionOnMain(obj: "" as AnyObject, completion: &completion)
                }
            case .fail(let code, let errorMsg):
                self.failCompletionOnMainThread(code: code!, errorMsg: errorMsg!, completion: &completion)
            }
        }
        
    }
    
    func CandidateDetails(nodeId: String,completion: PlatonCommonCompletion?){
        var completion = completion
        let paramter = SolidityFunctionParameter(name: "whateverkey", type: .string)
        
        web3.eth.platonCall(code: ExecuteCode.ContractExecute, contractAddress: contractAddress, functionName: "CandidateDetails", from: nil, params: [nodeId.data(using: .utf8)!], outputs: [paramter]) { (result, data) in
            switch result{
            case .success:
                if let dic = data as? Dictionary<String, String>{
                    self.successCompletionOnMain(obj: dic["whateverkey"] as AnyObject, completion: &completion)
                }else{
                    self.successCompletionOnMain(obj: "" as AnyObject, completion: &completion)
                }
            case .fail(let code, let errorMsg):
                self.failCompletionOnMainThread(code: code!, errorMsg: errorMsg!, completion: &completion)
            }
        }
    }
    
    func GetBatchCandidateDetail(batchNodeIds: String,completion: PlatonCommonCompletion?){
        var completion = completion
        let paramter = SolidityFunctionParameter(name: "whateverkey", type: .string)
        
        web3.eth.platonCall(code: ExecuteCode.ContractExecute, contractAddress: contractAddress, functionName: "GetBatchCandidateDetail", from: nil, params: [batchNodeIds.data(using: .utf8)!], outputs: [paramter]) { (result, data) in
            switch result{
            case .success:
                if let dic = data as? Dictionary<String, String>{
                    self.successCompletionOnMain(obj: dic["whateverkey"] as AnyObject, completion: &completion)
                }else{
                    self.successCompletionOnMain(obj: "" as AnyObject, completion: &completion)
                }
            case .fail(let code, let errorMsg):
                self.failCompletionOnMainThread(code: code!, errorMsg: errorMsg!, completion: &completion)
            }
        }
    }
    
    func CandidateList(completion: PlatonCommonCompletion?){
        var completion = completion
        let paramter = SolidityFunctionParameter(name: "whateverkey", type: .string)
        
        web3.eth.platonCall(code: ExecuteCode.ContractExecute, contractAddress: contractAddress, functionName: "CandidateList", from: nil, params: [], outputs: [paramter]) { (result, data) in
            switch result{
            case .success:
                if let dic = data as? Dictionary<String, String>{
                    self.successCompletionOnMain(obj: dic["whateverkey"] as AnyObject, completion: &completion)
                }else{
                    self.successCompletionOnMain(obj: "" as AnyObject, completion: &completion)
                }
            case .fail(let code, let errorMsg):
                self.failCompletionOnMainThread(code: code!, errorMsg: errorMsg!, completion: &completion)
            }
        }
    }
    
    func VerifiersList(completion: PlatonCommonCompletion?){
        var completion = completion
        let paramter = SolidityFunctionParameter(name: "whateverkey", type: .string)
        
        web3.eth.platonCall(code: ExecuteCode.ContractExecute, contractAddress: contractAddress, functionName: "VerifiersList", from: nil, params: [], outputs: [paramter]) { (result, data) in
            switch result{
            case .success:
                if let dic = data as? Dictionary<String, String>{
                    self.successCompletionOnMain(obj: dic["whateverkey"] as AnyObject, completion: &completion)
                }else{
                    self.successCompletionOnMain(obj: "" as AnyObject, completion: &completion)
                }
            case .fail(let code, let errorMsg):
                self.failCompletionOnMainThread(code: code!, errorMsg: errorMsg!, completion: &completion)
            }
        }
    }
    
    
    
    
    
}

