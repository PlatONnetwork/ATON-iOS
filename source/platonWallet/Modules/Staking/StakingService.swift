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
import platonWeb3

final class StakingService: BaseService {

    static let sharedInstance = StakingService()

    func getMyDelegate(adddresses: [String], completion: PlatonCommonCompletion?) {
        var completion = completion
        var parameters: [String: Any] = [:]
        parameters["walletAddrs"] = adddresses

        let url = SettingService.getCentralizationURL() + "/node/listDelegateGroupByAddr"

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
                    let response = try decoder.decode(JSONResponse<[Delegate]>.self, from: data)
                    self.successCompletionOnMain(obj: response.data as AnyObject, completion: &completion)
                } catch let err {
                    self.failCompletionOnMainThread(code: -1, errorMsg: err.localizedDescription, completion: &completion)
                }
            case .failure(let error):
                self.failCompletionOnMainThread(code: -1, errorMsg: error.localizedDescription, completion: &completion)
                break
            }
        }
    }

    func updateNodeListData(isRankingSorted: Bool = true, completion: ((_ result : PlatonCommonResult, _ obj : [Node]) -> Void)?) {
        let url = SettingService.getCentralizationURL() + "/node/nodelist"

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
                    let copyData = response.data.detached
                    let sortData = copyData.sorted(by: { (lhs, rhs) -> Bool in
                        return isRankingSorted ? Int(lhs.ratePA ?? "0") ?? 0 > Int(rhs.ratePA ?? "0") ?? 0 : lhs.ranking < rhs.ranking
                    }).sorted(by: { (lhs, rhs) -> Bool in
                        return isRankingSorted ? lhs.ranking < rhs.ranking : Int(lhs.ratePA ?? "0") ?? 0 > Int(rhs.ratePA ?? "0") ?? 0
                    })

                    DispatchQueue.main.async {
                        completion?(.success, sortData)
                    }
                    NodePersistence.add(nodes: response.data, nil)
                } catch let error {
                    completion?(.fail(-1, error.localizedDescription), [])
                }
            case .failure(let error):
                completion?(.fail(-1, error.localizedDescription), [])
            }
        }
    }

    func getNodeList(
        controllerType: NodeControllerType,
        isRankingSorted: Bool,
        isFetch: Bool = false,
        completion: PlatonCommonCompletion?) {

        if controllerType == .active && isFetch == false {
            let copyData = NodePersistence.getActiveNode(isRankingSorted: isRankingSorted).detached
            let sortData = copyData.sorted(by: { (lhs, rhs) -> Bool in
                return isRankingSorted ? Int(lhs.ratePA ?? "0") ?? 0 > Int(rhs.ratePA ?? "0") ?? 0 : lhs.ranking < rhs.ranking
            }).sorted(by: { (lhs, rhs) -> Bool in
                return isRankingSorted ? lhs.ranking < rhs.ranking : Int(lhs.ratePA ?? "0") ?? 0 > Int(rhs.ratePA ?? "0") ?? 0
            })

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                completion?(.success, sortData as AnyObject)
            }
        } else if controllerType == .candidate && isFetch == false {
            let copyData = NodePersistence.getCandiateNode(isRankingSorted: isRankingSorted).detached
            let sortData = copyData.sorted(by: { (lhs, rhs) -> Bool in
                return isRankingSorted ? Int(lhs.ratePA ?? "0") ?? 0 > Int(rhs.ratePA ?? "0") ?? 0 : lhs.ranking < rhs.ranking
            }).sorted(by: { (lhs, rhs) -> Bool in
                return isRankingSorted ? lhs.ranking < rhs.ranking : Int(lhs.ratePA ?? "0") ?? 0 > Int(rhs.ratePA ?? "0") ?? 0
            })
            // 不延时回调的话，会发生下拉刷新顶部出现位移偏差
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                completion?(.success, sortData as AnyObject)
            }
        } else {
            // 这里本身访问网络请求，存在延时，并不需要设置延时回调
            updateNodeListData(isRankingSorted: isRankingSorted) { (result, data) in
                switch result {
                case .success:
                    if controllerType == .active {
                        let oriData = data.filter { $0.nodeStatus == NodeStatus.Active.rawValue }
                        let sortData = oriData.sorted(by: { (lhs, rhs) -> Bool in
                            return isRankingSorted ? Int(lhs.ratePA ?? "0") ?? 0 > Int(rhs.ratePA ?? "0") ?? 0 : lhs.ranking < rhs.ranking
                        }).sorted(by: { (lhs, rhs) -> Bool in
                            return isRankingSorted ? lhs.ranking < rhs.ranking : Int(lhs.ratePA ?? "0") ?? 0 > Int(rhs.ratePA ?? "0") ?? 0
                        })
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            completion?(.success, sortData as AnyObject)
                        }
                    } else if controllerType == .candidate {
                        let oriData = data.filter { $0.nodeStatus == NodeStatus.Candidate.rawValue }
                        let sortData = oriData.sorted(by: { (lhs, rhs) -> Bool in
                            return isRankingSorted ? Int(lhs.ratePA ?? "0") ?? 0 > Int(rhs.ratePA ?? "0") ?? 0 : lhs.ranking < rhs.ranking
                        }).sorted(by: { (lhs, rhs) -> Bool in
                            return isRankingSorted ? lhs.ranking < rhs.ranking : Int(lhs.ratePA ?? "0") ?? 0 > Int(rhs.ratePA ?? "0") ?? 0
                        })
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            completion?(.success, sortData as AnyObject)
                        }
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            completion?(.success, data as AnyObject)
                        }
                    }
                case .fail(let errCode, let errMessage):
                    completion?(.fail(errCode, errMessage), nil)
                }

            }
        }
    }

    func getNodeDetail(nodeId: String, completion: PlatonCommonCompletion?) {
        var completion = completion
        var parameters: [String: Any] = [:]
        parameters["nodeId"] = nodeId

        let url = SettingService.getCentralizationURL() + "/node/nodeDetails"

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
            }
        }
    }

    func getDelegateDetail(
        address: String,
        completion: PlatonCommonCompletion?) {
        var completion = completion

        var parameters: [String: Any] = [:]
        parameters["addr"] = address

        let url = SettingService.getCentralizationURL() + "/node/delegateDetails"

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

        let url = SettingService.getCentralizationURL() + "/node/getDelegationValue"

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
                    let response = try decoder.decode(JSONResponse<Delegation>.self, from: data)
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

        let url = SettingService.getCentralizationURL() + "/node/canDelegation"

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
                       gas: BigUInt?,
                       gasPrice: BigUInt?,
                       _ completion: PlatonCommonCompletion?) {

        web3.staking.createDelegate(typ: typ, nodeId: nodeId, amount: amount, sender: sender, privateKey: privateKey, gas: gas, gasPrice: gasPrice) { (result, data) in
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
                    transaction.direction = .Sent
                    transaction.confirmTimes = Int(Date().timeIntervalSince1970 * 1000)
                    transaction.to = PlatonConfig.ContractAddress.stakingContractAddress
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
                          gas: BigUInt?,
                          gasPrice: BigUInt?,
                          _ completion: PlatonCommonCompletion?) {
        web3.staking.withdrewDelegate(stakingBlockNum: stakingBlockNum, nodeId: nodeId, amount: amount, sender: sender, privateKey: privateKey, gas: gas, gasPrice: gasPrice) { (result, data) in
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
                    transaction.confirmTimes = Int(Date().timeIntervalSince1970 * 1000)
                    transaction.direction = .Receive
                    transaction.to = PlatonConfig.ContractAddress.stakingContractAddress
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
