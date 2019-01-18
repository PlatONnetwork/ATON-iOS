//
//  Router.swift
//  platonWallet
//
//  Created by matrixelement on 29/11/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import BigInt

extension BaseViewController{
    func router(stransaction : STransaction, specifiedWallet: Wallet? = nil) -> BaseViewController {
        
        if stransaction.transanctionCategoryLazy == .JointWalletCreation ||
            stransaction.transanctionCategoryLazy == .JointWalletExecution ||
            stransaction.transanctionCategoryLazy == .JointWalletSubmit ||
            stransaction.transanctionCategoryLazy == .JointWalletApprove ||
            stransaction.transanctionCategoryLazy == .JointWalletRevoke{
            /*
            let vc = SharedWalletTransactionDetailVC()
            vc.sTransaction = stransaction;
            vc.swallet = SWalletService.sharedInstance.getSWalletByOwnerAddress(ownerAddress: stransaction.ownerWalletAddress)
            return vc
             */
            let vc = TransactionDetailViewController()
            vc.transaction = stransaction
            var wallet = WalletService.sharedInstance.getWalletByAddress(address: stransaction.ownerWalletAddress)
            if wallet == nil{
                //wallet dosen't exist
                wallet = Wallet()
            }
            vc.wallet = wallet
            return vc
        }
        
        var swallet = SWalletService.sharedInstance.getSWalletByContractAddress(contractAddress: stransaction.contractAddress)
        if swallet == nil{
            swallet = SWallet(tx: stransaction)
        }
        
       return self.navToTransactionReachTrustworthyStatus(tx: stransaction,specifiedWallet: specifiedWallet)
    
    }
    
    func navTo12Confirmation(stransaction : STransaction, swallet: SWallet) -> BaseViewController{
        if (stransaction.blockNumber?.length)! > 0{
            guard TransactionService.service.lastedBlockNumber != nil, (TransactionService.service.lastedBlockNumber?.length)! > 0 else{
                return self.navToSharedWalletTXDetailView(tx: stransaction, swallet: swallet)
            }
            
            let lastedBlockNumber = BigUInt(TransactionService.service.lastedBlockNumber!)
            let txBlockNumber = BigUInt((stransaction.blockNumber)!)
            let blockDiff = BigUInt.safeSubStractToUInt64(a: lastedBlockNumber!, b: txBlockNumber!)
            if Int64(blockDiff) < MinTransactionConfirmations{
                //block confriming
                return self.navToSharedWalletTXDetailView(tx: stransaction, swallet: swallet)
            }else{
                //success
                return self.navToTransactionReachTrustworthyStatus(tx: stransaction)
            }
        }else{
            //pending
            return self.navToSharedWalletTXDetailView(tx: stransaction, swallet: swallet)
        }
    }
    
    func navToTransactionReachTrustworthyStatus(tx : STransaction,specifiedWallet: Wallet? = nil) -> BaseViewController{
        
        var swallet = SWalletService.sharedInstance.getSWalletByContractAddress(contractAddress: tx.contractAddress)
        
        if swallet == nil{
            swallet = SWallet(tx: tx)
        }
        
        if ((tx.executed)) {
            //success transfer
            return self.navToSharedWalletTXDetailView(tx: tx, swallet: swallet!)
        }else if (!(tx.executed)){
            
            if tx.signStatus == .reachRevoke{
                return self.navToSharedWalletTXDetailView(tx: tx, swallet: swallet!)
            }else if tx.signStatus == .reachApproval{
                return self.navToSharedWalletTXDetailView(tx: tx, swallet: swallet!)
            }else if tx.signStatus == .voting{
                return self.navToConfirmView(tx: tx, swallet: swallet!,specifiedWallet: specifiedWallet)
            }
        }
        return BaseViewController()
    }
    
    func navToConfirmView(tx: STransaction, swallet: SWallet, specifiedWallet: Wallet? = nil) -> BaseViewController{
        let vc = ShareWalletConfirmVC()
        vc.sTransaction = tx;
        vc.swallet = swallet
        if specifiedWallet != nil{
            vc.specifiedWallet = specifiedWallet
        }
        return vc
    }
    
    func navToSharedWalletTXDetailView(tx: STransaction, swallet: SWallet) -> BaseViewController{
        let vc = SharedWalletTransactionDetailVC()
        vc.sTransaction = tx;
        vc.swallet = swallet
        return vc
    }
    

    
    
}
