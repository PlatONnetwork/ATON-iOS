//
//  ImportKeystoreViewController.swift
//  platonWallet
//
//  Created by matrixelement on 2018/10/23.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class ImportKeystoreViewController: BaseImportWalletViewController,UIScrollViewDelegate {

    
    @IBOutlet weak var keystoreTextView: UITextView!
    @IBOutlet weak var keystoreTipsLabel: UILabel!
    @IBOutlet weak var nameTF: PTextFieldWithPadding!
    @IBOutlet weak var nameTipsLabel: UILabel!
    @IBOutlet weak var pswTF: PTextFieldWithPadding!
    @IBOutlet weak var pswTipsLabel: UILabel!
    @IBOutlet weak var importBtn: PButton!
    
    @IBOutlet weak var pasteButton: UIButton!
    @IBOutlet weak var keystoreTipsBottomLayout: NSLayoutConstraint!
    
    @IBOutlet weak var nameTipsBottomLayout: NSLayoutConstraint!
    
    @IBOutlet weak var pswTipsBottomLayout: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var scrollViewBottomLayout: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        endEditingWhileTapBackgroundView = true
        
        keystoreTextView.text = defaultText
        keystoreTextView.tintColor = keystoreTextView.textColor
        scrollView.keyboardDismissMode = .interactive
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onPasteboardChange), name: UIPasteboard.changedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onPasteboardChange), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        importBtn.style = .disable
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.checkKeyboard()
    }
    
    @objc func onPasteboardChange(){
        self.checkKeyboard()
    }
    
    func checkKeyboard(){ 
        if let pasteBoardString = UIPasteboard.general.string{
            if pasteBoardString.isKeyStoreString(){
                self.pasteButton.setTitleColor(UIColor(rgb: 0x105CFE), for: .normal)
            }else{
                self.pasteButton.setTitleColor(UIColor(rgb: 0xB6BBD0), for: .normal)
            }
        }else{
            self.pasteButton.setTitleColor(UIColor(rgb: 0xB6BBD0), for: .normal)
        }
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
        
        guard checkInputValueIsValid() else { return }
        
        showLoadingHUD()
        
        WalletService.sharedInstance.import(keystore: keystoreTextView.text, walletName: nameTF.text!, password: pswTF.text!) {[weak self] (wallet, error) in
            
            self?.hideLoadingHUD(animated: false)
            
            guard error == nil && wallet != nil else {
                self?.showMessage(text: error!.errorDescription ?? "")
                return
            }

            self?.showMessage(text: Localized("importWalletVC_success_tips"))
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3, execute: {
                (UIApplication.shared.delegate as? AppDelegate)?.gotoMainTab()
            })
            
            
        }
        
        
    }
    
    func checkCanEableButton() {
        if self.checkInputValueIsValid(){
            importBtn.style = .blue
        }else{
            importBtn.style = .disable
        }
    }
    
    func checkInputValueIsValid() -> Bool {
        return checkKeystoreTV(showError: false) && checkNameTF(showError: false) && checkPswTF(showError: false)
    }
    
    func checkKeystoreTV(showError: Bool = true) -> Bool {
        if showError{
            if keystoreTextView.text!.isEmpty {
                keystoreTipsLabel.text = Localized("importKeystoreVC_keystore_empty_tips")
                keystoreTipsLabel.isHidden = false
                keystoreTipsBottomLayout.priority = .defaultHigh
            }else {
                keystoreTipsLabel.isHidden = true
                keystoreTipsBottomLayout.priority = .defaultLow
            }
        }
        
        self.view.layoutIfNeeded()
        
        return !keystoreTextView.text!.isEmpty
    }
    
    func checkNameTF(showError: Bool = true) -> Bool {
        let nameRes = CommonService.isValidWalletName(nameTF.text,checkDuplicate: true)
        if showError{
            if (nameRes.0) {
                nameTipsLabel.isHidden = true
                nameTipsBottomLayout.priority = .defaultLow
                nameTF.setBottomLineStyle(style: .Normal)
            }else {
                nameTipsLabel.text = nameRes.1
                nameTipsLabel.isHidden = false
                nameTipsBottomLayout.priority = .defaultHigh
                nameTF.setBottomLineStyle(style: .Error)
            }
            self.view.layoutIfNeeded()
        }
        
        return nameRes.0
    }
    
    func checkPswTF(showError: Bool = true) -> Bool {
        let pswRes = CommonService.isValidWalletPassword(pswTF.text)
        if showError{
            if (pswRes.0) {
                pswTipsLabel.isHidden = true
                pswTipsBottomLayout.priority = .defaultLow
                pswTF.setBottomLineStyle(style: .Normal)
            }else {
                pswTipsLabel.text = pswRes.1
                pswTipsLabel.isHidden = false
                pswTipsBottomLayout.priority = .defaultHigh
                pswTF.setBottomLineStyle(style: .Error)
            }
            self.view.layoutIfNeeded()
        }
        
        return pswRes.0
    }
    
    //MARK:- User Interaction
    
    @IBAction func onPaste(_ sender: Any) {
        if let pasteBoardString = UIPasteboard.general.string{
            if pasteBoardString.isKeyStoreString(){
                self.keystoreTextView.text = pasteBoardString
            }
        }
    }
}

extension ImportKeystoreViewController: UITextFieldDelegate, UITextViewDelegate {
    
    //MARK:- UITextFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == nameTF {
            let _ = checkNameTF()
        }else if textField == pswTF {
            let _ = checkPswTF()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTF {
            pswTF.becomeFirstResponder()
        }else if textField == pswTF {
            pswTF.resignFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { 
            self.checkCanEableButton()
        }
        return true
    }
    
    //MARK:- UITextViewDelegate
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView == keystoreTextView {
            let _ = checkKeystoreTV()
        }
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { 
            self.checkCanEableButton()
        }
        return true
    }
    
}
