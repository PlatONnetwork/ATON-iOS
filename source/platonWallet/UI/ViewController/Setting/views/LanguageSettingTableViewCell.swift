//
//  LanguageSettingTableViewCell.swift
//  platonWallet
//
//  Created by matrixelement on 5/11/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit

class LanguageSettingTableViewCell: UITableViewCell {

    @IBOutlet weak var detailLabel: UILabel!
    
    @IBOutlet weak var selectedIcon: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
