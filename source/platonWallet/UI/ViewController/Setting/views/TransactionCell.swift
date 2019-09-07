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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = normal_background_color
        backgroundColor = normal_background_color
        selectionStyle = .none
    }

    
    func updateCell(tx : Transaction){
        if tx.txType == .unknown || tx.txType == .transfer {
            if tx.direction == .unknown {
                typeLabel.text = tx.txType?.localizeTitle
            } else {
                typeLabel.text = tx.direction.localizedDesciption
            }
        } else {
            typeLabel.text = tx.txType?.localizeTitle
        }
        timeLabel.text = Date.toStanderTimeDescrition(millionSecondsTimeStamp: tx.confirmTimes)
        
        switch tx.direction {
        case .Sent:
            amoutLabel.text = "-" + (tx.valueDescription)!.ATPSuffix()
            amoutLabel.textColor = UIColor(rgb: 0xff3b3b)
        case .Receive:
            amoutLabel.text = "+" + (tx.valueDescription)!.ATPSuffix()
            amoutLabel.textColor = UIColor(rgb: 0x19a20e)
        default:
            amoutLabel.text = "-" + (tx.valueDescription)!.ATPSuffix()
            amoutLabel.textColor = UIColor(rgb: 0xff3b3b)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

    
}
