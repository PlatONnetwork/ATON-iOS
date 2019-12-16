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

    func getConfig(completion: PlatonCommonCompletion?) {
        let url = SettingService.shareInstance.getCentralizationHost() + "/config/config.json"

        var request = URLRequest(url: try! url.asURL())
        request.httpMethod = "GET"
        request.timeoutInterval = requestTimeout
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        Alamofire.request(request).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(RemoteConfig.self, from: data)

                    completion?(.success, response as AnyObject)
                } catch let err {
                    completion?(.fail(-1, err.localizedDescription), nil)
                }
            case .failure(let error):
                completion?(.fail(-1, error.localizedDescription), nil)
            }
        }
    }

    func getRemoteVersion(completion: PlatonCommonCompletion?) {
        let url = SettingService.shareInstance.getCentralizationHost() + "/config/aton-update.json"

        var request = URLRequest(url: try! url.asURL())
        request.httpMethod = "GET"
        request.timeoutInterval = requestTimeout
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        Alamofire.request(request).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(RemoteVersionResponse.self, from: data)

                    completion?(.success, response.data.ios as AnyObject)
                } catch let err {
                    completion?(.fail(-1, err.localizedDescription), nil)
                }
            case .failure:
                completion?(.fail(-1, nil), nil)
            }
        }
    }
}
