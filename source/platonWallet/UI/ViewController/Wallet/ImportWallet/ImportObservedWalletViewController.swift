//
//  ImportObservedWalletViewController.swift
//  platonWallet
//
//  Created by Admin on 23/9/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import SnapKit
import Localize_Swift

class ImportObservedWalletViewController: BaseImportWalletViewController {
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    let tipLabel = UILabel()
    let addresstextView = UITextView()
    let textViewTipLabel = UILabel()
    
    let submitButton = PButton()
    let pasteButton = UIButton()
    
    var submitButtonTopConstaint: Constraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view.snp.width)
            make.height.equalTo(view.snp.height)
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3
        paragraphStyle.headIndent = 8
        
        let dotString = "• "
        let dotAttr = NSAttributedString(string: dotString, attributes: [NSAttributedString.Key.foregroundColor: common_blue_color])
        let attr1 = NSMutableAttributedString(string: Localized("import_observed_wallet_tip_1") + "\n")
        attr1.insert(dotAttr, at: 0)
        
        let attr2 = NSMutableAttributedString(string: Localized("import_observed_wallet_tip_2") + "\n")
        attr2.insert(dotAttr, at: 0)
        
        let attr3 = NSMutableAttributedString(string: Localized("import_observed_wallet_tip_3") + "\n")
        attr3.insert(dotAttr, at: 0)
        
        let attr4 = NSMutableAttributedString(string: Localized("import_observed_wallet_tip_4") + "\n")
        attr4.insert(dotAttr, at: 0)
        
        let attributedString = NSMutableAttributedString()
        attributedString.append(attr1)
        attributedString.append(attr2)
        attributedString.append(attr3)
        attributedString.append(attr4)
        attributedString.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle], range: NSRange(location: 0, length: attributedString.string.count))
        
       
        tipLabel.textColor = common_darkGray_color
        tipLabel.font = UIFont.systemFont(ofSize: 12)
        tipLabel.numberOfLines = 0
        tipLabel.attributedText = attributedString
        contentView.addSubview(tipLabel)
        tipLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(16)
        }
        
        addresstextView.backgroundColor = UIColor(hex: "f0f1f5")
        addresstextView.font = UIFont.systemFont(ofSize: 14)
        addresstextView.textColor = .black
        addresstextView.LocalizePlaceholder = "importKeystoreVC_addressInput_placeholder"
        addresstextView.delegate = self
        contentView.addSubview(addresstextView)
        addresstextView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(tipLabel.snp.bottom).offset(4)
            make.height.equalTo(95)
        }
        
        textViewTipLabel.font = UIFont.systemFont(ofSize: 12)
        textViewTipLabel.textColor = UIColor(hex: "ff4747")
        contentView.addSubview(textViewTipLabel)
        textViewTipLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(addresstextView)
            make.top.equalTo(addresstextView.snp.bottom).offset(8)
        }
        
        submitButton.localizedNormalTitle = "importWalletVC_import_observed_title"
        submitButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        submitButton.addTarget(self, action: #selector(startImport), for: .touchUpInside)
        contentView.addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(addresstextView.snp.bottom).offset(30).priorityMedium()
            self.submitButtonTopConstaint = make.top.equalTo(textViewTipLabel.snp.bottom).offset(30).priorityHigh().constraint
            make.height.equalTo(44)
        }
        contentView.layoutIfNeeded()
        
        pasteButton.setTitleColor(common_blue_color, for: .normal)
        pasteButton.localizedNormalTitle = "importWalletVC_PasteButton"
        pasteButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        pasteButton.addTarget(self, action: #selector(onPaste), for: .touchUpInside)
        contentView.addSubview(pasteButton)
        pasteButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalTo(addresstextView.snp.bottom).offset(-35.5)
        }
        
        endEditingWhileTapBackgroundView = true
        
        addresstextView.text = defaultText
        addresstextView.tintColor = addresstextView.textColor
        scrollView.keyboardDismissMode = .interactive
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onPasteboardChange), name: UIPasteboard.changedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onPasteboardChange), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        submitButton.style = .disable
        submitButtonTopConstaint?.deactivate()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
            if pasteBoardString.is40ByteAddress() {
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
    
    func checkCanEableButton() {
        if self.checkInputValueIsValid(){
            submitButton.style = .blue
        }else{
            submitButton.style = .disable
        }
    }
    
    func checkInputValueIsValid() -> Bool {
        return checkObservedWalletTV(showError: false)
    }
    
    func checkObservedWalletTV(showError: Bool = true) -> Bool {
        if showError {
            if addresstextView.text!.isEmpty {
                textViewTipLabel.text = Localized("importKeystoreVC_observed_empty_tips")
                submitButtonTopConstaint?.activate()
                textViewTipLabel.isHidden = false
                self.view.layoutIfNeeded()
                return false
            }
            
            if !addresstextView.text!.is40ByteAddress() {
                textViewTipLabel.text = Localized("importKeystoreVC_observed_invalid_tips")
                submitButtonTopConstaint?.activate()
                textViewTipLabel.isHidden = false
                self.view.layoutIfNeeded()
                return false
            }
            
            let addresses = (AssetVCSharedData.sharedData.walletList as! [Wallet]).map { $0.address.add0x().lowercased() }
            if addresses.contains(addresstextView.text!.add0x().lowercased()) {
                textViewTipLabel.text = Localized("importKeystoreVC_observed_existed_tips")
                submitButtonTopConstaint?.activate()
                textViewTipLabel.isHidden = false
                self.view.layoutIfNeeded()
                return false
            }
        }
        submitButtonTopConstaint?.deactivate()
        textViewTipLabel.isHidden = true
        self.view.layoutIfNeeded()
        return true
    }
    
    //MARK:- User Interaction
    
    @objc func onPaste() {
        if let pasteBoardString = UIPasteboard.general.string{
            if pasteBoardString.is40ByteAddress() {
                self.addresstextView.text = pasteBoardString
            }
        }
    }
    
    @objc func startImport() {
        
        view.endEditing(true)
        
        guard checkInputValueIsValid() else { return }
        
        showLoadingHUD()
        
        WalletService.sharedInstance.import(address: addresstextView.text) { [weak self] (wallet, error) in
            self?.hideLoadingHUD(animated: false)
            
            guard error == nil && wallet != nil else {
                self?.showMessage(text: error!.errorDescription ?? "")
                return
            }
            
            self?.showMessage(text: Localized("importWalletVC_success_tips"), delay: 1.0)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3, execute: {
                (UIApplication.shared.delegate as? AppDelegate)?.gotoMainTab()
            })
        }
    }

}

extension ImportObservedWalletViewController: UITextFieldDelegate, UITextViewDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.checkCanEableButton()
        }
        return true
    }
    
    //MARK:- UITextViewDelegate
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView == addresstextView {
            let _ = checkObservedWalletTV()
        }
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.checkCanEableButton()
        }
        return true
    }
    
}
