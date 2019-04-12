//
//  web3+completion.swift
//  platonWallet
//
//  Created by Ned on 8/12/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import Localize_Swift


let onMainPerformTimeout = 5.0

public typealias PlatonCommonCompletion = (_ result : PlatonCommonResult, _ obj : AnyObject?) -> ()

public enum PlatonCommonResult : Error{
    case success
    case fail(Int?,String?)
}

public extension Web3.Eth{
    
    public typealias ContractDeployCompletion = (_ result : PlatonCommonResult, _ transactionHash: String?, _ contractAddress : String?, _ receipt: EthereumTransactionReceiptObject?) -> ()
    
    public typealias ContractCallCompletion = (_ result : PlatonCommonResult, _ data : AnyObject?) -> ()
    
    public typealias ContractSendRawCompletion = (_ result : PlatonCommonResult, _ data : Data?) -> ()
    
    //MARK: - Deploy
    
    func deploy_timeout(completion: inout ContractDeployCompletion?){
        if Thread.current == Thread.main{
            completion?(PlatonCommonResult.fail(-1, Localized("Request_timeout")),nil,nil, nil)
            completion = nil
        }else{
            let semaphore = DispatchSemaphore(value: 0)
            var mc = completion
            DispatchQueue.main.async {
                mc?(PlatonCommonResult.fail(-1, Localized("Request_timeout")),nil,nil, nil)
                mc = nil
                semaphore.signal()
            }
            if semaphore.wait(wallTimeout: .now() + onMainPerformTimeout) == .timedOut{
            }
            completion = nil
        }
    }
    
    func deploy_fail(code: Int, errorMsg: String, completion: inout ContractDeployCompletion?){
        if Thread.current == Thread.main{
            completion?(PlatonCommonResult.fail(code, errorMsg),nil,nil, nil)
            completion = nil
        }else{
            let semaphore = DispatchSemaphore(value: 0)
            var mc = completion
            DispatchQueue.main.async {
                mc?(PlatonCommonResult.fail(code, errorMsg),nil, nil,nil)
                mc = nil
                semaphore.signal()
            }
            if semaphore.wait(wallTimeout: .now() + onMainPerformTimeout) == .timedOut{
            }
            completion = nil
        }
    }
    
    func deploy_success(_ transactionHash: String?,_ contractAddress : String?, _ receipt: EthereumTransactionReceiptObject?,completion: inout ContractDeployCompletion?) {
        if Thread.current == Thread.main{
            completion?(PlatonCommonResult.success,transactionHash,contractAddress, receipt)
            completion = nil
        }else{
            let semaphore = DispatchSemaphore(value: 0)
            var mc = completion
            DispatchQueue.main.async {
                mc?(PlatonCommonResult.success,transactionHash,contractAddress, receipt)
                mc = nil
                semaphore.signal()
            }
            if semaphore.wait(wallTimeout: .now() + onMainPerformTimeout) == .timedOut{
            }
            completion = nil
        }
    }
    
    func deploy_empty(completion: inout ContractDeployCompletion?){
        if Thread.current == Thread.main{
            completion?(PlatonCommonResult.fail(-1, Localized("RPC_Response_empty")),nil, nil,nil)
            completion = nil
        }else{
            let semaphore = DispatchSemaphore(value: 0)
            var mc = completion
            DispatchQueue.main.async {
                mc?(PlatonCommonResult.fail(-1, Localized("RPC_Response_empty")),nil, nil,nil)
                mc = nil
                semaphore.signal()
            }
            if semaphore.wait(wallTimeout: .now() + onMainPerformTimeout) == .timedOut{
            }
            completion = nil
        }
        
    }
    
    
    
    
    //MARK: - Call
    
    func call_timeout(completion: inout ContractCallCompletion?){
        if Thread.current == Thread.main{
            completion?(PlatonCommonResult.fail(-1, Localized("Request_timeout")),nil)
            completion = nil
        }else{
            let semaphore = DispatchSemaphore(value: 0)
            var mc = completion
            DispatchQueue.main.async {
                mc?(PlatonCommonResult.fail(-1, Localized("Request_timeout")),nil)
                mc = nil
                semaphore.signal()
            }
            if semaphore.wait(wallTimeout: .now() + onMainPerformTimeout) == .timedOut{
            }
            completion = nil
        }
    }
    
    func call_fail(code: Int, errorMsg: String, completion: inout ContractCallCompletion?){
        if Thread.current == Thread.main{
            completion?(PlatonCommonResult.fail(code, errorMsg),nil)
            completion = nil
        }else{
            let semaphore = DispatchSemaphore(value: 0)
            var mc = completion
            DispatchQueue.main.async {
                mc?(PlatonCommonResult.fail(code, errorMsg),nil)
                mc = nil
                semaphore.signal()
            }
            if semaphore.wait(wallTimeout: .now() + onMainPerformTimeout) == .timedOut{
            }
            completion = nil
        }
    }
    
