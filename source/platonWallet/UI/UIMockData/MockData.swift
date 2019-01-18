//
//  MockData.swift
//  platonWallet
//
//  Created by matrixelement on 21/11/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import Localize_Swift

class MockData{
    
    
    static func swallets(wallet : Wallet) -> [SWallet]{
        var array : [SWallet] = []
        
        let s1 = SWallet()
        s1.contractAddress = "0xc1930aee22de83e8957ab9720c2000000000000" + String(3)
        s1.name = "needrequireNumberof_" + String(2)
        s1.walletAddress = (wallet.key?.address)!
        
        let ownerNumber = 3
        for i in 0...ownerNumber{
            let addr = AddressInfo()
            addr.walletAddress = "0xc1930aee22de83e8957ab9720c2111111111111" + String(i)
            addr.walletName = Localized("sharedWalletDefaltMemberName") + String(i)
            if i == 0{
                addr.walletAddress = wallet.key?.address
            }
            s1.owners.append(addr)
        }
        s1.required = 2
        
        array.append(s1)
        
        
        let s2 = SWallet()
        s2.contractAddress = "0xc1930aee22de83e8957ab9720c2000000000000" + String(5)
        s2.name = "needrequireNumberof_" + String(3)
        s2.walletAddress = (wallet.key?.address)!
        
        let ownerNumber5 = 5
        for i in 0...ownerNumber5{
            let addr = AddressInfo()
            addr.walletAddress = "0xc1930aee22de83e8957ab9720c2111111111111" + String(i)
            addr.walletName = Localized("sharedWalletDefaltMemberName") + String(i)
            
            if i == 0{
                addr.walletAddress = wallet.key?.address
            }
            
            s2.owners.append(addr)
        
        }
        s2.required = 3
        
        array.append(s2)
        
        
        
        return array
    }
    
    static func getSTransactions(swallet : SWallet) -> [STransaction]{
        
        var array : [STransaction] = []
        
        for i in 0...10{
            
            let tx = STransaction()
            tx.transactionID = String(i)
            tx.contractAddress = swallet.contractAddress
            
            for item in swallet.owners{
                let detResult = DeterminedResult()
                detResult.walletAddress = item.walletAddress
                detResult.operation = 0
                tx.determinedResult.append(detResult)
            }
            
            tx.from = "123from"
            tx.to = "123to"
            tx.value = "123000000000"
            tx.fee = "520000000"
            tx.pending = false
            tx.txhash = "0xhash" + String(i)
            
            if swallet.owners.count == 4{
                if i == 0 {
                    tx.blockNumber = "2000"
                    tx.executed = false
                    var index = 0
                    for item in tx.determinedResult{
                        if item.walletAddress == swallet.walletAddress
                        {
                            item.operation = 1
                        }else{
                            item.operation = 0
                        }
                    
                        index = index + 1
                    }
                }
                
                if i == 1 {
                    tx.blockNumber = "2000"
                    tx.executed = false
                    var index = 0
                    for item in tx.determinedResult{
                        if item.walletAddress == swallet.walletAddress
                        {
                            item.operation = 0
                        }else{
                            item.operation = 1
                        }
                        
                        index = index + 1
                    }
                }
                
                
                if i == 2 {
                    tx.blockNumber = "200"
                    tx.executed = true
                    var index = 0
                    for item in tx.determinedResult{
                        if item.walletAddress == swallet.walletAddress
                        {
                            item.operation = 0
                        }else if index < 3{
                            item.operation = 1
                        }else{
                            item.operation = 2
                        }
                        
                        index = index + 1
                    }
                }
            }
         
            array.append(tx)
        }
        
        return array
    }
    
}
