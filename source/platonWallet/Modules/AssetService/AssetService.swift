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
    
    var assets = [String:WalletBalance?]()
    
    let queue = DispatchQueue(label: "platon.asset.queue")
    
    var timer : Timer?
    
    var querying : Bool = false
    
    func getBalances(addresses : [WalletBalance],completion : @escaping AssetQueryCompletion) {
        let queue = DispatchQueue(label: "getBalances")
        let semaphore = DispatchSemaphore(value: 0)
        var balances : [WalletBalance] = []
        
        queue.async {
            for balanceObj in addresses {
                
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
        if assetQueryTimerEnable {
            timer = Timer.scheduledTimer(timeInterval: TimeInterval(assetQueryTimerInterval), target: self, selector: #selector(timerFirer), userInfo: nil, repeats: true)
            timer?.fire()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(OnDidSwitchNode), name: NSNotification.Name(didswitchNode_Notification), object: nil)
    }
    
    func getBalance(address : String,completion : @escaping (_ result : PlatonCommonResult, _ balance : WalletBalance?) -> ()) {
        var ea : EthereumAddress?
        do {
            ea = try EthereumAddress(hex: address, eip55: false)
        } catch {
            
        }
        DispatchQueue.main.async {
            web3.eth.getBalance(address: ea!, block: .latest) { resp in
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
    
    
    // MARK: - Timer
    
    @objc func timerFirer(){
        if querying {
            return
        }
        querying = true
        let wallets = WalletService.sharedInstance.wallets
        let swallets = SWalletService.sharedInstance.wallets
        
        var addresses : [WalletBalance] = []
        
        for wallet in wallets{
            let balance = WalletBalance()
            balance.address = wallet.key?.address
            balance.walletType = WalletType.ClassicWallet
            addresses.append(balance)
        }
        
        for swallet in swallets{
            let balance = WalletBalance()
            balance.address = swallet.contractAddress
            balance.walletType = WalletType.JointWallet
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
