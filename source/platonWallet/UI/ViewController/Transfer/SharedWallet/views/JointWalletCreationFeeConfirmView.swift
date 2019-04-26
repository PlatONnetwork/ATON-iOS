//
//  FeeConfirmView.swift
//  platonWallet
//
//  Created by matrixelement on 3/12/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit

enum FeeConfirmViewType {
    case CreateContract
    case ExecuteContract
}

class JointWalletCreationFeeConfirmView: UIView {

    @IBOutlet weak var feeLabel: UILabel!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var submitButton: PButton!
    
    @IBOutlet weak var titleDescription: UILabel!
    
    @IBOutlet weak var paymentInfo: UILabel!
    
    @IBOutlet weak var executorName: UILabel!

    @IBOutlet weak var payInfoDes: UILabel!
    
    override func awakeFromNib() {
        self.submitButton.style = .blue
    }
    
    func setViewType(_ type: FeeConfirmViewType){
        if type == .ExecuteContract{
            titleDescription.localizedText = "SharedWalletTransactionDetailVC_execute_contract"
            paymentInfo.localizedText = "SharedWalletTransactionDetailVC_payment_execute_contract"
            payInfoDes.localizedText = "SharedWalletTransactionDetailVC_execute_PayType"
            submitButton.localizedNormalTitle = "SharedWalletTransactionDetailVC_payment_confirm"
        }
    }
}
