//
//  WalletManagerTableViewCell.swift
//  platonWallet
//
//  Created by matrixelement on 2018/10/29.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit

class WalletManagerTableViewCell: UITableViewCell {

    @IBOutlet weak var container: UIView!
    
    @IBOutlet weak var walletIcon: UIImageView!
    
    @IBOutlet weak var walletName: UILabel!
    
    @IBOutlet weak var address: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        container.layer.cornerRadius = 4
        container.layer.masksToBounds = true
    }
    
    func feedData(_ wallet:AnyObject) {
        if let aptWallet = wallet as? Wallet{
            walletName.text = aptWallet.name
            address.text = aptWallet.key?.address
            walletIcon.image = UIImage(named: aptWallet.avatar)?.circleImage()
        }else if let swallet = wallet as? SWallet{
            walletName.text = swallet.name
            address.text = swallet.contractAddress
            let av = swallet.contractAddress.walletRandomAvatar()
            walletIcon.image = UIImage(named: av)?.circleImage()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
    }
    
}
