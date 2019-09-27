//
//  SettingTableViewCell.swift
//  platonWallet
//
//  Created by matrixelement on 29/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class SettingTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var desLabel: UILabel!
    
    @IBOutlet weak var detailIcon: UIImageView!
    @IBOutlet weak var sepline: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCellWithIndexPath(indexPath : IndexPath){
        sepline.alpha = 1
        switch indexPath.row {
        case 0:
            do {

                iconImage.image = UIImage(named: "iconWalletMgr")
                desLabel.localizedText = "PersonalVC_cell_wallet_manager"
            }
        case 1:
            do {
                iconImage.image = UIImage(named: "iconTxHis")
                desLabel.localizedText = "PersonalVC_cell_wallet_Transactions"
            }
        case 2:
            do {
                iconImage.image = UIImage(named: "iconAddrBook")
                desLabel.localizedText = "PersonalVC_cell_wallet_address_book"
            }
        case 3:
            do {
                iconImage.image = UIImage(named: "iconSetting")
                desLabel.localizedText = "PersonalVC_cell_wallet_setting"
            }
            /*
        case 4:
            do {
                iconImage.image = UIImage(named: "iconHelp")
                desLabel.localizedText = "PersonalVC_cell_wallet_help"
            }
             */
        case 4:
            do {
                iconImage.image = UIImage(named: "4.icon-Support and feedback")
                desLabel.localizedText = "PersonalVC_cell_wallet_feedback"
            }
        case 5:
            do {
                iconImage.image = UIImage(named: "iconCom")
                desLabel.localizedText = "PersonalVC_cell_wallet_community"
            }
        case 6:
            do {
                iconImage.image = UIImage(named: "iconAbout")
                desLabel.localizedText = "PersonalVC_cell_wallet_About"
            }
        default: break
            
        }
    }
    
}
