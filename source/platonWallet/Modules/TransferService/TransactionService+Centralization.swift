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
import CryptoSwift
import platonWeb3

//public let requestTimeout = TimeInterval(30.0)

extension TransactionService {

    public func getBatchTransaction(
        addresses: [String],
        beginSequence: Int64,
        listSize: Int,
        direction: String,
        completion: NetworkCompletion<[Transaction]>?) {
        var parameters: Parameters = [:]
        parameters["walletAddrs"] = addresses
        parameters["beginSequence"] = beginSequence
        parameters["listSize"] = listSize
        parameters["direction"] = direction
        NetworkService.request("/transaction/list", parameters: parameters, completion: completion)
    }

    public func getDelegateRecord(
        addresses: [String],
        beginSequence: String,
        listSize: Int,
        direction: String,
        type: String,
        completion: NetworkCompletion<[Transaction]>?) {
        var parameters: Parameters = [:]

        parameters["walletAddrs"] = addresses
        parameters["beginSequence"] = beginSequence
        parameters["listSize"] = listSize
        parameters["direction"] = direction
        parameters["type"] = type

        NetworkService.request("/transaction/delegateRecord", parameters: parameters, completion: completion)
    }

    func getTransactionStatus(
        hashes: [String],
        completion: NetworkCompletion<[TransactionsStatusByHash]>?) {
        var parameters: Parameters = [:]
        parameters["hash"] = hashes
        NetworkService.request("/transaction/getTransactionsStatus", parameters: parameters, completion: completion)
    }

    func getContractGas(from: String, txType: TxType, nodeId: String? = nil, stakingBlockNum: String? = nil, completion: NetworkCompletion<RemoteGas>?) {
        var parameters: Parameters = [:]
        parameters["from"] = from
        parameters["txType"] = txType.rawValue
        if let nid = nodeId {
            parameters["nodeId"] = nid
        }

        if let sBlockNum = stakingBlockNum {
            parameters["stakingBlockNum"] = sBlockNum
        }

        NetworkService.request("/transaction/estimateGas", parameters: parameters, completion: completion)
    }

    func sendSignedTransaction(txType: TxType, minDelgate: String? = nil, isObserverWallet: Bool, data: String, sign: String, completion: NetworkCompletion<String>?) {
        TransactionService.service.sendSignedTransactionToServer(data: data, sign: sign) { (result, txHash) in
            switch result {
            case .success:
                completion?(.success, txHash)
            case .failure(let error):
                guard let error = error else { return }
                switch error {
                case .responeTimeoutError:
                    completion?(.success, "")
                case .serviceError(let code):
                    switch code {
                    case 3001...3009:
                        completion?(.failure(NetworkError.sendSignedData(txType.rawValue, code, minDelgate ?? "0", isObserverWallet)), nil)
                    default:
                        completion?(.failure(error), nil)
                    }
                default:
                    completion?(.failure(error), nil)
                }
            }
        }
    }

    func sendSignedTransactionToServer(data: String, sign: String, completion: NetworkCompletion<String>?) {
        var parameters: Parameters = [:]
        parameters["data"] = data
        parameters["sign"] = sign

        NetworkService.request("/transaction/submitSignedTransaction", parameters: parameters, completion: completion)
    }

    func sendRawTransaction(txType: TxType, minDelgate: String? = nil, isObserverWallet: Bool, data: SignedTransaction, privateKey: String, completion: NetworkCompletion<String>?) {
        guard
            let jsonData = try? JSONEncoder().encode(data),
            let jsonString = String(data: jsonData, encoding: .utf8) else {
            completion?(.failure(NetworkError.jsonEncodeError), nil)
            return
        }

        guard let signResult = signQrcodeData(signedData: data.signedData, remark: data.remark ?? "", privateKey: privateKey) else {
            completion?(.failure(NetworkError.signError), nil)
            return
        }

        sendSignedTransaction(txType: txType, minDelgate: minDelgate, isObserverWallet: isObserverWallet, data: jsonString, sign: signResult, completion: completion)
    }

    func signQrcodeData(signedData: String, remark: String, privateKey: String) -> String? {
        guard let pk = try? EthereumPrivateKey(hexPrivateKey: privateKey) else {
            return nil
        }

        var signedDataBytes = signedData.hexToBytes()
        let remarkBytes = remark.bytes
        signedDataBytes.append(contentsOf: remarkBytes)

        guard
            let sign = try? pk.sign(message: signedDataBytes) else {
                return nil
        }

        var signBytes = Bytes()
        let vBytes = UInt8(sign.v + 27).makeBytes()
        signBytes.append(contentsOf: vBytes)
        signBytes.append(contentsOf: sign.r)
        signBytes.append(contentsOf: sign.s)
        return signBytes.toHexString().add0x()
    }
}
