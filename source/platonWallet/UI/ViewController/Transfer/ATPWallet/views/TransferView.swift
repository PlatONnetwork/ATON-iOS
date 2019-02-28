//
//  TransferView.swift
//  platonWallet
//
//  Created by matrixelement on 18/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift
import UITextView_Placeholder

class TransferView: UIView{

    @IBOutlet weak var toAddressTip: UILabel!
    
    @IBOutlet weak var amoutTip: UILabel!
    
    @IBOutlet weak var memoTip: UILabel!
    
    @IBOutlet weak var toAddressTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var toAddressTipHeight: NSLayoutConstraint!
    
    
    @IBOutlet weak var amoutTipTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var amoutTipHeight: NSLayoutConstraint!
    
    @IBOutlet weak var memoTipHeight: NSLayoutConstraint!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var toWalletAddressDes: UILabel!
    
    @IBOutlet weak var toWalletAddressTextField: UITextField!
    
    @IBOutlet weak var addressBookBtn: UIButton!
    
    @IBOutlet weak var sendAmoutDes: UILabel!
    
    @IBOutlet weak var sendAmoutTextField: UITextField!
    
    @IBOutlet weak var payWalletDes: UILabel!
    
    @IBOutlet weak var payWalletName: UILabel!
    
    @IBOutlet weak var payWalletAddress: UILabel!
    
    @IBOutlet weak var chooseWalletBtn: UIButton!
    
    @IBOutlet weak var memoTextView: UITextView!
    
    @IBOutlet weak var txFeeLabel: UILabel!
    
    @IBOutlet weak var confirmBtn: UIButton!
    
    @IBOutlet weak var feeSlider: UISlider!
    
    @IBOutlet weak var fasterDes: UILabel!
    
    @IBOutlet weak var cheaperDes: UILabel!
    
    @IBOutlet weak var estimatedTimeDes: UILabel!
    
    @IBOutlet weak var feeLabel: UILabel!
    
    @IBOutlet weak var balanceLabel: UILabel!
    
    @IBOutlet weak var sendAllButton: UIButton!
    
    @IBOutlet weak var confirmButtonTopConstraint: NSLayoutConstraint!
    
    var containerViewInitHeight : CGFloat = 0
    
    override func awakeFromNib() {
        initSubViews()
        Localized()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.containerView.frame.size.height != 0 && containerViewInitHeight == 0 && self.confirmButtonTopConstraint.constant == 0{
            containerViewInitHeight = self.containerView.frame.size.height
            if UIDevice.current.screenType == .iPhones_X_XS ||
            UIDevice.current.screenType == .iPhone_XR ||
                UIDevice.current.screenType == .iPhone_XSMax{
                containerViewInitHeight = containerViewInitHeight + 34
            }
        }
        let offset = self.frame.size.height - containerViewInitHeight
        self.confirmButtonTopConstraint.constant = offset
    }
    
