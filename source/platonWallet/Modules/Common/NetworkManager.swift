//
//  NetworkManager.swift
//  platonWallet
//
//  Created by Admin on 23/9/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import Alamofire

class NetworkManager {
    static let shared = NetworkManager()

    let reachabilityManager = Alamofire.NetworkReachabilityManager(host: "www.apple.com")
    func startNetworkReachabilityObserver() {
        reachabilityManager?.listener = { _ in
            NotificationCenter.default.post(name: Notification.Name.ATON.DidNetworkStatusChange, object: nil)
        }

        // start listening
        reachabilityManager?.startListening()
    }
}
