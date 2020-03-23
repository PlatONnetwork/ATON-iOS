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

    public func getWalletBalances(addrs: [String], completion: NetworkCompletion<[Balance]>?) {
        var parameters: Parameters = [:]
        parameters["addrs"] = addrs
        NetworkService.request("/account/getBalance", parameters: parameters, completion: completion)
    }
}
