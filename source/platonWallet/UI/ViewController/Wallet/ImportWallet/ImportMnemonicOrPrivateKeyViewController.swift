//
//  ImportMnemonicOrPrivateKeyViewController.swift
//  platonWallet
//
//  Created by matrixelement on 2018/10/24.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class ImportMnemonicOrPrivateKeyViewController: BaseImportWalletViewController {
    
    @IBOutlet weak var headerTipsLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewTipsLabel: UILabel!
    @IBOutlet weak var textViewTipsBottomLayout: NSLayoutConstraint!
    
    @IBOutlet weak var nameTF: PTextFieldWithPadding!
    @IBOutlet weak var nameTFTipsLabel: UILabel!
    @IBOutlet weak var nameTFTipsBottomLayout: NSLayoutConstraint!
    @IBOutlet weak var pswTF: PPasswordTextField!
    
    @IBOutlet weak var confirmPswTF: PPasswordTextField!
    
    @IBOutlet weak var pswAdviseLabel: UILabel!
    @IBOutlet weak var pswTipsLabel: UILabel!
    
    @IBOutlet weak var pswTipsBottomLayout: NSLayoutConstraint!
    @IBOutlet weak var importBtn: PButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var passwordStrengthView: PasswordStrengthView!
    
    var importType: ImportWalletVCType = .mnemonic
    
    convenience init(type: ImportWalletVCType) {
        
        self.init()
        importType = type
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    func setupUI() {
        
        endEditingWhileTapBackgroundView = true
        
        if importType == .mnemonic {
            
            headerTipsLabel.localizedText = "importWalletVC_mnemonic_tips"
            textView.localizedText_Placeholder = "importWalletVC_mnemonic_textView_placeholder"
            
        }else {
            
            headerTipsLabel.localizedText = "importWalletVC_privateKey_tips"
            textView.localizedText_Placeholder = "importWalletVC_privateKey_textView_placeholder"
        }
        scrollView.keyboardDismissMode = .interactive
        textView.text = defaultText
        checkCanEableButton()
    }

    ///keyboard notification
    @objc func keyboardWillChangeFrame(_ notify:Notification) {
        
        let endFrame = notify.userInfo!["UIKeyboardFrameEndUserInfoKey"] as! CGRect
        if endFrame.origin.y - UIScreen.main.bounds.height < 0 {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: endFrame.size.height, right: 0)
        }else {
            scrollView.contentInset = UIEdgeInsets.zero
        }
        
    }
    
    
    @IBAction func startImport(_ sender: Any) {
        
        view.endEditing(true)
        
        guard checkInputValueIsValid() else {
            return
        }
        
        showLoading()
        
        if importType == .mnemonic {
            
            WalletService.sharedInstance.import(mnemonic: textView.text!, walletName: nameTF.text!, walletPassword: pswTF.text!) { [weak self](wallet, error) in
                self?.hideLoading(animated: false)
                self?.importCompletion(wallet: wallet, error: error)
            }
            
        }else {
            
            WalletService.sharedInstance.import(privateKey: textView.text!, walletName: nameTF.text!, walletPassword: pswTF.text!) { [weak self](wallet, error) in
                
                self?.hideLoading(animated: false)
                self?.importCompletion(wallet: wallet, error: error)
            }
            
        }
        
    }
    
    func importCompletion(wallet:Wallet?,error:WalletService.Error?) {
        guard error == nil && wallet != nil else {
            showMessage(text: error!.errorDescription ?? "")
            return
        }
        showMessage(text: Localized("importWalletVC_success_tips"))
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5, execute: {
            (UIApplication.shared.delegate as? AppDelegate)?.gotoMainTab()
        })
    }
    
    func checkCanEableButton() {
        importBtn.isEnabled = nameTF.text!.length > 0 && pswTF.text!.length > 5 && confirmPswTF.text!.length > 5 && textView.text!.length > 0
    }
    
    func checkTextView() -> Bool {
        
        if textView.text!.isEmpty {
            if importType == .mnemonic {
                textViewTipsLabel.localizedText = "importWalletVC_mnemonicInput_empty_tips"
            }else {
                textViewTipsLabel.localizedText = "importWalletVC_privateKeyInput_empty_tips"
            }
            
            textViewTipsLabel.isHidden = false
            textViewTipsBottomLayout.priority = .defaultHigh
        }else {
            textViewTipsLabel.isHidden = true
            textViewTipsBottomLayout.priority = .defaultLow
        }
        view.layoutIfNeeded()
        return !textView.text!.isEmpty
        
    }
    
    func checkNameTF() -> Bool {
        
        let nameRes = CommonService.isValidWalletName(nameTF.text)
        if (nameRes.0) {
            nameTFTipsLabel.isHidden = true
            nameTFTipsBottomLayout.priority = .defaultLow
        }else {
            nameTFTipsLabel.text = nameRes.1
            nameTFTipsLabel.isHidden = false
            nameTFTipsBottomLayout.priority = .defaultHigh
        }
        view.layoutIfNeeded()
        return nameRes.0
        
    }
    
    func checkPswTF(isConfirmPsw: Bool = false) -> Bool {
        
        let pswRes = CommonService.isValidWalletPassword(pswTF.text, confirmPsw: isConfirmPsw ? confirmPswTF.text : nil)
        if (pswRes.0) {
            pswTipsLabel.isHidden = true
            pswAdviseLabel.isHidden = false
            pswTipsBottomLayout.priority = .defaultLow
        }else {
            pswTipsLabel.text = pswRes.1
            pswTipsLabel.isHidden = false
            pswAdviseLabel.isHidden = true
            pswTipsBottomLayout.priority = .defaultHigh
        }
        
        view.layoutIfNeeded()
        return pswRes.0
    }
    
    func checkInputValueIsValid() -> Bool {
        
        return checkTextView() && checkNameTF() && checkPswTF(isConfirmPsw: true)
        
//        if textView.text!.isEmpty {
//            if importType == .mnemonic {
//                textViewTipsLabel.text = Localized("importWalletVC_mnemonicInput_empty_tips")
//            }else {
//                textViewTipsLabel.text = Localized("importWalletVC_privateKeyInput_empty_tips")
//            }
//
//            textViewTipsLabel.isHidden = false
//            textViewTipsBottomLayout.priority = .defaultHigh
//        }else {
//            textViewTipsLabel.isHidden = true
//            textViewTipsBottomLayout.priority = .defaultLow
//        }
//        
//        let nameRes = CommonService.isValidWalletName(nameTF.text)
//        if (nameRes.0) {
//            nameTFTipsLabel.isHidden = true
//            nameTFTipsBottomLayout.priority = .defaultLow
//        }else {
//            nameTFTipsLabel.text = nameRes.1
//            nameTFTipsLabel.isHidden = false
//            nameTFTipsBottomLayout.priority = .defaultHigh
//        }
//        
//        let pswRes = CommonService.isValidWalletPassword(pswTF.text, confirmPsw: confirmPswTF.text)
//        if (pswRes.0) {
//            pswTipsLabel.isHidden = true
//            pswAdviseLabel.isHidden = false
//            pswTipsBottomLayout.priority = .defaultLow
//        }else {
//            pswTipsLabel.text = pswRes.1
//            pswTipsLabel.isHidden = false
//            pswAdviseLabel.isHidden = true
//            pswTipsBottomLayout.priority = .defaultHigh
//        }
//        
//        self.view.layoutIfNeeded()
//        
//        return textViewTipsLabel.isHidden && nameRes.0 && pswRes.0
        
    }
    
}

extension ImportMnemonicOrPrivateKeyViewController :UITextFieldDelegate, UITextViewDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) { 
            self.checkCanEableButton()
            if textField == self.pswTF {
                self.passwordStrengthView.updateFor(password: self.pswTF.text ?? "")
            }
        }
        
        return true
    }
    
    //MARK:- UITextFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == nameTF {
            let _ = checkNameTF()
        }else if textField == pswTF {
            let _ = checkPswTF()
        }else if textField == confirmPswTF {
            let _ = checkPswTF(isConfirmPsw: true)
        }
        
    }
    
    //MARK:- UITextViewDelegate
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if self.textView == textView {
            let _ = checkTextView()
        }
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { 
            self.checkCanEableButton()
        }
        return true
    }

}