    func call_success(dictionary : AnyObject?, completion: inout ContractCallCompletion?) {
        if Thread.current == Thread.main{
            completion?(PlatonCommonResult.success,dictionary)
            completion = nil
        }else{
            let semaphore = DispatchSemaphore(value: 0)
            var mc = completion
            DispatchQueue.main.async {
                mc?(PlatonCommonResult.success,dictionary)
                mc = nil
                semaphore.signal()
            }
            if semaphore.wait(wallTimeout: .now() + onMainPerformTimeout) == .timedOut{
            }
            completion = nil
        }
    }
    
    func call_empty(completion: inout ContractCallCompletion?){
        if Thread.current == Thread.main{
            completion?(PlatonCommonResult.fail(-1, Localized("RPC_Response_empty")),nil)
            completion = nil
        }else{
            let semaphore = DispatchSemaphore(value: 0)
            var mc = completion
            DispatchQueue.main.async {
                mc?(PlatonCommonResult.fail(-1, Localized("RPC_Response_empty")),nil)
                mc = nil
                semaphore.signal()
            }
            if semaphore.wait(wallTimeout: .now() + onMainPerformTimeout) == .timedOut{
            }
            completion = nil
        }
        
    }
    
    
    
    //MARK: - Transaction
    
    func sendRawTransaction_timeout(completion: inout ContractSendRawCompletion?){
        if Thread.current == Thread.main{
            completion?(PlatonCommonResult.fail(-1, Localized("Request_timeout")),nil)
            completion = nil
        }else{
            let semaphore = DispatchSemaphore(value: 0)
            var mc = completion
            DispatchQueue.main.async {
                mc?(PlatonCommonResult.fail(-1, Localized("Request_timeout")),nil)
                mc = nil
                semaphore.signal()
            }
            if semaphore.wait(wallTimeout: .now() + onMainPerformTimeout) == .timedOut{
            }
            completion = nil
        }
    }
    
    func sendRawTransaction_fail(code: Int, errorMsg: String, completion: inout ContractSendRawCompletion?){
        if Thread.current == Thread.main{
            completion?(PlatonCommonResult.fail(code, errorMsg),nil)
            completion = nil
        }else{
            let semaphore = DispatchSemaphore(value: 0)
            var mc = completion
            DispatchQueue.main.async {
                mc?(PlatonCommonResult.fail(code, errorMsg),nil)
                mc = nil
                semaphore.signal()
            }
            if semaphore.wait(wallTimeout: .now() + onMainPerformTimeout) == .timedOut{
            }
            completion = nil
        }
    }
    
    func sendRawTransaction_success(data : Data?, completion: inout ContractSendRawCompletion?) {
        if Thread.current == Thread.main{
            completion?(PlatonCommonResult.success,data)
            completion = nil
        }else{
            let semaphore = DispatchSemaphore(value: 0)
            var mc = completion
            DispatchQueue.main.async {
                mc?(PlatonCommonResult.success,data)
                mc = nil
                semaphore.signal()
            }
            if semaphore.wait(wallTimeout: .now() + onMainPerformTimeout) == .timedOut{
            }
            completion = nil
        }
    }
    
    func sendRawTransaction_empty(completion: inout ContractSendRawCompletion?){
        if Thread.current == Thread.main{
            completion?(PlatonCommonResult.fail(-1, Localized("RPC_Response_empty")),nil)
            completion = nil
        }else{
            let semaphore = DispatchSemaphore(value: 0)
            var mc = completion
            DispatchQueue.main.async {
                mc?(PlatonCommonResult.fail(-1, Localized("RPC_Response_empty")),nil)
                mc = nil
                semaphore.signal()
            }
            if semaphore.wait(wallTimeout: .now() + onMainPerformTimeout) == .timedOut{
            }
            completion = nil
        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    func timeOutCompletionOnMainThread(completion: PlatonCommonCompletion?){
        var completion = completion
        DispatchQueue.main.async {
            completion?(PlatonCommonResult.fail(-1, Localized("Request_timeout")),nil)
            completion = nil
        }
    }
    
    func failCompletionOnMainThread(code: Int, errorMsg: String,completion: PlatonCommonCompletion?){
        var completion = completion
        DispatchQueue.main.async {
            completion?(PlatonCommonResult.fail(code, errorMsg),nil)
            completion = nil
        }
    }
    
    func failWithEmptyResponseCompletionOnMainThread(completion: PlatonCommonCompletion?){
        var completion = completion
        DispatchQueue.main.async {
            completion?(PlatonCommonResult.fail(-1, Localized("RPC_Response_empty")),nil)
            completion = nil
        }
    }
    
    func successCompletionOnMain(obj : AnyObject?,completion: PlatonCommonCompletion?){
        var completion = completion
        DispatchQueue.main.async {
            completion?(PlatonCommonResult.success,obj)
            completion = nil
        }
    }

    
}
