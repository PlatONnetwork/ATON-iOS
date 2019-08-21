//
//  TransactionService+Centralization.swift
//  platonWallet
//
//  Created by Admin on 14/5/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import Alamofire
import Localize_Swift

public let requestTimeout = TimeInterval(30.0)

extension TransactionService {
    
    public func getBatchTransaction(
        addresses: [String],
        beginSequence: Int,
        listSize: Int,
        direction: String,
        completion: PlatonCommonCompletion?) {
        var completion = completion
        var parameters : Dictionary<String,Any> = [:]
        
        parameters["walletAddrs"] = addresses
        parameters["beginSequence"] = beginSequence
        parameters["listSize"] = listSize
        parameters["direction"] = direction
        
        let url = SettingService.debugBaseURL + "transaction/list"
        
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
                    let response = try decoder.decode(TransactionResponse.self, from: data)
                    self.successCompletionOnMain(obj: response.data as AnyObject, completion: &completion)
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
    
    public func getDelegateRecord(
        addresses: [String],
        beginSequence: String,
        listSize: Int,
        direction: String,
        type: String,
        completion: PlatonCommonCompletion?) {
        var completion = completion
        var parameters : Dictionary<String,Any> = [:]
        
        parameters["walletAddrs"] = addresses
        parameters["beginSequence"] = beginSequence
        parameters["listSize"] = listSize
        parameters["direction"] = direction
        parameters["type"] = type
        
        let url = SettingService.debugBaseURL + "transaction/delegateRecord"
        
        var request = URLRequest(url: try! url.asURL())
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters)
        request.httpMethod = "POST"
        request.timeoutInterval = requestTimeout
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(SettingService.getChainID(), forHTTPHeaderField: "x-aton-cid")
        
        Alamofire.request(request).responseString { str in
            print("getDelegateRecord response:\(str)")
        }
        
        Alamofire.request(request).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(JSONResponse<[Transaction]>.self, from: data)
                    self.successCompletionOnMain(obj: response.data as AnyObject, completion: &completion)
                } catch let err {
                    self.failCompletionOnMainThread(code: -1, errorMsg: err.localizedDescription, completion: &completion)
                }
            case .failure(let error):
                self.failCompletionOnMainThread(code: -1, errorMsg: error.localizedDescription, completion: &completion)
                break;
            }
        }
    }
}
