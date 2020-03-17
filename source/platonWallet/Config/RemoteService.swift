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

    static func getConfig(completion: NetworkCompletion<RemoteConfig>?) {
        let headers: HTTPHeaders = ["cache-control": "no-cache"]
        let url = SettingService.shareInstance.getCentralizationHost() + "/config/config.json"
        NetworkService.request(url, headers: headers, isConfig: true, method: .Get, completion: completion)
    }

    static func getRemoteVersion(completion: NetworkCompletion<RemoteVersion>?) {
        guard
            let buildVersionString = Bundle.main.infoDictionary!["CFBundleVersion"] as? String,
            let buildVersion = Int(buildVersionString) else { return }

        var parameters: Parameters = [:]
        parameters["versionCode"] = buildVersion
        parameters["deviceType"] = "ios"
        parameters["channelCode"] = "AppStore"
        NetworkService.request("/config/checkUpdate", parameters: parameters, completion: completion)
    }
}
