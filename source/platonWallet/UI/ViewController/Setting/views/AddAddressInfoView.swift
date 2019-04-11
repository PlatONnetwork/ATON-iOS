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
    
    @IBOutlet weak var scanButton: UIButton!
    
    @IBOutlet weak var walletNameTip: UILabel!
    
    @IBOutlet weak var addressTip: UILabel!
    
  
    @IBOutlet weak var addressDesToNameTextFieldBottom: NSLayoutConstraint!
    
    @IBOutlet weak var addressDesToNameTipBottom: NSLayoutConstraint!
    
    
    @IBOutlet weak var addressTipHeight: NSLayoutConstraint!
    
    @IBOutlet weak var addButton: PButton!
    
    override func awakeFromNib() {

        addressTipHeight.constant = 0
        walletNameTip.text = ""
    
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
        walletNameTip.isHidden = false
        UIView.animate(withDuration: 0.25) {
            self.addressDesToNameTipBottom.priority = UILayoutPriority(rawValue: 999)
            self.addressDesToNameTextFieldBottom.priority = UILayoutPriority(rawValue: 998)
            self.layoutIfNeeded()
        }
    }
    
    func hideWalletNameTip() {
        walletNameTip.isHidden = true
        UIView.animate(withDuration: 0.25) {
            self.addressDesToNameTextFieldBottom.priority = UILayoutPriority(rawValue: 999)
            self.addressDesToNameTipBottom.priority = UILayoutPriority(rawValue: 998)
            
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
