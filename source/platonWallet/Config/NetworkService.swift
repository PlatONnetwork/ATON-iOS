//
//  NetworkService.swift
//  platonWallet
//
//  Created by Admin on 21/2/2020.
//  Copyright © 2020 ju. All rights reserved.
//

import Foundation
import Alamofire

enum NetworkError: Error {
    case `default`(Error)
    case jsonDecodeError(Error)
    case queryParameterError
    case serverError

    var code: Int {
        switch self {
        case .default(let error):
            return error._code
        case .jsonDecodeError:
            return -2
        case .queryParameterError:
            return -1
        case .serverError:
            return -100
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

    static func request<T: Codable>(_ url: String, parameters: Parameters? = nil, headers: HTTPHeaders? = nil, method: NetHTTPMethod = .Post, completion: NetworkCompletion<T>?) {
        let requestUrl = SettingService.getCentralizationURL() + url
        var request = URLRequest(url: try! requestUrl.asURL())

        if let param = parameters {
            request.httpBody = try! JSONSerialization.data(withJSONObject: param)
        }

        let _ = basicHeaders(headers: headers).map { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        request.allHTTPHeaderFields = basicHeaders(headers: headers)
        request.httpMethod = method.rawValue

        sessionManager.request(request).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(JSONResponse<T>.self, from: data)
                    if result.code == NetworkError.queryParameterError.code {
                        completion?(.failure(NetworkError.queryParameterError), nil)
                    } else if result.code == NetworkError.serverError.code {
                        completion?(.failure(NetworkError.serverError), nil)
                    } else {
                        completion?(.success, result.data)
                    }
                } catch let error {
                    completion?(.failure(NetworkError.jsonDecodeError(error)), nil)
                }
            case .failure(let error):
                completion?(.failure(NetworkError.default(error)), nil)
            }
        }
    }
}
