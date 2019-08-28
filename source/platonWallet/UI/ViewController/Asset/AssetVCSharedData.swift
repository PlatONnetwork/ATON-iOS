//
//  AssetVCSharedData.swift
//  platonWallet
//
//  Created by Ned on 19/3/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation

typealias DidSwithWalletHandler = () ->Void


enum WalletSortType {
    case createTime,userArrangement
}

class AssetVCSharedData{
    
    static let sharedData = AssetVCSharedData()
    
    var walletChangeHandlers: Dictionary<String,DidSwithWalletHandler> = [:]
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(didSwithNode), name: NSNotification.Name(NodeStoreService.didSwitchNodeNotification), object: nil)
    }
     
    var walletList: [Any]{
        get{
            var tmp : [Any] = []
            tmp.append(contentsOf: WalletService.sharedInstance.wallets)
            
            var rangeWallets = tmp.filter { obj -> Bool in
                if let cwallet = obj as? Wallet{
                    return cwallet.userArrangementIndex != -1 
                }else if let jwallet = obj as? SWallet{
                    return jwallet.userArrangementIndex != -1
                }
                return false
            }
            rangeWallets.userArrangementSort()
            
            var unrangeWallets = tmp.filter { obj -> Bool in
                if let cwallet = obj as? Wallet{
                    return cwallet.userArrangementIndex == -1 
                }else if let jwallet = obj as? SWallet{
                    return jwallet.userArrangementIndex == -1
                }
                return false
            }
            unrangeWallets.walletCreateTimeSort()
            
            var newSorted : [Any] = []
            newSorted.append(contentsOf: rangeWallets)
            newSorted.append(contentsOf: unrangeWallets)
            
            return newSorted
        }
    }
    
    var selectedWallet : AnyObject?{
        didSet{
            guard selectedWallet != nil else{
                
                if walletList.count > 0{
                    //if delete selected wallet，set the first wallet
                    selectedWallet = walletList.first as AnyObject
                }else{
                    
                }
                
                return
            }
            for (_,v) in walletChangeHandlers.enumerated(){
                v.value()
            }
        }
    }
    var cWallet: Wallet?{
        guard let wallet = selectedWallet as? Wallet  else {
            return nil
        }
        return wallet
    }
    var jWallet: SWallet?{
        guard let wallet = selectedWallet as? SWallet  else {
            return nil
        }
        return wallet
    }
    
    var selectedWalletName: String?{
        if cWallet != nil{
            return cWallet?.name
        }
        if jWallet != nil{
            return jWallet?.name
        }
        return ""
    }
    var selectedWalletAddress: String?{
        if cWallet != nil{
            return cWallet?.key?.address
        }
        if jWallet != nil{
            return jWallet?.contractAddress
        }
        return ""
    }
    
    //MARK: - Notification
    
    @objc func didSwithNode(){
        self.reloadWallets()
        NotificationCenter.default.post(name: NSNotification.Name(updateWalletList_Notification), object: nil)
    }
    
    public func willDeleteWallet(object: AnyObject){
        //issue mutiply thread access wallet object?
        if let wallet = object as? Wallet{
            if let selectedWallet = AssetVCSharedData.sharedData.selectedWallet as? Wallet{
                if (selectedWallet.key?.address.ishexStringEqual(other: wallet.key?.address))!{
                    AssetVCSharedData.sharedData.selectedWallet = nil
                }
            }
        }else if let swallet = object as? SWallet{
            if let selectedWallet = AssetVCSharedData.sharedData.selectedWallet as? SWallet{
                if selectedWallet.contractAddress.ishexStringEqual(other: swallet.contractAddress){
                    AssetVCSharedData.sharedData.selectedWallet = nil
                }
            } 
        }
        
        self.reloadWallets()
        NotificationCenter.default.post(name: NSNotification.Name(updateWalletList_Notification), object: nil)
    }
    
    public func reloadWallets(){
        let newList = self.walletList
        if newList.count > 0{
            self.selectedWallet = newList.first as AnyObject
        }else{
            self.selectedWallet = nil
        }
    }
}

extension AssetVCSharedData {
    // 通过地址查询本地的账号名称
    func getWalletName(for address: String) -> String? {
        let localWallet = (AssetVCSharedData.sharedData.walletList as! [Wallet]).filter { $0.key?.address.lowercased() == address.lowercased() }.first
        return localWallet?.name
    }
}

extension AssetVCSharedData{
    
    func registerHandler(object: AnyObject?, handle: DidSwithWalletHandler?){
        guard object != nil,handle != nil else {
            return
        }
        let address = String(format: "%d", (object?.hash)!)
        guard address.length > 0 else{
            return
        }
        walletChangeHandlers[address] = handle
    }
    
    func removeHandler(object: AnyObject?){
        var tmp = object
        withUnsafePointer(to: &tmp) {
            let address = String(format: "%p", $0)
            guard address.length > 0 else{
                return
            }
            walletChangeHandlers.removeValue(forKey: address)
        }
    }
}
