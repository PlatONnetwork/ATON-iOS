//
//  SharedWalletMemberCell.swift
//  platonWallet
//
//  Created by matrixelement on 16/11/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit

class SharedWalletMemberCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateData(info : AddressInfo)  {
        nameLabel.text = info.walletName
        addressLabel.text = info.walletAddress
    }
    
}
