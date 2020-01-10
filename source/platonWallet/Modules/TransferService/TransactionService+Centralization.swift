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
        beginSequence: Int64,
        listSize: Int,
        direction: String,
        completion: PlatonCommonCompletion?) {
        var completion = completion
        var parameters : Dictionary<String,Any> = [:]

        parameters["walletAddrs"] = addresses
        parameters["beginSequence"] = beginSequence
        parameters["listSize"] = listSize
        parameters["direction"] = direction

        let url = SettingService.getCentralizationURL() + "/transaction/list"

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
                    let response = try decoder.decode(TransactionResponse.self, from: data)
                    self.successCompletionOnMain(obj: response.data as AnyObject, completion: &completion)
                } catch let err {
                    print("Err", err)
                    self.failCompletionOnMainThread(code: -1, errorMsg: err.localizedDescription, completion: &completion)
                }
            case .failure(let error):
                self.failCompletionOnMainThread(code: -1, errorMsg: error.localizedDescription, completion: &completion)
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

        let url = SettingService.getCentralizationURL() + "/transaction/delegateRecord"

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
                    let response = try decoder.decode(JSONResponse<[Transaction]>.self, from: data)
                    self.successCompletionOnMain(obj: response.data as AnyObject, completion: &completion)
                } catch let err {
                    self.failCompletionOnMainThread(code: -1, errorMsg: err.localizedDescription, completion: &completion)
                }
            case .failure(let error):
                self.failCompletionOnMainThread(code: -1, errorMsg: error.localizedDescription, completion: &completion)
            }
        }
    }

    func getTransactionStatus(
        hashes: [String],
        completion: PlatonCommonCompletion?) {
        var completion = completion
        var parameters : Dictionary<String,Any> = [:]
        parameters["hash"] = hashes

        let url = SettingService.getCentralizationURL() + "/transaction/getTransactionsStatus"

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
                    let response = try decoder.decode(JSONResponse<[TransactionsStatusByHash]>.self, from: data)
                    self.successCompletionOnMain(obj: response.data as AnyObject, completion: &completion)
                } catch let err {
                    self.failCompletionOnMainThread(code: -1, errorMsg: err.localizedDescription, completion: &completion)
                }
            case .failure(let error):
                self.failCompletionOnMainThread(code: -1, errorMsg: error.localizedDescription, completion: &completion)
            }
        }
    }

    func getContractGas(from: String, txType: TxType, completion: CommonCompletion<RemoteGas>?) {
        var parameters : Dictionary<String,Any> = [:]
        parameters["from"] = from
        parameters["txType"] = txType.rawValue

        let url = SettingService.getCentralizationURL() + "/transaction/estimateGas"

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
                    let response = try decoder.decode(JSONResponse<RemoteGas>.self, from: data)
                    completion?(.success, response.data)
                } catch let err {
                    completion?(.fail(-1, err.localizedDescription), nil)
                }
            case .failure(let error):
                completion?(.fail(-1, error.localizedDescription), nil)
            }
        }
    }
}
