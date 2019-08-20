//
//  KeyStore.swift
//  platonWallet
//
//  Created by matrixelement on 17/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import platonWeb3

typealias AssetQueryCompletion = (_ result : PlatonCommonResult?, _ balances : [WalletBalance] ) -> ()

class AssetService : BaseService{
    
    public static let sharedInstace = AssetService()
    
    var balances: [Balance] = []
    
    var assets = [String:WalletBalance?]()
    
    let queue = DispatchQueue(label: "platon.asset.queue")
    
    var querying : Bool = false
    
    func getBalances(addresses : [WalletBalance],completion : @escaping AssetQueryCompletion) {
        let queue = DispatchQueue(label: "getBalances")
        let semaphore = DispatchSemaphore(value: 0)
        var balances : [WalletBalance] = []
        
        queue.async {
            for balanceObj in addresses {
                guard balanceObj != nil, balanceObj.address != nil else{
                    continue
                }
                self.getBalance(address: balanceObj.address!) { result,balance in
                    
                    switch result{
                        
                    case .success:
                        balance?.walletType = balanceObj.walletType
                        balances.append(balance!)
                        semaphore.signal()
                    case .fail(_, _):
                        DispatchQueue.main.async {
                            completion(PlatonCommonResult.fail(-3200,""),balances)
                        }
                        semaphore.signal()
                    }
                }
                
                if  semaphore.wait(timeout: .now() + 10) == .success{
                    continue
                }else{
                    break
                }
            }
            
            DispatchQueue.main.async {
                completion(.success,balances)
            }
        }

    }
    
    // MARK: - Initialization
    
    public override init(){
        super.init()
        fetchWalletBanlance()
        
        NotificationCenter.default.addObserver(self, selector: #selector(OnDidSwitchNode), name: NSNotification.Name(NodeStoreService.didSwitchNodeNotification), object: nil)
    }
    
    func getBalance(address : String,completion : @escaping (_ result : PlatonCommonResult, _ balance : WalletBalance?) -> ()) {
        var ea : EthereumAddress?
        do {
            ea = try EthereumAddress(hex: address, eip55: false)
        } catch {
            
        }
        DispatchQueue.main.async { 
            web3.platon.getBalance(address: ea!, block: .latest) { resp in
                DispatchQueue.main.async {
                    switch resp.status{
                    case .success(_):
                        let wbalance = WalletBalance()
                        wbalance.address = address
                        wbalance.balance = resp.result!.quantity
                        self.assets[address] = wbalance
                        completion(PlatonCommonResult.success,wbalance)
                    case .failure(_):
                        completion(PlatonCommonResult.fail(-1, resp.getErrorLocalizedDescription()),nil)
                        return
                        
                    }
                }
            }
        }
    }
    
    func fetchWalletBalanceForV7(_ completion: PlatonCommonCompletion?) {
        let completion = completion
        let addresses = (AssetVCSharedData.sharedData.walletList as! [Wallet]).map { return $0.key!.address }
        guard addresses.count > 0 else { return }
        
        getWalletBalances(addrs: addresses) { [weak self] (result, data) in
            switch result {
            case .success:
                if let newData = data as? [Balance] {
                    self?.balances = newData
                    completion?(PlatonCommonResult.success, newData as AnyObject)
                } else {
                    completion?(PlatonCommonResult.success, nil)
                }
            case .fail(_, _):
                completion?(PlatonCommonResult.fail(nil, nil), nil)
            }
        }
    }
    
    
    // MARK: - Timer
    
    @objc func fetchWalletBanlance(){
        if querying {
            return
        }
        querying = true
        let wallets = WalletService.sharedInstance.wallets
        var addresses : [WalletBalance] = []
        
        for wallet in wallets{
            let balance = WalletBalance()
            balance.address = wallet.key?.address
            balance.walletType = WalletType.ClassicWallet
            addresses.append(balance)
        }
        
        getBalances(addresses: addresses) { (result, banlance) in
            switch result{
            case .success?:
                do {
                    NotificationCenter.default.post(name: Notification.Name(DidUpdateAllAssetNotification), object: nil)
                    self.querying = false
                }
                
            case .fail( _, _)?:
                do{
                    self.querying = false
                }
                
            case .none:
                do{
                    self.querying = false
                }
                
            }
        }
    }
    
    //MARK: - Notification
    @objc func OnDidSwitchNode(){
        assets.removeAll()
    }
    
    
}
