//
//  WalletSelectionTableViewCell.swift
//  platonWallet
//
//  Created by matrixelement on 2018/11/6.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit

class WalletSelectionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var walletIconImgV: UIImageView!
    
    @IBOutlet weak var walletNameLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var selectionImgV: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func feedData(_ wallet:Wallet, isSelected: Bool) {
        
        walletIconImgV.image = UIImage(named: wallet.avatar)?.circleImage()
        walletNameLabel.text = wallet.name
        //addressLabel.text = wallet.key?.address
        addressLabel.text = wallet.balanceDescription()
        selectionImgV.isHidden = !isSelected
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
