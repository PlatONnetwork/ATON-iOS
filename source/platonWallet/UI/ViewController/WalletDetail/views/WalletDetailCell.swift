//
//  WalletDetailCell.swift
//  platonWallet
//
//  Created by matrixelement on 23/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import BigInt
import Localize_Swift

class WalletDetailCell: UITableViewCell {
    
    @IBOutlet weak var txTypeLabel: UILabel!
    
    @IBOutlet weak var transferAmoutLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var txIcon: UIImageView!
    
    
    @IBOutlet weak var unreadTag: UILabel!
    
    
    @IBOutlet weak var sepline: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        unreadTag.layer.masksToBounds = true
        unreadTag.layer.cornerRadius = 3
        unreadTag.isHidden = true
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateTransferCell(txAny : AnyObject?, walletAny : AnyObject?) {
        
        if let tx = txAny as? Transaction{
            updateCellWithAPTTransfer(tx: tx, anyWallet: walletAny)
        }else if let stx = txAny as? STransaction{
            updateCellWithSharedWalletTransfer(tx: stx, walletAny: walletAny)
        }
    }
    
    func updateCellStyle(count: Int, index: Int){

    }

    func updateCellWithAPTTransfer(tx : Transaction, anyWallet : AnyObject?) {
      
        if let w = anyWallet as? Wallet {
            self.unreadTag.isHidden = true
            tx.senderAddress = w.key?.address
            //classic wallet' transaction
//            if (tx.from?.ishexStringEqual(other: w.key?.address))! {
//                transferAmoutLabel.text = "-" + (tx.valueDescription)!.ATPSuffix()
//                txIcon.image = UIImage(named: "walletSendIcon")
//                
////                txTypeLabel.text = Localized("walletDetailVC_tx_type_send")
////                txTypeLabel.text = tx.transactionStauts.localizeTitle
//            }else {
//                transferAmoutLabel.text = "+" + (tx.valueDescription)!.ATPSuffix()
//                txIcon.image = UIImage(named: "walletRecvIcon")
//                
////                txTypeLabel.text = tx.transactionStauts.localizeTitle
////                if tx.blockNumber != nil && (tx.blockNumber?.length)! > 0{
////                    txTypeLabel.localizedText = "walletDetailVC_tx_type_receive"
////                }else{
////                    txTypeLabel.localizedText = "TransactionListVC_Receiving"
////                }
////                txTypeLabel.localizedText = "walletDetailVC_tx_type_receive"
//            }
        }else if let ws = anyWallet as? SWallet {
            //joint wallet' transaction
            tx.senderAddress = ws.contractAddress
//            if (tx.from?.ishexStringEqual(other: ws.contractAddress))! {
//                transferAmoutLabel.text = "-" + (tx.valueDescription)!.ATPSuffix()
//                txIcon.image = UIImage(named: "walletSendIcon")
//                txTypeLabel.text = Localized("walletDetailVC_tx_type_send")
//                
//            }else{
//                transferAmoutLabel.text = "+" + (tx.valueDescription)!.ATPSuffix()
//                txIcon.image = UIImage(named: "walletRecvIcon")
//                
////                if tx.blockNumber != nil && (tx.blockNumber?.length)! > 0{
////                    txTypeLabel.localizedText = "walletDetailVC_tx_type_receive"
////                }else{
////                    txTypeLabel.localizedText = "TransactionListVC_Receiving"
////                }
//
//            }
        }
        
        switch tx.transactionStauts {
        case .sending,.sendSucceed,.sendFailed:
            transferAmoutLabel.text = "-" + (tx.valueDescription)!.ATPSuffix()
            txIcon.image = UIImage(named: "txSendSign")
        case .receiving,.receiveSucceed,.receiveFailed:
            transferAmoutLabel.text = "+" + (tx.valueDescription)!.ATPSuffix()
            txIcon.image = UIImage(named: "txRecvSign")
        case .voting,.voteSucceed,.voteFailed:
            transferAmoutLabel.text = "-" + (tx.valueDescription)!.ATPSuffix()
            txIcon.image = UIImage(named: "walletVote")
 
        }

        txTypeLabel.text = tx.transactionStauts.localizeTitle
        let (des,color) = tx.transactionStauts.localizeDescAndColor
        statusLabel.text = des
        statusLabel.textColor = color
        
        guard (tx.createTime != 0) else{
            timeLabel.text = "--:--:-- --:--"
            return
        }
        timeLabel.text = Date.toStanderTimeDescrition(millionSecondsTimeStamp: tx.createTime)
    }
    
