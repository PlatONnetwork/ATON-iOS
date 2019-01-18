//
//  AddAddressInfoView.swift
//  platonWallet
//
//  Created by matrixelement on 29/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit

class AddAddressInfoView: UIView {

    @IBOutlet weak var nameTextField: PTextFieldWithPadding!
    
    @IBOutlet weak var addressField: PTextFieldWithPadding!
    
    @IBOutlet weak var confirmButton: UIButton!
    
    @IBOutlet weak var walletNameTip: UILabel!
    
    @IBOutlet weak var addressTip: UILabel!
    
    @IBOutlet weak var walletNameTipHeight: NSLayoutConstraint!
    
    @IBOutlet weak var addressTipHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {

        walletNameTipHeight.constant = 0
        addressTipHeight.constant = 0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if nameTextField.isFirstResponder{
            nameTextField.resignFirstResponder()
        }
        
        if addressField.isFirstResponder {
            addressField.resignFirstResponder()
        }
    }
    
    func showWalletNameTipWithString(desciption : String) {
        walletNameTip.text = desciption
        UIView.animate(withDuration: 0.25) {
            self.walletNameTipHeight.constant = 16;
            self.layoutIfNeeded()
        }
    }
    
    func hideWalletNameTip() {
        UIView.animate(withDuration: 0.25) {
            self.walletNameTipHeight.constant = 0;
            self.layoutIfNeeded()
        }
    }
    
    func showAddressTipWithString(desciption : String) {
        addressTip.text = desciption
        UIView.animate(withDuration: 0.25) {
            self.addressTipHeight.constant = 16;
            self.layoutIfNeeded()
        }
    }
    
    func hideAddressTip() {
        UIView.animate(withDuration: 0.25) {
            self.addressTipHeight.constant = 0;
            self.layoutIfNeeded()
        }
    }

}
