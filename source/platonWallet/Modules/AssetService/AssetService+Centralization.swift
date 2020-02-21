//
//  AssetService+Centralization.swift
//  platonWallet
//
//  Created by Admin on 16/8/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import Alamofire

extension AssetService {

    public func getWalletBalances(addrs: [String], completion: PlatonCommonCompletion?) {
        var completion = completion
        var parameters : [String: Any] = [:]

        parameters["addrs"] = addrs

        let url = SettingService.getCentralizationURL() + "/account/getBalance"

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
                    let response = try decoder.decode(JSONResponse<[Balance]>.self, from: data)

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
