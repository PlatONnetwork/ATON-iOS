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

//let CentralizationURL = "http://192.168.9.190:18060/browser-server/"
let CentralizationURL = "http://192.168.9.190:10061/a-api/"
let chaindId = "203"

extension VoteManager{
    
    
    public func getBatchVoteSummary(addressList: [String], completion: PlatonCommonCompletion?) {
        var completion = completion
        var values : Dictionary<String,Any> = [:]
        
        values["cid"] = chaindId
        values["addressList"] = addressList
        let url = CentralizationURL + "api/getBatchVoteSummary"
        
        var request = URLRequest(url: try! url.asURL())
        request.httpBody = try! JSONSerialization.data(withJSONObject: values)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10
        
        Alamofire.request(request).responseJSON { (response) in
            switch response.result{
                
            case .success(let resp):
                
                guard let respmap = resp as? [String:Any], let data = respmap["data"] as? [Dictionary<String,Any>] else {
                    self.failCompletionOnMainThread(code: -1, errorMsg: "", completion: &completion)
                    return
                }
                let nodesum = MyVoteStatic.parserAllNodeSummary(mapArray: data)
                self.successCompletionOnMain(obj: nodesum as AnyObject, completion: &completion)
                
            case .failure(_):
                self.failCompletionOnMainThread(code: -1, errorMsg: "", completion: &completion)
            }
        }

    }
    
     
    
    public func getBatchVoteTransaction(pageNo:Int = 1, pageSize: Int = 1000, completion: PlatonCommonCompletion?) {
        var completion = completion
        var values : Dictionary<String,Any> = [:]
        var walletAddrs: [String] = []
        
        for item in WalletService.sharedInstance.wallets{
            walletAddrs.append((item.key?.address)!)
        }
        
        values["cid"] = chaindId
        values["walletAddrs"] = walletAddrs
        values["pageNo"] = pageNo
        values["pageSize"] = pageSize
         
        let url = CentralizationURL + "api/getBatchVoteTransaction"
        
        var request = URLRequest(url: try! url.asURL())
        request.httpBody = try! JSONSerialization.data(withJSONObject: values)
        request.httpMethod = "POST"
        request.timeoutInterval = 10
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        Alamofire.request(request).responseJSON { (response) in
            switch response.result{
                
            case .success(let resp):
                
                guard let resp = resp as? [String:Any], let data = resp["data"] as? [Dictionary<String,Any>] else {
                    self.failCompletionOnMainThread(code: -1, errorMsg: "", completion: &completion)
                    return
                }
                
                let nodesum = NodeVoteSummary.parserWithDicArray(mapArray: data)
                self.successCompletionOnMain(obj: nodesum as AnyObject, completion: &completion)
                
            case .failure(_):
                self.failCompletionOnMainThread(code: -1, errorMsg: "", completion: &completion)
            }
        }
    }
    
    

}