    func updateCellWithSharedWalletTransfer(tx : STransaction,walletAny : AnyObject?) {
        
        if tx.readTag == 1{
            unreadTag.isHidden = false
        }else{
            unreadTag.isHidden = true
        }
        
        var fixedFrom = tx.to
        if !(fixedFrom?.hasPrefix("0x"))!{
            fixedFrom = "0x" + fixedFrom!
        }
        
        if tx.transanctionCategoryLazy == .ATPTransfer{
            if let sw = walletAny as? SWallet{
                //joint wallet detail‘s transactions
                if (tx.from?.ishexStringEqual(other: sw.contractAddress))!{
                    transferAmoutLabel.text = "-" + (tx.valueDescription)!.ATPSuffix()
                    txTypeLabel.text = tx.typeLocalization
                    txIcon.image = UIImage(named: "txSendSign")
                }else{
                    transferAmoutLabel.text = "+" + (tx.valueDescription)!.ATPSuffix()
                    if tx.executed{
                        txTypeLabel.text = Localized("TransactionListVC_Received")
                    }else{
                        txTypeLabel.text = Localized("TransactionListVC_Receiving")
                    }
                    txIcon.image = UIImage(named: "txRecvSign")
                }
                
            }else if let w = walletAny as? Wallet{
                //classic wallet detail's transactions
                
                var owerSendout = false
                for item in tx.determinedResult{
                    if (item.walletAddress?.ishexStringEqual(other: w.key?.address))!{
                        owerSendout = true
                    }
                }
               
                var isRecv = false
                if (tx.to?.ishexStringEqual(other: w.key?.address))!{
                    isRecv = true
                }
                if ((tx.ownerWalletAddress.ishexStringEqual(other: w.key?.address)) || owerSendout) && !isRecv{
                    transferAmoutLabel.text = "-" + (tx.valueDescription)!.ATPSuffix()
                    txTypeLabel.text = Localized("walletDetailVC_tx_type_send")
                    txIcon.image = UIImage(named: "txSendSign")
                }else{
                    transferAmoutLabel.text = "+" + (tx.valueDescription)!.ATPSuffix()
                    if tx.executed{
                        txTypeLabel.text = Localized("TransactionListVC_Received")
                    }else{
                        txTypeLabel.text = Localized("TransactionListVC_Receiving")
                    }
                    txIcon.image = UIImage(named: "txRecvSign")
                }
            }

        }else{
            txTypeLabel.text = tx.typeLocalization
            transferAmoutLabel.text = (tx.valueDescription)!.ATPSuffix()
        }
        
        
        switch tx.transanctionCategoryLazy {
        case .ATPTransfer?:
            do{}
        case .some(.JointWalletCreation):
            txIcon.image = UIImage(named: "JointWalletCreateIcon")
        case .some(.JointWalletExecution):
            txIcon.image = UIImage(named: "JointWalletExe")
        case .some(.JointWalletSubmit):
            txIcon.image = UIImage(named: "JointWalletExe")
        case .some(.JointWalletApprove):
            txIcon.image = UIImage(named: "JointWalletExe")
        case .some(.JointWalletRevoke):
            txIcon.image = UIImage(named: "JointWalletExe")
        case .none:
            txIcon.image = UIImage(named: "")
        }
        
        let (des,color) = tx.labelDesciptionAndColor()
        statusLabel.text = des
        statusLabel.textColor = color
        
        guard (tx.createTime > 0) else{
            timeLabel.text = "--:--:-- --:--"
            return
        }
        timeLabel.text = Date.toStanderTimeDescrition(millionSecondsTimeStamp: Int(tx.createTime))
    }
    
}
