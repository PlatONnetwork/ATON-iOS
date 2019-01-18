//
//  CreateIndividualWalletViewController.swift
//  platonWallet
//
//  Created by matrixelement on 15/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class CreateIndividualWalletViewController: BaseViewController,BackupDelegate {

    @IBOutlet weak var nameTF: PTextFieldWithPadding!
    @IBOutlet weak var pswTF: PTextFieldWithPadding!
    @IBOutlet weak var confirmPswTF: PTextFieldWithPadding!
    
    @IBOutlet weak var pswAdviseLabel: UILabel!
    @IBOutlet weak var nameTipsLabel: UILabel!
    @IBOutlet weak var pswTipsLabel: UILabel!
    
    @IBOutlet weak var noteLabelTopLayoutWithPswTips: NSLayoutConstraint!
    
    @IBOutlet weak var pswLabelTopLayoutWithNameTips: NSLayoutConstraint!
    
    @IBOutlet weak var strengthView: PasswordStrengthView!
    
    @IBOutlet weak var createBtn: PButton!
    
    var wallet:Wallet!
    var alertPswInput: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        
        endEditingWhileTapBackgroundView = true

        navigationItem.localizedText = "createWalletVC_title"
        
        showNavigationBarShadowImage()
        
        nameTF.becomeFirstResponder()
        
        checkCanEableButton()
    }
    
    @IBAction func createWallet(_ sender: Any) {
        
        view.endEditing(true)
        
        guard checkInputValueIsValid() else {
            return
        }
        
        showLoading()
        
        
        
        WalletService.sharedInstance.createWallet(name: nameTF.text!, password: pswTF.text!) { [weak self](wallet, error) in

            guard error == nil && wallet != nil else {
                self?.showMessage(text: error!.errorDescription ?? "")
                return
            }
            
            self?.hideLoading()
            self?.wallet = wallet
            let successVC = CreateWalletSuccessViewController()
            successVC.delegate = self
            self?.navigationController?.pushViewController(successVC, animated: true)
            
        }
        
    }
    
    
    func checkInputValueIsValid() -> Bool {
        
        return checkNameTF() && checkPswTF(isConfirmPsw: true)
          
    }
    
    func checkCanEableButton() {
        createBtn.isEnabled = nameTF.text!.length > 0 && pswTF.text!.length > 5 && confirmPswTF.text!.length > 5
    }
    
    func checkNameTF() -> Bool {
        let nameRes = CommonService.isValidWalletName(nameTF.text)
        
        if nameRes.0 {
            nameTipsLabel.isHidden = true
            pswLabelTopLayoutWithNameTips.priority = .defaultLow
        }else {
            nameTipsLabel.text = nameRes.1 ?? ""
            nameTipsLabel.isHidden = false
            pswLabelTopLayoutWithNameTips.priority = .defaultHigh
        }
        self.view.layoutIfNeeded()
        return nameRes.0
    }
    
    func checkPswTF(isConfirmPsw: Bool = false) -> Bool {
        
        let pswRes = CommonService.isValidWalletPassword(pswTF.text, confirmPsw: isConfirmPsw ? confirmPswTF.text : nil)
        if pswRes.0 {
            pswTipsLabel.isHidden = true
            pswAdviseLabel.isHidden = false 
            noteLabelTopLayoutWithPswTips.priority = .defaultLow
        }else {
            pswTipsLabel.text = pswRes.1
            pswTipsLabel.isHidden = false
            pswAdviseLabel.isHidden = true
            noteLabelTopLayoutWithPswTips.priority = .defaultHigh
        }
        self.view.layoutIfNeeded()
        return pswRes.0
    }
    
    
    /// BackupDelegate
    func startBackupClick() {
        
        showInputPswAlert()
        
    }
    
    func showInputPswAlert() {
        
        let alertC = PAlertController(title: Localized("alert_input_psw_title"), message: nil)
        alertC.addTextField(text: alertPswInput, placeholder: "", isSecureTextEntry: true)
        alertC.addAction(title: Localized("alert_cancelBtn_title")) {
            
        }
        alertC.addAction(title: Localized("alert_confirmBtn_title")) { [weak self] in
            
            let input = alertC.textField?.text ?? ""
            if !CommonService.isValidWalletPassword(alertC.textField?.text ?? "").0{
                return
            }
            alertC.dismiss(animated: true, completion: nil)
            
            if (self?.pswTF.text != alertC.textField?.text) {
                self?.alertPswInput = alertC.textField?.text
                self?.showErrorPswAlert()
            }else {
                self?.pushToBackupMnemonicVC()
            }
            
        }
        alertC.inputVerify = { input in
            return CommonService.isValidWalletPassword(input).0
        }
        alertC.addActionEnableStyle(title: Localized("alert_confirmBtn_title"))
        alertC.show(inViewController: self, animated: false)
        alertC.textField?.becomeFirstResponder()

    }
    
    func showErrorPswAlert() {
        
        let alertC = PAlertController(title: Localized("alert_psw_input_error_title"), message: Localized("alert_psw_input_error_msg"))
        
        alertC.addAction(title: Localized("alert_psw_input_error_backBtn_title")) { [weak self] in
            
            self?.showInputPswAlert()
            
        }
        alertC.show(inViewController: self)
    }
    
    func pushToBackupMnemonicVC() {
        
        let vc = BackupMnemonicViewController()
        vc.mnemonic = wallet.key?.mnemonic
        rt_navigationController.pushViewController(vc, animated: true) 
        
    }

    
}

extension CreateIndividualWalletViewController :UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { 
            self.checkCanEableButton()
            
            if textField == self.pswTF {
                
                self.strengthView.updateFor(password: self.pswTF.text ?? "")
            }
            
        }
        
        return true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == nameTF {
            let _ = checkNameTF()
        }else if textField == pswTF {
            let _ = checkPswTF(isConfirmPsw: confirmPswTF.text!.length > 0)
        }else if textField == confirmPswTF {
            let _ = checkPswTF(isConfirmPsw: true)
        }
    }
    
}
