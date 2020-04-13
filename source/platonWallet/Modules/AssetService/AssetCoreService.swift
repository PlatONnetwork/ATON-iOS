//
//  AssetCoreService.swift
//  platonWallet
//
//  Created by Admin on 1/4/2020.
//  Copyright © 2020 ju. All rights reserved.
//

import Foundation

class AssetCoreService {
    static let shared = AssetCoreService()
    var handlers: [String: (() -> Void)] = [:]

    var assetVisible: Bool {
        get {
            guard let isHide = UserDefaults.standard.object(forKey: AssetHidingStatus) as? Bool else {
                UserDefaults.standard.set(false, forKey: AssetHidingStatus)
                UserDefaults.standard.synchronize()

                for v in handlers {
                    v.value()
                }
                return false
            }
            return isHide
        }
        set {
            UserDefaults.standard.set(newValue, forKey: AssetHidingStatus)
            UserDefaults.standard.synchronize()

            for v in handlers {
                v.value()
            }
        }
    }
}

extension AssetCoreService {
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
