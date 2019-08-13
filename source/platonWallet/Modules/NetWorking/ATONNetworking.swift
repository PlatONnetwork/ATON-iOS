//
//  ATONNetworking.swift
//  platonWallet
//
//  Created by Admin on 8/8/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation

public enum HTTPMethod: String {
    case GET
    case OPTIONS
    case HEAD
    case POST
    case PUT
    case PATCH
    case DELETE
}

public protocol URLComponentsConvertible {
    var urlComponents: URLComponents? { get }
}

public final class HTTPResult: NSObject {
    public final var content: Data?
    public var response: URLResponse?
    public var error: Error?
    public var task: URLSessionTask?
    public var request: URLRequest? { return task?.originalRequest }
    public var encoding = String.Encoding.utf8
    public var JSONReadingOptions = JSONSerialization.ReadingOptions(rawValue: 0)
    
    public var statusCode: Int? {
        return (self.response as? HTTPURLResponse)?.statusCode
    }
    
    public var reason: String {
        if let error = self.error {
            return error.localizedDescription
        }
        return "Unknown"
    }
    
    public var isRedirect: Bool {
        if let code = self.statusCode {
            return code >= 300 && code < 400
        }
        return false
    }
    
    public override var description: String {
        if let status = statusCode,
           let urlString = request?.url?.absoluteString,
           let method = request?.httpMethod {
            return "\(method) \(urlString) \(status)"
        } else {
            return "<Empty>"
        }
    }
    
    public init(data: Data?, response: URLResponse?, error: Error?, task: URLSessionTask?) {
        self.content = data
        self.response = response
        self.error = error
        self.task = task
    }
    
    public var json: Any? {
        return content.flatMap {
            try? JSONSerialization.jsonObject(with: $0, options: JSONReadingOptions)
        }
    }
    
    public var text: String? {
        return content.flatMap { String(data: $0, encoding: encoding) }
    }
    
    
    
    
}

//public protocol Adaptor {
//    func request(
//        _ method: HTTPMethod,
//        url: URLComponentsConvertible,
//        params: [String: Any],
//        data: [String: Any],
//        json: Any?,
//        headers: [String: String],
//        cookies: [String: String],
//        redirects: Bool,
//        timeout: Double?,
//        urlQuery: String?,
//        requestBody: Data?,
////        asyncProgressHandler: Task
//    )
//}


//public struct CaseInsensitiveDictionary<Key: Hashable, Value>: Collection, ExpressibleByDictionaryLiteral {
//    private var _data: [Key: Value] = [:]
//    private var _keyMap: [String: Key] = [:]
//
//    public typealias Element = (key: Key, value: Value)
//    public typealias Index = DictionaryIndex<Key, Value>
//    public var startIndex: Dictionary<Key, Value>.Index
//}
//
//typealias TaskID = Int
//public typealias TaskCompletionHandler = (HTTP)
//
//final class ATONNetworking<T: Codable> {
//    open let session: URLSession
//
//    typealias CompletionJSONClosure = (_ data: T) -> Void
//    var completionJSONClosure: CompletionJSONClosure = { _ in }
//
//    public init() {
//        self.session = URLSession.shared
//    }
//
//    func requestJSON(_ url: ATONURLNetworking,
//                     doneClosure: @escaping CompletionJSONClosure) {
//        self.completionJSONClosure = doneClosure
//        let request: URLRequest = URLRequest(url: url.asURL())
//        let task = self.session.dataTask(with: request) { (data, res, error) in
//            if error == nil {
//                let decoder = JSONDecoder()
//                do {
//                    let jsonModel = try decoder.decode(T.self, from: data!)
//                    self.completionJSONClosure(jsonModel)
//                } catch {
//                    print("JSON parser failure")
//                }
//            }
//        }
//        task.resume()
//    }
//}

