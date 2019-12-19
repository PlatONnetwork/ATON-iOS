//
//  AssetVCSharedData.swift
//  platonWallet
//
//  Created by Ned on 19/3/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation

typealias DidSwithWalletHandler = () -> Void

enum WalletSortType {
    case createTime, userArrangement
}

class AssetVCSharedData {

    static let sharedData = AssetVCSharedData()

    var walletChangeHandlers: Dictionary<String, DidSwithWalletHandler> = [:]

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(didSwithNode), name: NSNotification.Name(NodeStoreService.didSwitchNodeNotification), object: nil)
    }

    var walletList: [Any] {
        get {
            var tmp: [Any] = []
            tmp.append(contentsOf: WalletService.sharedInstance.wallets)

            var rangeWallets = tmp.filter { obj -> Bool in
                if let cwallet = obj as? Wallet {
                    return cwallet.userArrangementIndex != -1
                }
                return false
            }
            rangeWallets.userArrangementSort()

            var unrangeWallets = tmp.filter { obj -> Bool in
                if let cwallet = obj as? Wallet {
                    return cwallet.userArrangementIndex == -1
                }
                return false
            }
            unrangeWallets.walletCreateTimeSort()

            var newSorted: [Any] = []
            newSorted.append(contentsOf: rangeWallets)
            newSorted.append(contentsOf: unrangeWallets)
            return newSorted
        }
    }

    var currentWalletAddress: String? {
        didSet {
            for v in walletChangeHandlers {
                v.value()
            }
        }
    }

    var selectedWallet: AnyObject? {
        guard
            let address = currentWalletAddress,
            let wallet = (walletList as? [Wallet])?.first(where: { $0.address.lowercased() == address.lowercased() })
            else {
                if let defaultWallet = walletList.first as? Wallet {
                    currentWalletAddress = defaultWallet.address
                    return defaultWallet
                }
                return nil
        }
        return wallet as AnyObject
    }

//    var selectedWallet: AnyObject? {
//        didSet {
//            guard selectedWallet != nil else {
//
//                if walletList.count > 0 {
//                    //if delete selected wallet，set the first wallet
//                    selectedWallet = walletList.first as AnyObject
//                } else {
//
//                }
//
//                return
//            }
//            for v in walletChangeHandlers {
//                v.value()
//            }
//        }
//    }
    var cWallet: Wallet? {
        guard let wallet = selectedWallet as? Wallet  else {
            return nil
        }
        return wallet
    }

    var selectedWalletName: String? {
        if cWallet != nil {
            return cWallet?.name
        }
        return ""
    }
    var selectedWalletAddress: String? {
        if cWallet != nil {
            return cWallet?.address
        }
        return ""
    }

    // MARK: - Notification

    @objc func didSwithNode() {
        self.reloadWallets()
        NotificationCenter.default.post(name: Notification.Name.ATON.updateWalletList, object: nil)
    }

    public func willDeleteWallet(object: AnyObject) {
        //issue mutiply thread access wallet object?
        if let wallet = object as? Wallet {
            if let selectedWallet = AssetVCSharedData.sharedData.selectedWallet as? Wallet {
                if selectedWallet.address.ishexStringEqual(other: wallet.address) {
//                    AssetVCSharedData.sharedData.selectedWallet = nil
                    AssetVCSharedData.sharedData.currentWalletAddress = nil;
                }
            }
        }

        self.reloadWallets()
        NotificationCenter.default.post(name: Notification.Name.ATON.updateWalletList, object: nil)
    }

    public func reloadWallets() {
        let newList = self.walletList
        currentWalletAddress = (newList as? [Wallet])?.first?.address
//        if newList.count > 0 {
//            self.selectedWallet = newList.first as AnyObject
//        } else {
//            self.selectedWallet = nil
//        }
    }

    func updateSelectedWallet() {
        guard
            let sw = selectedWallet as? Wallet,
            let wl = walletList as? [Wallet]
        else { return }
        let currentSw = wl.first(where: { $0.address.lowercased() == sw.address.lowercased() })
        currentWalletAddress = currentSw?.address
//        selectedWallet = currentSw
    }
}

extension AssetVCSharedData {
    // 通过地址查询本地的账号名称
    func getWalletName(for address: String) -> String? {
        let localWallet = (AssetVCSharedData.sharedData.walletList as! [Wallet]).filter { $0.address.lowercased() == address.lowercased() }.first
        return localWallet?.name
    }
}

extension AssetVCSharedData {

    func registerHandler(object: AnyObject?, handle: DidSwithWalletHandler?) {
        guard object != nil, handle != nil else {
            return
        }
        let address = String(format: "%d", (object?.hash)!)
        guard address.length > 0 else {
            return
        }
        walletChangeHandlers[address] = handle
    }

    func removeHandler(object: AnyObject?) {
        var tmp = object
        withUnsafePointer(to: &tmp) {
            let address = String(format: "%p", $0)
            guard address.length > 0 else {
                return
            }
            walletChangeHandlers.removeValue(forKey: address)
        }
    }
}
