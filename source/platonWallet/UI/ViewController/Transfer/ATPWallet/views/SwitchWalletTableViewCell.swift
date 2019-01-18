//
//  SwitchWalletTableViewCell.swift
//  platonWallet
//
//  Created by matrixelement on 29/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit

let SwitchWalletCellDisableBG = UIColor(rgb: 0xf0f0f0)
let SwitchWalletCellEnableBG = UIColor(rgb: 0xF8F8F8)

class SwitchWalletTableViewCell: UITableViewCell {

    @IBOutlet weak var walletBalance: UILabel!
    @IBOutlet weak var walletName: UILabel!
    
    @IBOutlet weak var checkIcon: UIImageView!
    
    @IBOutlet weak var walletIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateBalanceStyle(balance: WalletBalance?){
        if balance == nil || balance?.balance == nil || String((balance?.balance)!) == "0"{
            self.contentView.backgroundColor = SwitchWalletCellDisableBG
        }else{
            self.contentView.backgroundColor = SwitchWalletCellEnableBG
        }
    }
    
}
