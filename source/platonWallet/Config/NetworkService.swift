//
//  NetworkService.swift
//  platonWallet
//
//  Created by Admin on 21/2/2020.
//  Copyright © 2020 ju. All rights reserved.
//

import Foundation
import Alamofire

class NetworkService {
    static let sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10.0
        configuration.timeoutIntervalForResource = 50.0
        return SessionManager(configuration: configuration)
    }()

}
