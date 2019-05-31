//
//  TransactionCell.swift
//  platonWallet
//
//  Created by matrixelement on 1/11/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class TransactionCell: UITableViewCell {
    
    @IBOutlet weak var typeLabel: UILabel!
    
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var amoutLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    
    func updateCell(tx : Transaction){
        updateTransactionStatus(tx: tx)
        amoutLabel.text = "-" + (tx.valueDescription)!.ATPSuffix()
        timeLabel.text = Date.toStanderTimeDescrition(millionSecondsTimeStamp: tx.confirmTimes)
    }
 
    
    func updateTransactionStatus(tx : Transaction) {

        tx.senderAddress = tx.from
        
        typeLabel.text = tx.txType == .transfer ? tx.transactionStauts.localizeTitle : tx.txType?.localizeTitle
        statusLabel.text = tx.transactionStauts.localizeDescAndColor.0
        statusLabel.textColor = tx.transactionStauts.localizeDescAndColor.1
        
    }
    
    func updateSTransactionStatus(tx : STransaction) {
        let detachTx = tx.detached()
        detachTx.labelDesciptionAndColor { (des, color) in
            self.statusLabel.text = des
            self.statusLabel.textColor = color
        }
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

    
}
