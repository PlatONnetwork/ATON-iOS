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
        typeLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
    }

    func updateCell(tx : Transaction) {
        if tx.txType == .unknown || tx.txType == .transfer {
            if tx.direction == .unknown {
                typeLabel.text = tx.txType?.localizeTitle
            } else {
                typeLabel.text = tx.direction.localizedDesciption
            }
        } else {
            typeLabel.text = tx.txType?.localizeTitle
        }
        typeLabel.textColor = (tx.txReceiptStatus == TransactionReceiptStatus.businessCodeError.rawValue) ? UIColor(white: 0.0, alpha: 0.5) : .black

        timeLabel.text = Date.toStanderTimeDescrition(millionSecondsTimeStamp: tx.confirmTimes)

        amoutLabel.text = tx.amountTextString
        amoutLabel.textColor = tx.amountTextColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
