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

    static func getRewardDelegate(adddresses: [String], beginSequence: Int, listSize: Int, direction: String, completion: NetworkCompletion<[RewardModel]>?) {

        var parameters: Parameters = [:]
        parameters["walletAddrs"] = adddresses
        parameters["beginSequence"] = beginSequence
        parameters["listSize"] = listSize
        parameters["direction"] = direction

        NetworkService.request("/transaction/getRewardTransactions", parameters: parameters, completion: completion)
    }

    static func searchNodes(text: String, type: NodeControllerType, sort: NodeSort) -> [Node] {
        let nodes = NodePersistence.searchNodes(text: text, type: type, sort: sort)
        let sortData = nodeSorted(nodes, sort: sort)
        return sortData
    }

    static func getMyDelegate(adddresses: [String], completion: NetworkCompletion<[Delegate]>?) {
        var parameters: Parameters = [:]
        parameters["walletAddrs"] = adddresses

        NetworkService.request("/node/listDelegateGroupByAddr", parameters: parameters, completion: completion)
    }

    static func getNodeListData(sort: NodeSort, completion: NetworkCompletion<[Node]>?) {
        NetworkService.request("/node/nodelist", completion: completion)
    }

    static func updateNodeListData(sort: NodeSort, completion: NetworkCompletion<[Node]>?) {
        StakingService.getNodeListData(sort: sort) { (result, response) in
            switch result {
            case .success:
                guard let data = response else {
                    completion?(.success, [])
                    return
                }
                // save to database
                NodePersistence.add(nodes: data) {
                }

                let sortData = StakingService.nodeSorted(data, sort: sort)
                completion?(.success, sortData)
            case .failure(let error):
                completion?(.failure(error), nil)
            }
        }
    }

    static func getNodeList(
        controllerType: NodeControllerType,
        sort: NodeSort,
        isFetch: Bool = false,
        completion: NetworkCompletion<[Node]>?) {

        if controllerType == .active && isFetch == false {
            let copyData = NodePersistence.getActiveNode(sort: sort).detached
            let sortData = StakingService.nodeSorted(copyData, sort: sort)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                completion?(.success, sortData)
            }
        } else if controllerType == .candidate && isFetch == false {
            let copyData = NodePersistence.getCandiateNode(sort: sort).detached
            let sortData = StakingService.nodeSorted(copyData, sort: sort)
            // 不延时回调的话，会发生下拉刷新顶部出现位移偏差
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                completion?(.success, sortData)
            }
        } else {
            if isFetch == false {
                let copyData = NodePersistence.getAll(sort: sort).detached
                let sortData = StakingService.nodeSorted(copyData, sort: sort)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    completion?(.success, sortData)
                }
                return
            }
            // 这里本身访问网络请求，存在延时，并不需要设置延时回调
            StakingService.updateNodeListData(sort: sort) { (result, response) in
                switch result {
                case .success:
                    guard let data = response else {
                        completion?(.success, [])
                        return
                    }

                    if controllerType == .active {
                        let oriData = data.filter { $0.nodeStatus == NodeStatus.Active.rawValue }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            completion?(.success, oriData)
                        }
                    } else if controllerType == .candidate {
                        let oriData = data.filter { $0.nodeStatus == NodeStatus.Candidate.rawValue }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            completion?(.success, oriData)
                        }
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            completion?(.success, data)
                        }
                    }
                case .failure(let error):
                    completion?(.failure(error), nil)
                }
            }
        }
    }

    static func getNodeDetail(nodeId: String, completion: NetworkCompletion<NodeDetail>?) {
        var parameters: Parameters = [:]
        parameters["nodeId"] = nodeId
        NetworkService.request("/node/nodeDetails", parameters: parameters, completion: completion)
    }

    static func getDelegateDetail(
        address: String,
        completion: NetworkCompletion<TotalDelegate>?) {
        var parameters: Parameters = [:]
        parameters["addr"] = address
        NetworkService.request("/node/delegateDetails", parameters: parameters, completion: completion)
    }

    static func getDelegationValue(
        addr: String,
        nodeId: String,
        completion: NetworkCompletion<Delegation>?) {
        var parameters: Parameters = [:]
        parameters["addr"] = addr
        parameters["nodeId"] = nodeId
        NetworkService.request("/node/getDelegationValue", parameters: parameters, completion: completion)
    }
}

extension StakingService {
    static func nodeSorted(_ array: [Node], sort: NodeSort) -> [Node] {
        let copyData = array
        let sortData = copyData.sorted(by: { (lhs, rhs) -> Bool in
            switch sort {
            case .rank:
                if lhs.ranking != rhs.ranking {
                    return lhs.ranking < rhs.ranking
                }

                if lhs.delegateSum != rhs.delegateSum {
                    return (BigUInt(lhs.delegateSum ?? "0") ?? BigUInt.zero) > (BigUInt(rhs.delegateSum ?? "0") ?? BigUInt.zero)
                }

                if lhs.delegate != rhs.delegate {
                    return (Int(lhs.delegate ?? "0") ?? 0) > (Int(rhs.delegate ?? "0") ?? 0)
                }

                return (Int(lhs.delegatedRatePA ?? "0") ?? 0) > (Int(rhs.delegatedRatePA ?? "0") ?? 0)
            case .delegated:
                if lhs.delegateSum != lhs.delegateSum {
                    return (BigUInt(lhs.delegateSum ?? "0") ?? BigUInt.zero) > (BigUInt(rhs.delegateSum ?? "0") ?? BigUInt.zero)
                }

                if lhs.ranking != rhs.ranking {
                    return lhs.ranking < rhs.ranking
                }

                if lhs.delegate != rhs.delegate {
                    return (Int(lhs.delegate ?? "0") ?? 0) > (Int(rhs.delegate ?? "0") ?? 0)
                }

                return (Int(lhs.delegatedRatePA ?? "0") ?? 0) > (Int(rhs.delegatedRatePA ?? "0") ?? 0)
            case .delegator:
                if lhs.delegate != rhs.delegate {
                    return (Int(lhs.delegate ?? "0") ?? 0) > (Int(rhs.delegate ?? "0") ?? 0)
                }

                if lhs.ranking != rhs.ranking {
                    return lhs.ranking < rhs.ranking
                }

                if lhs.delegateSum != rhs.delegateSum {
                    return (BigUInt(lhs.delegateSum ?? "0") ?? BigUInt.zero) > (BigUInt(rhs.delegateSum ?? "0") ?? BigUInt.zero)
                }

                return (Int(lhs.delegatedRatePA ?? "0") ?? 0) > (Int(rhs.delegatedRatePA ?? "0") ?? 0)
            case .yield:
                if lhs.delegatedRatePA != rhs.delegatedRatePA {
                    return (Int(lhs.delegatedRatePA ?? "0") ?? 0) > (Int(rhs.delegatedRatePA ?? "0") ?? 0)
                }

                if lhs.ranking != rhs.ranking {
                    return lhs.ranking < rhs.ranking
                }

                if lhs.delegateSum != rhs.delegateSum {
                    return (BigUInt(lhs.delegateSum ?? "0") ?? BigUInt.zero) > (BigUInt(rhs.delegateSum ?? "0") ?? BigUInt.zero)
                }

                return (Int(lhs.delegate ?? "0") ?? 0) > (Int(rhs.delegate ?? "0") ?? 0)
            }
        })
        return sortData
    }
}
