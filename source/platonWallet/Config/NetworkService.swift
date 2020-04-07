//
//  NetworkService.swift
//  platonWallet
//
//  Created by Admin on 21/2/2020.
//  Copyright © 2020 ju. All rights reserved.
//

import Foundation
import Alamofire
import Localize_Swift

enum NetworkError: Error {
    case `default`(Error)
    case jsonDecodeError(Error)
    case jsonEncodeError
    case privateKeyError
    case signError
    case requestTimeoutError(Error)
    case responeTimeoutError(Error)
    case serviceError(Int)
    case knownTransactionError(Int)
    case nonceError(Int)
    case qrcodeExpiredError(Int)
    case transactionFailError
    case sendSignedData(String, Int, String) // txtype,errorcode,mindelegate

    var code: Int {
        switch self {
        case .default(let error):
            return error._code
        case .jsonDecodeError:
            return -2
        case .jsonEncodeError:
            return -3
        case .privateKeyError:
            return -101
        case .signError:
            return -102
        case .requestTimeoutError:
            return -103
        case .responeTimeoutError:
            return -104
        case .serviceError(let c):
            return c
        case .knownTransactionError(let c):
            return c
        case .nonceError(let c):
            return c
        case .qrcodeExpiredError(let c):
            return c
        case .transactionFailError:
            return -32000
        case .sendSignedData(_, let c, _):
            return c
        }
    }

    var message: String {
        switch self {
        case .default(let error):
            return error.localizedDescription
        case .jsonDecodeError:
            return "json to model error"
        case .jsonEncodeError:
            return "model to json error"
        case .privateKeyError:
            return "privatekey error"
        case .signError:
            return "sign error"
        case .requestTimeoutError:
            return Localized("RPC_Response_connectionTimeout")
        case .responeTimeoutError(let error):
            return error.localizedDescription
        case .serviceError(let c):
            return Localized("network_error_default", arguments: c)
        case .knownTransactionError:
            return Localized("network_error_knowntransaction")
        case .nonceError(let c):
            return Localized("network_error_nonce_too_low", arguments: c)
        case .qrcodeExpiredError:
            return Localized("network_error_expired")
        case .transactionFailError:
            return Localized("Transaction.Fail")
        case .sendSignedData(let t, let c, let m):
            switch c {
            case 3001:
                return Localized("error_3001")
            case 3002:
                return Localized("error_3002", arguments: c)
            case 3003:
                return Localized("error_3003")
            case 3004:
                if t == TxType.claimReward.rawValue {
                    return Localized("error_3004_reward")
                } else if t == TxType.delegateCreate.rawValue {
                    return Localized("error_3004_delegate")
                } else if t == TxType.delegateWithdraw.rawValue {
                    return Localized("error_3004_withdraw")
                } else {
                    return Localized("error_3004_transfer")
                }
            case 3005:
                return Localized("error_3005")
            case 3006:
                return Localized("error_3006")
            case 3007:
                return Localized("error_3007")
            case 3008:
                return Localized("error_3008")
            case 3009:
                return Localized("error_3009", arguments: m)
            default:
                return Localized("error_3002", arguments: c)
            }
        }
    }
}

enum NetworkCommonResult : Error {
    case success
    case failure(NetworkError?)
}

typealias NetworkCompletion<T> = (_ result: NetworkCommonResult, _ data: T?) -> Void

class NetworkService {
    enum NetHTTPMethod: String {
        case Get = "GET"
        case Post = "POST"
    }

    static let sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10.0
        configuration.timeoutIntervalForResource = 50.0
        return SessionManager(configuration: configuration)
    }()

    static func basicHeaders(headers: HTTPHeaders?) -> HTTPHeaders {
        var newHeaders: HTTPHeaders = [:]
        if let oldHeaders = headers {
            newHeaders = oldHeaders
        }
        newHeaders["Content-Type"] = "application/json"
        return newHeaders
    }

    static func request<T: Decodable>(_ url: String, parameters: Parameters? = nil, headers: HTTPHeaders? = nil, isConfig: Bool = false, method: NetHTTPMethod = .Post, completion: NetworkCompletion<T>?) {
        var requestUrl = url
        if !url.hasPrefix("http") {
            requestUrl = SettingService.getCentralizationURL() + url
        }

        var request = URLRequest(url: try! requestUrl.asURL())

        if let param = parameters {
            request.httpBody = try! JSONSerialization.data(withJSONObject: param)
        }

        let _ = basicHeaders(headers: headers).map { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        request.allHTTPHeaderFields = basicHeaders(headers: headers)
        request.httpMethod = method.rawValue

        sessionManager.request(request).responseData { response in
            guard let statusCode = response.response?.statusCode, statusCode < 400 else {
                completion?(.failure(NetworkError.serviceError(1)), nil)
                return
            }

            switch response.result {
            case .success(let data):
                do {
                    if isConfig {
                        let decoder = JSONDecoder()
                        let result = try decoder.decode(T.self, from: data)
                        completion?(.success, result)
                        return
                    }

                    let decoder = JSONDecoder()
                    let result = try decoder.decode(JSONResponse<T>.self, from: data)
                    if result.code == 0 {
                        completion?(.success, result.data)
                    } else {
                        switch result.code {
                        case 301:
                            completion?(.failure(NetworkError.knownTransactionError(result.code)), nil)
                        case 302:
                            completion?(.failure(NetworkError.nonceError(result.code)), nil)
                        case 303:
                            completion?(.failure(NetworkError.qrcodeExpiredError(result.code)), nil)
                        case -32000:
                            completion?(.failure(NetworkError.transactionFailError), nil)
                        default:
                            completion?(.failure(NetworkError.serviceError(result.code)), nil)
                        }
                    }
                } catch let error {
                    completion?(.failure(NetworkError.jsonDecodeError(error)), nil)
                }
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    completion?(.failure(NetworkError.responeTimeoutError(error)), nil)
                } else if error._code == NSURLErrorCannotConnectToHost {
                    completion?(.failure(NetworkError.requestTimeoutError(error)), nil)
                } else {
                    completion?(.failure(NetworkError.default(error)), nil)
                }
            }
        }
    }
}

class NetworkStatusService {
    static let shared = NetworkStatusService()

    var handlers: [String: (() -> Void)] = [:]

    var isConnecting: Bool = true {
        didSet {
            for v in handlers {
                v.value()
            }
        }
    }

    let reachabilityManager = Alamofire.NetworkReachabilityManager(host: "www.apple.com")

    func startNetworkObserver() {
        reachabilityManager?.listener = { [weak self] status in
            switch status {
            case .reachable:
                if self?.isConnecting == false {
                    self?.isConnecting = true
                }
            default:
                if self?.isConnecting == true {
                    self?.isConnecting = false
                }
            }
        }
        // start listening
        reachabilityManager?.startListening()
    }
}

extension NetworkStatusService {
    func registerHandler(object: AnyObject?, handler: (() -> Void)?) {
        guard object != nil, handler != nil else {
            return
        }
        let address = String(format: "%d", (object?.hash)!)
        guard address.length > 0 else { return }
        handlers[address] = handler
    }

    func removeHandler(object: AnyObject?) {
        var tmp = object
        withUnsafePointer(to: &tmp) {
            let address = String(format: "%p", $0)
            guard address.length > 0 else { return }
            handlers.removeValue(forKey: address)
        }
    }
}
