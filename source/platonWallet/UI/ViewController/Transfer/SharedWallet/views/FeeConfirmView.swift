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

class FeeConfirmView: UIView {

    @IBOutlet weak var feeLabel: UILabel!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var titleDescription: UILabel!
    
    @IBOutlet weak var paymentInfo: UILabel!
    
    
    
    
    func setViewType(_ type: FeeConfirmViewType){
        if type == .ExecuteContract{
            titleDescription.localizedText = "SharedWalletTransactionDetailVC_execute_contract"
            paymentInfo.localizedText = "SharedWalletTransactionDetailVC_payment_execute_contract"
            submitButton.localizedNormalTitle = "SharedWalletTransactionDetailVC_payment_confirm"
        }
    }
}
