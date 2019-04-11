//
//  CreateIndividualWalletViewController.swift
//  platonWallet
//
//  Created by matrixelement on 15/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class CreateIndividualWalletViewController: BaseViewController,StartBackupMnemonicDelegate {
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(afterBackup), name: NSNotification.Name(BackupMnemonicFinishNotification), object: nil)
    }
    
    func setupUI() {
        
        endEditingWhileTapBackgroundView = true

        super.leftNavigationTitle = "createWalletVC_title"
        
        showNavigationBarShadowImage()
        
        nameTF.becomeFirstResponder()
        
        createBtn.style = .disable
        
    }
    
    override func rt_customBackItem(withTarget target: Any!, action: Selector!) -> UIBarButtonItem! {
        return self.getBasicLeftBarButtonItemWithBasicStyle(localizedText: "createWalletVC_title")
    }
    
    @IBAction func createWallet(_ sender: Any) {
        
        view.endEditing(true)
        
        guard checkInputValueIsValid() else {
            return
        }
        
        showLoadingHUD() 
        
        WalletService.sharedInstance.createWallet(name: nameTF.text!, password: pswTF.text!) { [weak self](wallet, error) in

            guard error == nil && wallet != nil else {
                self?.showMessage(text: error!.errorDescription ?? "")
                return
            }
             
            self?.hideLoadingHUD()
            self?.wallet = wallet
            let successVC = CreateWalletSuccessViewController()
            successVC.delegate = self
            self?.navigationController?.pushViewController(successVC, animated: true)
            
        }
        
    }
    
    
  
    
    //MARK: - Check Input
    
    func checkCanEableButton() {
        if self.checkInputValueIsValid(){
            createBtn.style = .blue
        }else{
            createBtn.style = .disable
        }
    }
    
    func checkInputValueIsValid() -> Bool {
        
        return checkNameTF() && checkPswTF(isConfirmPsw: true)
        
    }
    
    
    func checkNameTF(showErrorMsg: Bool = false) -> Bool {
        let nameRes = CommonService.isValidWalletName(nameTF.text,checkDuplicate: true)
        if showErrorMsg{
            if nameRes.0 {
                nameTipsLabel.isHidden = true
                pswLabelTopLayoutWithNameTips.priority = .defaultLow
                nameTF.setBottomLineStyle(style: .Normal)
            }else {
                nameTipsLabel.text = nameRes.1 ?? ""
                nameTipsLabel.isHidden = false
                pswLabelTopLayoutWithNameTips.priority = .defaultHigh
                nameTF.setBottomLineStyle(style: .Error)
            }
        }
        self.view.layoutIfNeeded()
        return nameRes.0
    } 
    
    func checkPswTF(showErrorMsg: Bool = false,isConfirmPsw: Bool = false) -> Bool {
        
        let pswRes = CommonService.isValidWalletPassword(pswTF.text, confirmPsw: isConfirmPsw ? confirmPswTF.text : nil)
        if showErrorMsg{
            if pswRes.0 {
                pswTipsLabel.isHidden = true
                pswAdviseLabel.isHidden = false 
                noteLabelTopLayoutWithPswTips.priority = .defaultLow
                pswTF.setBottomLineStyle(style: .Normal)
                confirmPswTF.setBottomLineStyle(style: .Normal)
            }else {
                pswTipsLabel.text = pswRes.1
                pswTipsLabel.isHidden = false
                pswAdviseLabel.isHidden = true
                noteLabelTopLayoutWithPswTips.priority = .defaultHigh
                pswTF.setBottomLineStyle(style: .Error)
                confirmPswTF.setBottomLineStyle(style: .Error)
            }
        }
        self.view.layoutIfNeeded()
        return pswRes.0
    }
    
    
    /// BackupDelegate
    func startBackup() {
        showInputPswAlert()
    }
    
    @objc func afterBackup() {
        WalletService.sharedInstance.afterBackupMnemonic(wallet: wallet)
    }
    
    
    func showInputPswAlert() { 
        
        let alertVC = AlertStylePopViewController.initFromNib()
        let style = PAlertStyle.passwordInput(walletName: self.nameTF.text)
        alertVC.onAction(confirm: {[weak self] (text, _) -> (Bool)  in
            let valid = CommonService.isValidWalletPassword(text ?? "")
            if !valid.0{
                alertVC.showInputErrorTip(string: valid.1)
                return false
            }
            
            if (self?.pswTF.text != text) {
                alertVC.showInputErrorTip(string: Localized("alert_psw_input_error_title"))
                return false
                
            }else {
                
                self?.showLoadingHUD()
                WalletService.sharedInstance.exportMnemonic(wallet: self!.wallet, password: self!.pswTF.text!, completion: { (res, error) in
                    if (error == nil && (res!.length) > 0) {
                        let vc = BackupMnemonicViewController()
                        vc.walletAddress = self?.wallet.key?.address
                        vc.mnemonic = res 
                        self?.rt_navigationController.pushViewController(vc, animated: true)
                        alertVC.dismissWithCompletion()
                    }else{
                        self?.hideLoadingHUD()
                        alertVC.showInputErrorTip(string: error?.errorDescription)
                    }
                })
                return false
                
            }
            
        }) { (_, _) -> (Bool) in
            return true
        }
        alertVC.style = style
        alertVC.showInViewController(viewController: self)
        return
    }
    
}

extension CreateIndividualWalletViewController :UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == self.pswTF || textField == self.confirmPswTF {
            if string == " " {
                return false
            }
        }
        
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
            let _ = checkNameTF(showErrorMsg: true)
        }else if textField == pswTF {
            let _ = checkPswTF(showErrorMsg: true,isConfirmPsw: confirmPswTF.text!.length > 0)
        }else if textField == confirmPswTF {
            let _ = checkPswTF(showErrorMsg: true,isConfirmPsw: true)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == nameTF {
            pswTF.becomeFirstResponder()
        }else if textField == pswTF {
            confirmPswTF.becomeFirstResponder()
        }else if textField == confirmPswTF {
            confirmPswTF.resignFirstResponder()
        }
        
        return true
    }
    
}
