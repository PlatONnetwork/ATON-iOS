//
//  AddressBookTableViewCell.swift
//  platonWallet
//
//  Created by matrixelement on 29/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import SwipeCellKit

class AddressBookTableViewCell: SwipeTableViewCell {

    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var walletAddress: UILabel!
    @IBOutlet weak var walletName: UILabel!
    
    @IBOutlet weak var icon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = 3.0
    }
 
    func setUpdCell(addressInfo : AddressInfo)  {
        walletName.text = addressInfo.walletName
        walletAddress.text = addressInfo.walletAddress
        icon.image = UIImage(named: addressInfo.walletAddress?.walletRandomAvatar() ?? "walletAvatar_1")
    }
    
}
