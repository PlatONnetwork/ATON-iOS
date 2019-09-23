//
//  KeyStore.swift
//  platonWallet
//
//  Created by matrixelement on 17/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import platonWeb3

class AssetService : BaseService{
    
    public static let sharedInstace = AssetService()
    
    var balances: [Balance] = []
    
    let queue = DispatchQueue(label: "platon.asset.queue")
    
    var querying : Bool = false
    
    // MARK: - Initialization
    
    public override init(){
        super.init()
        fetchWalletBalanceForV7(nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(OnDidSwitchNode), name: NSNotification.Name(NodeStoreService.didSwitchNodeNotification), object: nil)
    }
    
    func fetchWalletBalanceForV7(_ completion: PlatonCommonCompletion?) {
        let completion = completion
        let addresses = (AssetVCSharedData.sharedData.walletList as! [Wallet]).map { return $0.key!.address }
        guard addresses.count > 0 else {
            NotificationCenter.default.post(name: Notification.Name.ATON.DidUpdateAllAsset, object: nil)
            return
        }
        
        getWalletBalances(addrs: addresses) { [weak self] (result, data) in
            switch result {
            case .success:
                if let newData = data as? [Balance] {
                    
                    for bal in newData {
                        let oriBalance = self?.balances.first(where: { $0.addr.lowercased() == bal.addr.lowercased() })
                        if oriBalance == nil {
                            continue
                        }
                        
                        if oriBalance?.free != bal.free || oriBalance?.lock != bal.lock {
                            NotificationCenter.default.post(name: Notification.Name.ATON.UpdateTransactionList, object: nil)
                            break
                        }
                    }
                    
                    self?.balances = newData
                    NotificationCenter.default.post(name: Notification.Name.ATON.DidUpdateAllAsset, object: nil)
                    completion?(PlatonCommonResult.success, newData as AnyObject)
                } else {
                    completion?(PlatonCommonResult.success, nil)
                }
            case .fail(_, _):
                completion?(PlatonCommonResult.fail(nil, nil), nil)
            }
        }
    }
    
    //MARK: - Notification
    @objc func OnDidSwitchNode(){
//        assets.removeAll()
    }
}


