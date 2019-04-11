//
//  VoteConfirmView.swift
//  platonWallet
//
//  Created by juzix on 2019/1/9.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit

class VoteConfirmView: UIView {

    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var transactionType: UILabel!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var submitBtn: PButton!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var confirmButton: PButton!
    @IBOutlet weak var walletName: UILabel!
    @IBOutlet weak var walletAddressLabel: UILabel!
    
    override func awakeFromNib() {
        self.confirmButton.style = .blue
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
