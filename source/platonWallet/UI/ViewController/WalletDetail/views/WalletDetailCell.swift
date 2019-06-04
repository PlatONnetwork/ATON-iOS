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
    
    func updateTransferCell(transaction: Transaction?, wallet: Wallet?) {
        guard let tx = transaction else { return }
        updateCellWithAPTTransfer(tx: tx, wallet: wallet)
    }
    
    func updateCellStyle(count: Int, index: Int){

    }

    func updateCellWithAPTTransfer(tx: Transaction, wallet: Wallet?) {
        guard let w = wallet else { return }
        self.unreadTag.isHidden = true
        tx.senderAddress = w.key?.address
        
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
        
        if tx.txType == .unknown || tx.txType == .transfer {
            txTypeLabel.text = tx.transactionStauts.localizeTitle
        } else {
            txTypeLabel.text = tx.txType?.localizeTitle
        }

        let (des,color) = tx.transactionStauts.localizeDescAndColor
        statusLabel.text = des
        statusLabel.textColor = color
        
        guard (tx.confirmTimes != 0) else{
            guard tx.createTime != 0 else {
                timeLabel.text = "--:--:-- --:--"
                return
            }
            timeLabel.text = Date.toStanderTimeDescrition(millionSecondsTimeStamp: tx.createTime)
            return
        }
        
        timeLabel.text = Date.toStanderTimeDescrition(millionSecondsTimeStamp: tx.confirmTimes)
        
    }
    
}
