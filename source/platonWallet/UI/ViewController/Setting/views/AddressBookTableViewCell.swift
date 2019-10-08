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
    }
 
    func setUpdCell(addressInfo : AddressInfo, isForSelectMode: Bool)  {
        walletName.text = addressInfo.walletName
        walletAddress.text = addressInfo.walletAddress?.addressForDisplay()
        icon.image = UIImage(named: addressInfo.walletAddress?.walletAddressLastCharacterAvatar() ?? "walletAvatar_1")
        if isForSelectMode && (AssetVCSharedData.sharedData.selectedWallet as! Wallet).address.lowercased() == addressInfo.walletAddress?.lowercased() {
            containerView.backgroundColor = UIColor(rgb: 0xdcdfe8, alpha: 0.4)
        } else {
            containerView.backgroundColor = UIViewController_backround
        }
    }
    
}
