//
//  RemoteService.swift
//  platonWallet
//
//  Created by Admin on 30/10/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import Alamofire

class RemoteService {

    static let sharedInstance = RemoteService()

    func getConfig(completion: NetworkCompletion<RemoteConfig>?) {
        let headers: HTTPHeaders = ["cache-control": "no-cache"]
        NetworkService<RemoteConfig>.request("/config/config.json", headers: headers, method: .Get) { (result, data) in
            switch result {
            case .success:
                completion?(.success, data)
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }

    func getRemoteVersion(versionCode: Int, completion: PlatonCommonCompletion?) {
        let url = SettingService.getCentralizationURL() + "/config/checkUpdate"

        var parameters: [String: Any] = [:]
        parameters["versionCode"] = versionCode
        parameters["deviceType"] = "ios"
        parameters["channelCode"] = "AppStore"

        var request = URLRequest(url: try! url.asURL())
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters)
        request.httpMethod = "POST"
//        request.timeoutInterval = requestTimeout
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        NetworkService.sessionManager.request(request).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(RemoteVersionResponse.self, from: data)

                    completion?(.success, response.data as AnyObject)
                } catch let err {
                    completion?(.fail(-1, err.localizedDescription), nil)
                }
            case .failure:
                completion?(.fail(-1, nil), nil)
            }
        }
    }
}
