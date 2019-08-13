//
//  StakingService.swift
//  platonWallet
//
//  Created by Admin on 8/8/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import Alamofire

final class StakingService: BaseService {
    
    static let sharedInstance = StakingService()
    
    func getMyDelegate(adddresses: [String], completion: PlatonCommonCompletion?) {
        var completion = completion
        var parameters: [String: Any] = [:]
        parameters["walletAddrs"] = adddresses
        
        let url = SettingService.debugBaseURL + "node/listDelegateGroupByAddr"
        
        var request = URLRequest(url: try! url.asURL())
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters)
        request.httpMethod = "POST"
        request.timeoutInterval = requestTimeout
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(SettingService.getChainID(), forHTTPHeaderField: "x-aton-cid")
        
        Alamofire.request(request).responseJSON { (result) in
            print(result)
        }
        
        Alamofire.request(request).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(JSONResponse<[Delegate]>.self, from: data)
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
    
    func getNodeList(completion: PlatonCommonCompletion?) {
        var completion = completion
        
        let url = SettingService.debugBaseURL + "node/nodelist"
        
        var request = URLRequest(url: try! url.asURL())
        request.httpMethod = "POST"
        request.timeoutInterval = requestTimeout
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(SettingService.getChainID(), forHTTPHeaderField: "x-aton-cid")
        
        Alamofire.request(request).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(JSONResponse<[Node]>.self, from: data)
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
    
    func getNodeDetail(nodeId: String, completion: PlatonCommonCompletion?) {
        var completion = completion
        var parameters: [String: Any] = [:]
        parameters["nodeId"] = nodeId
        
        let url = SettingService.debugBaseURL + "node/nodeDetails"
        
        var request = URLRequest(url: try! url.asURL())
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters)
        request.httpMethod = "POST"
        request.timeoutInterval = requestTimeout
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(SettingService.getChainID(), forHTTPHeaderField: "x-aton-cid")
        
        Alamofire.request(request).responseJSON { (result) in
            print(result)
        }
        
        Alamofire.request(request).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(JSONResponse<NodeDetail>.self, from: data)
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
    
    func getDelegateDetail(
        address: String,
        beginSequence: String,
        direction: String,
        listSize: Int,
        completion: PlatonCommonCompletion?) {
        var completion = completion
        
        var parameters: [String: Any] = [:]
        parameters["addr"] = address
        parameters["beginSequence"] = beginSequence
        parameters["listSize"] = listSize
        parameters["direction"] = direction
        
        let url = SettingService.debugBaseURL + "node/delegateDetails"
        
        var request = URLRequest(url: try! url.asURL())
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters)
        request.httpMethod = "POST"
        request.timeoutInterval = requestTimeout
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(SettingService.getChainID(), forHTTPHeaderField: "x-aton-cid")
        
        Alamofire.request(request).responseJSON { (result) in
            print(result)
        }
        
        Alamofire.request(request).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(JSONResponse<[DelegateDetail]>.self, from: data)
                    self.successCompletionOnMain(obj: response.data as AnyObject, completion: &completion)
                } catch let err {
                    self.failCompletionOnMainThread(code: -1, errorMsg: err.localizedDescription, completion: &completion)
                }
            case .failure(let error):
                self.failCompletionOnMainThread(code: -1, errorMsg: error.localizedDescription, completion: &completion)
            }
        }
    }
    
    
}
