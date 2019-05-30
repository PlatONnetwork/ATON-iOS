//
//  VoteManager+Centralization.swift
//  platonWallet
//
//  Created by Ned on 2019/3/26.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import Localize_Swift
import BigInt

//let CentralizationURL = "http://192.168.9.190:18060/browser-server/"
let requestTimeout : TimeInterval = 30

extension VoteManager{
    
    public func GetBatchMyVoteNodeList(addressList: [String], completion: PlatonCommonCompletion?) {
        var completion = completion
        
        let url = SettingService.getCentralizationURL() + "/node/listUserVoteNode"
        var parameters : Dictionary<String,Any> = [:]
        parameters["walletAddrs"] = addressList
        
        var request = URLRequest(url: try! url.asURL())
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters)
        request.httpMethod = "POST"
        request.timeoutInterval = requestTimeout
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(SettingService.getChainID(), forHTTPHeaderField: "x-aton-cid")
        Alamofire.request(request).responseString { str in
            print("getBatchVoteTransaction response:\(str)")
        }
        
        Alamofire.request(request).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(NoteVoteResponse.self, from: data)
                    self.successCompletionOnMain(obj: response as AnyObject, completion: &completion)
                } catch let err {
                    print("Err", err)
                    self.failCompletionOnMainThread(code: -1, errorMsg: err.localizedDescription, completion: &completion)
                }
            case .failure(let error):
                self.failCompletionOnMainThread(code: -1, errorMsg: error.localizedDescription, completion: &completion)
                break;
            }
        }
    }
    
    public func GetBatchVoteNodeTransactionList(beginSequence: Int, listSize: Int, nodeId: String, direction: String, addressList: [String], completion: PlatonCommonCompletion?) {
        var completion = completion
        var parameters : Dictionary<String,Any> = [:]
        parameters["beginSequence"] = beginSequence
        parameters["listSize"] = listSize
        parameters["nodeId"] = nodeId
        parameters["direction"] = direction
        parameters["walletAddrs"] = addressList
        
        let url = SettingService.getCentralizationURL() + "/transaction/listVote"
        var request = URLRequest(url: try! url.asURL())
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(SettingService.getChainID(), forHTTPHeaderField: "x-aton-cid")
        request.timeoutInterval = requestTimeout
        
        Alamofire.request(request).responseData { (response) in
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(VoteTransactionResponse.self, from: data)
                    self.successCompletionOnMain(obj: response as AnyObject, completion: &completion)
                } catch let err {
                    print("Err", err)
                    self.failCompletionOnMainThread(code: -1, errorMsg: err.localizedDescription, completion: &completion)
                }
            case .failure(let error):
                self.failCompletionOnMainThread(code: -1, errorMsg: error.localizedDescription, completion: &completion)
            }
        }
    }
    
//    public func getBatchVoteSummary(addressList: [String], completion: PlatonCommonCompletion?) {
//        var completion = completion
//        var values : Dictionary<String,Any> = [:]
//        
//        values["cid"] = SettingService.getChainID()
//        values["addressList"] = addressList
//        let url = SettingService.getCentralizationURL() + "/api/getBatchVoteSummary"
//        
//        var request = URLRequest(url: try! url.asURL())
//        request.httpBody = try! JSONSerialization.data(withJSONObject: values)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue(SettingService.getChainID(), forHTTPHeaderField: "x-aton-cid")
//        request.timeoutInterval = requestTimeout
//        
//        Alamofire.request(request).responseJSON { (response) in
//            switch response.result{
//                
//            case .success(let resp):
//                
//                guard let respmap = resp as? [String:Any], let data = respmap["data"] as? [Dictionary<String,Any>] else {
//                    self.failCompletionOnMainThread(code: -1, errorMsg: "", completion: &completion)
//                    return
//                }
//                let nodesum = MyVoteStatic.parserAllNodeSummary(mapArray: data)
//                self.successCompletionOnMain(obj: nodesum as AnyObject, completion: &completion)
//                
//            case .failure(let error):
//                self.failCompletionOnMainThread(code: -1, errorMsg: error.localizedDescription, completion: &completion)
//            }
//        }
//
//    }
    
    public func getBatchVoteTransaction(pageNo:Int = 1, pageSize: Int = 2<<16, completion: PlatonCommonCompletion?) {
        var completion = completion
        var values : Dictionary<String,Any> = [:]
        var walletAddrs: [String] = []
        
        for item in WalletService.sharedInstance.wallets{
            walletAddrs.append((item.key?.address)!)
        }
        
        values["cid"] = SettingService.getChainID()
        values["walletAddrs"] = walletAddrs
        values["pageNo"] = pageNo
        values["pageSize"] = pageSize
         
        let url = SettingService.getCentralizationURL() + "/api/getBatchVoteTransaction"
         
        var request = URLRequest(url: try! url.asURL())
        request.httpBody = try! JSONSerialization.data(withJSONObject: values)
        request.httpMethod = "POST"
        request.timeoutInterval = requestTimeout
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        Alamofire.request(request).responseString { str in
            print("getBatchVoteTransaction response:\(str)")
        }
        Alamofire.request(request).responseJSON { (response) in
            switch response.result{
                
            case .success(let resp):
                
                guard let respd = resp as? [String:Any], let data = respd["data"] as? [Dictionary<String,Any>] else {
                    self.failCompletionOnMainThread(code: -1, errorMsg: Localized("data_parser_error"), completion: &completion)
                    return
                }
                
                DispatchQueue.global().async {
                    let nodesum = NodeVoteSummary.parserWithDicArray(mapArray: data)
                    self.successCompletionOnMain(obj: nodesum as AnyObject, completion: &completion)
                }
                
            case .failure(let error):
                self.failCompletionOnMainThread(code: -1, errorMsg: error.localizedDescription, completion: &completion)
            }
        }
    }
    
    public func GetBatchNodeList(completion: PlatonCommonCompletion?) {
        var completion = completion
        
        let url = SettingService.getCentralizationURL() + "/node/list"
        
        var request = URLRequest(url: try! url.asURL())
        request.httpBody = try! JSONSerialization.data(withJSONObject: [:])
        request.httpMethod = "POST"
        request.timeoutInterval = requestTimeout
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(SettingService.getChainID(), forHTTPHeaderField: "x-aton-cid")
        Alamofire.request(request).responseString { str in
            print("getBatchVoteTransaction response:\(str)")
        }
        
        Alamofire.request(request).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(CandidateResponse.self, from: data)
                    self.ticketPrice = BigUInt(response.ticketPrice ?? "0")
                    self.ticketsPoolCapacity = response.totalCount
                    self.ticketPoolUsageNum = response.voteCount
                    self.successCompletionOnMain(obj: response as AnyObject, completion: &completion)
                } catch let err {
                    print("Err", err)
                    self.failCompletionOnMainThread(code: -1, errorMsg: err.localizedDescription, completion: &completion)
                }
            case .failure(let error):
                self.failCompletionOnMainThread(code: -1, errorMsg: error.localizedDescription, completion: &completion)
                break;
            }
        }
    }
    
    

}
