//
//  StakingService.swift
//  platonWallet
//
//  Created by Admin on 8/8/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import Alamofire
import BigInt

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
        
        
        Alamofire.request(request).responseJSON { (response) in
            print(response)
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
    
    func updateNodeListData(completion: PlatonCommonCompletion?) {
        let url = SettingService.debugBaseURL + "node/nodelist"
        
        var request = URLRequest(url: try! url.asURL())
        request.httpMethod = "POST"
        request.timeoutInterval = requestTimeout
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        Alamofire.request(request).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(JSONResponse<[Node]>.self, from: data)
                    
                    NodePersistence.add(nodes: response.data, {
                        completion?(.success, nil)
                    })
                } catch let error {
                    completion?(.fail(-1, error.localizedDescription), nil)
                }
            case .failure(let error):
                completion?(.fail(-1, error.localizedDescription), nil)
            }
        }
    }
    
    func getNodeList(
        controllerType: NodeControllerType,
        isRankingSorted: Bool,
        completion: PlatonCommonCompletion?) {
        var completion = completion
        
        if controllerType == .active {
            let data = NodePersistence.getActiveNode(isRankingSorted: isRankingSorted)
            self.successCompletionOnMain(obj: data as AnyObject, completion: &completion)
        } else if controllerType == .candidate {
            let data = NodePersistence.getCandiateNode(isRankingSorted: isRankingSorted)
            self.successCompletionOnMain(obj: data as AnyObject, completion: &completion)
        } else {
            let datas = NodePersistence.getAll(isRankingSorted: isRankingSorted)
            self.successCompletionOnMain(obj: datas as AnyObject, completion: &completion)
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
        completion: PlatonCommonCompletion?) {
        var completion = completion
        
        var parameters: [String: Any] = [:]
        parameters["addr"] = address
        
        let url = SettingService.debugBaseURL + "node/delegateDetails"
        
        var request = URLRequest(url: try! url.asURL())
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters)
        request.httpMethod = "POST"
        request.timeoutInterval = requestTimeout
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        Alamofire.request(request).responseJSON { (response) in
            print(response)
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
    
    func getDelegationValue(
        addr: String,
        nodeId: String,
        completion: PlatonCommonCompletion?) {
        var completion = completion
        
        var parameters: [String: Any] = [:]
        parameters["addr"] = addr
        parameters["nodeId"] = nodeId
        
        let url = SettingService.debugBaseURL + "node/getDelegationValue"
        
        var request = URLRequest(url: try! url.asURL())
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters)
        request.httpMethod = "POST"
        request.timeoutInterval = requestTimeout
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        Alamofire.request(request).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(JSONResponse<[DelegationValue]>.self, from: data)
                    self.successCompletionOnMain(obj: response.data as AnyObject, completion: &completion)
                } catch let err {
                    self.failCompletionOnMainThread(code: -1, errorMsg: err.localizedDescription, completion: &completion)
                }
            case .failure(let error):
                self.failCompletionOnMainThread(code: -1, errorMsg: error.localizedDescription, completion: &completion)
            }
        }
    }
    
    func getCanDelegation(
        addr: String,
        nodeId: String,
        completion: PlatonCommonCompletion?) {
        var completion = completion
        var parameters: [String: Any] = [:]
        parameters["addr"] = addr
        parameters["nodeId"] = nodeId
        
        let url = SettingService.debugBaseURL + "node/canDelegation"
        
        var request = URLRequest(url: try! url.asURL())
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters)
        request.httpMethod = "POST"
        request.timeoutInterval = requestTimeout
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        Alamofire.request(request).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(JSONResponse<CanDelegation>.self, from: data)
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

extension StakingService {
    func createDelgate(typ: UInt16,
                       nodeId: String,
                       amount: BigUInt,
                       sender: String,
                       privateKey: String,
                       _ completion: PlatonCommonCompletion?) {
        
        web3.staking.createDelegate(typ: typ, nodeId: nodeId, amount: amount, sender: sender, privateKey: privateKey) { (result, data) in
            switch result {
            case .success:
                if let hashData = data {
                    let transaction = Transaction()
                    transaction.txhash = hashData.toHexString().add0x()
                    transaction.from = sender
                    transaction.txType = .delegateCreate
                    transaction.toType = .contract
                    transaction.txReceiptStatus = -1
                    transaction.value = amount.description
                    transaction.nodeId = nodeId
                    DispatchQueue.main.async {
                        completion?(PlatonCommonResult.success, transaction as AnyObject)
                    }
                    
                } else {
                    DispatchQueue.main.async {
                        completion?(PlatonCommonResult.success, nil)
                    }
                    
                }
            case .fail(let errCode, let errMsg):
                DispatchQueue.main.async {
                    completion?(PlatonCommonResult.fail(errCode, errMsg), nil)
                }
            }
        }
    }
    
    func withdrawDelegate(stakingBlockNum: UInt64,
                          nodeId: String,
                          amount: BigUInt,
                          sender: String,
                          privateKey: String,
                          _ completion: PlatonCommonCompletion?) {
        web3.staking.withdrewDelegate(stakingBlockNum: stakingBlockNum, nodeId: nodeId, amount: amount, sender: sender, privateKey: privateKey) { (result, data) in
            switch result {
            case .success:
                if let hashData = data {
                    let transaction = Transaction()
                    transaction.txhash = hashData.toHexString().add0x()
                    transaction.from = sender
                    transaction.txType = .delegateWithdraw
                    transaction.toType = .contract
                    transaction.txReceiptStatus = -1
                    transaction.value = amount.description
                    transaction.nodeId = nodeId
                    DispatchQueue.main.async {
                        completion?(PlatonCommonResult.success, transaction as AnyObject)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion?(PlatonCommonResult.success, nil)
                    }
                }
            case .fail(let errCode, let errMsg):
                DispatchQueue.main.async {
                    completion?(PlatonCommonResult.fail(errCode, errMsg), nil)
                }
            }
        }
    }
}