    func initSubViews() {
        addressBookBtn.addMaskView(corners: [.bottomRight,.topRight], cornerRadiiV: 5)
        
        chooseWalletBtn.setupSwitchWalletStyle()
        

        memoTextView.placeholderColor = transfer_placeholder_color;
        memoTextView.textColor = transfer_input_color
        
        feeSlider.minimumTrackTintColor = UIColor(rgb: 0xFFED1A)
        feeSlider.maximumTrackTintColor = UIColor(rgb: 0xEFF0F5)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap))
        addGestureRecognizer(tap)
        
        toAddressTipHeight.constant = 0
        amoutTipHeight.constant = 0
        memoTipHeight.constant = 0
        
        amoutTipTopConstraint.constant = 0
        toAddressTopConstraint.constant = 0
        
        feeSlider.setThumbImage(UIImage(named: "dragSliderIcon"), for: .normal)
    }
    
    func checkInputAddress() -> Bool{
        var valid = true
        if toWalletAddressTextField.text?.length == 0 {
            self.toAddressTip.localizedText = "transferVC_address_empty_tip"
            valid = false
        }
        
        if (!(toWalletAddressTextField.text?.is40ByteAddress())!) {
            self.toAddressTip.localizedText = "transferVC_address_Incorrect_tip"
            valid = false
        }
        return valid
    }
    func checkInputAddress(showTip : Bool) -> Bool{
        var tipHeight : CGFloat
        if showTip{
            tipHeight = 16
        }else{
            tipHeight = 0
        }

        let valid = checkInputAddress()
        
        if showTip && !valid{
            UIView.animate(withDuration: 0.3) {
                self.toAddressTipHeight.constant = tipHeight
                self.toAddressTopConstraint.constant = 6
                self.layoutIfNeeded()
                self.setNeedsLayout()
            }
        }else{
            UIView.animate(withDuration: 0.3) {
                self.toAddressTopConstraint.constant = 0
                self.toAddressTipHeight.constant = 0
                self.layoutIfNeeded()
                self.setNeedsLayout()
            }
        }

        return true
    }
    
    func checkInputAmout() -> Bool {
        var valid = true
        if sendAmoutTextField.text?.length == 0 {
            self.amoutTip.localizedText = "transferVC_amout_empty_tip"
            valid = false
        }
        
        if (!(sendAmoutTextField.text?.isValidInputAmoutWith8DecimalPlaceAndNonZero())!){
            self.amoutTip.localizedText = "transferVC_amout_amout_input_error"
            valid = false
        }
        return valid
    }
    
    func checkInputAmout(showTip : Bool) -> Bool{
        var tipHeight : CGFloat
        if showTip{
            tipHeight = 16
        }else{
            tipHeight = 0
        }
        let valid = checkInputAmout()
        
        if !valid && showTip{
            UIView.animate(withDuration: 0.3) {
                self.amoutTipHeight.constant = tipHeight
                self.amoutTipTopConstraint.constant = 6
                self.layoutIfNeeded()
                self.setNeedsLayout()
            }
        }else{
            self.sendAmoutTextField.textColor = .white
            UIView.animate(withDuration: 0.3) {
                self.amoutTipTopConstraint.constant = 0
                self.amoutTipHeight.constant = 0
                self.layoutIfNeeded()
                self.setNeedsLayout()
            }
        }

        return valid
    }
    
    func resportSufficiency(isSufficient : Bool){
        if isSufficient{
            self.sendAmoutTextField.textColor = .white
            UIView.animate(withDuration: 0.3) {
                self.amoutTipHeight.constant = 0
                self.amoutTipTopConstraint.constant = 0
                self.layoutIfNeeded()
                self.setNeedsLayout()
            }
        }else{
            UIView.animate(withDuration: 0.3) {
                self.amoutTipHeight.constant = 16
                self.amoutTipTopConstraint.constant = 6
                self.layoutIfNeeded()
                self.setNeedsLayout()
            }
            self.amoutTip.localizedText = "transferVC_Insufficient_balance"
            self.sendAmoutTextField.textColor = UIColor(rgb: 0xFF4747)
        }
    }
    
    func checkInputMemo() -> Bool{
        return true
    }
    
    func Localized() {
        toWalletAddressDes.localizedText = "transferVC_wallet_address_des"
        toWalletAddressTextField.LocalizePlaceholder = "transferVC_wallet_address_placeholder"
        sendAmoutDes.localizedText = "transferVC_Amount_des"
        sendAmoutTextField.LocalizePlaceholder = "transferVC_Input_placeholder"
        payWalletDes.localizedText = "transferVC_Wallet_des"
        payWalletName.localizedText = "transferVC_Wallet_name_des"
        txFeeLabel.localizedText = "transferVC_selectFee_des"
        cheaperDes.localizedText = "transferVC_cheaper_des"
        fasterDes.localizedText = "transferVC_faster_des"
        memoTextView.localizedText_Placeholder = "transferVC_switch_memo_placeholder"
    }
    
    @objc func onTap(){
        if toWalletAddressTextField.isFirstResponder{
            toWalletAddressTextField.resignFirstResponder()
        }
        if sendAmoutTextField.isFirstResponder{
            sendAmoutTextField.resignFirstResponder()
        }
        if memoTextView.isFirstResponder {
            memoTextView.resignFirstResponder()
        }
    }

}
