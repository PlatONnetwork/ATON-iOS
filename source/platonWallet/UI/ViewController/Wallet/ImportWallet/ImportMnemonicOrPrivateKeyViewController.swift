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
    @IBOutlet weak var pswTF: PPasswordTextField!
    @IBOutlet weak var confirmPswTF: PPasswordTextField!

    @IBOutlet weak var nameTFTipsLabel: UILabel!
    @IBOutlet weak var nameTFTipsBottomLayout: NSLayoutConstraint!

    @IBOutlet weak var pswAdviseLabel: UILabel!
    @IBOutlet weak var pswTipsLabel: UILabel!

    @IBOutlet weak var pswTipsBottomLayout: NSLayoutConstraint!
    @IBOutlet weak var importBtn: PButton!

    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var passwordStrengthView: PasswordStrengthView!

    @IBOutlet weak var mnemonicContainer: UIView!

    @IBOutlet weak var pasteButton: UIButton!

    var mnemonicGridView : MnemonicGridView? = UIView.viewFromXib(theClass: MnemonicGridView.self) as? MnemonicGridView

    @IBOutlet weak var mnemonicContainerHeight: NSLayoutConstraint!

    @IBOutlet weak var inputTextViewHeight: NSLayoutConstraint!
    /// 选择类型视图
    @IBOutlet weak var selectTypeView: UIView!
    /// 私钥TextView到助记词网格视图的间距
    @IBOutlet weak var privateKeyInputTextViewTopToGridViewBottom: NSLayoutConstraint!
    @IBOutlet weak var walletTypeBottomLine: UIView!
    @IBOutlet weak var walletPhysicalTypeLabel: UILabel!
    /// 当前的钱包物理类型
    var curWalletPhysicalType: WalletPhysicalType! = .normal {
        didSet {
            if curWalletPhysicalType == .normal {
                self.walletPhysicalTypeLabel.text = Localized("createWalletVC_walletType_normal")
            } else if curWalletPhysicalType == .hd {
                self.walletPhysicalTypeLabel.text = Localized("createWalletVC_walletType_hd")
            }
        }
    }

    var importType: ImportWalletVCType = .mnemonic

    convenience init(type: ImportWalletVCType) {

        self.init()
        importType = type
    }
    
    func prepareData() {
        curWalletPhysicalType = .normal
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.checkKeyboard()
    }

    @objc func onPasteboardChange() {
        self.checkKeyboard()
    }

    func checkKeyboard() {
        if let pasteBoardString = UIPasteboard.general.string {
            if self.importType == .privateKey && pasteBoardString.is128BytePrivateKey() {
                self.pasteButton.setTitleColor(UIColor(rgb: 0x105CFE), for: .normal)
            } else {
                self.pasteButton.setTitleColor(UIColor(rgb: 0xB6BBD0), for: .normal)
            }
        } else {
            self.pasteButton.setTitleColor(UIColor(rgb: 0xB6BBD0), for: .normal)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onPasteboardChange), name: UIPasteboard.changedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onPasteboardChange), name: UIApplication.willEnterForegroundNotification, object: nil)

    }

    func setupUI() {

        endEditingWhileTapBackgroundView = true

        if importType == .mnemonic {

            headerTipsLabel.localizedText = "importWalletVC_mnemonic_tips"
            textView.localizedText_Placeholder = "importWalletVC_mnemonic_textView_placeholder"
            self.inputTextViewHeight.constant = 0
            self.textView.isHidden = true

            self.mnemonicContainer.addSubview(self.mnemonicGridView!)
            self.mnemonicGridView?.snp.makeConstraints({ (make) in
                make.edges.equalTo(self.mnemonicContainer)
            })
            self.privateKeyInputTextViewTopToGridViewBottom.constant = 74
            walletTypeBottomLine.backgroundColor = bottomLineNormalColor
            self.selectTypeView.isHidden = false
            pasteButton.isHidden = true
        } else {
            headerTipsLabel.localizedText = "importWalletVC_privateKey_tips"
            textView.localizedText_Placeholder = "importWalletVC_privateKey_textView_placeholder"
            self.mnemonicContainerHeight.constant = 0
            self.mnemonicContainer.isHidden = true
            self.privateKeyInputTextViewTopToGridViewBottom.constant = 0
            self.selectTypeView.isHidden = true
        }
        scrollView.keyboardDismissMode = .interactive
        textView.text = defaultText

        importBtn.style = .disable

    }

    @IBAction func chooseWalletPhysicalType(_ sender: Any) {
        let vc = GlobalOptionsVC(options: [("0", Localized("createWalletVC_walletType_normal")), ("1", Localized("createWalletVC_walletType_hd"))], defaultSelectedIndex: 0, didConfirmedSelectionCallback: { (optionId, optionName) in
            print("optionId: \(optionId), optionName: \(optionName)")
            if optionId == "0" {
                self.curWalletPhysicalType = .normal
            } else if optionId == "1" {
                self.curWalletPhysicalType = .hd
            }
        })
        
        self.navigationController?.pushViewController(vc, animated: true)
    }

    ///keyboard notification
    @objc func keyboardWillChangeFrame(_ notify:Notification) {

        let endFrame = notify.userInfo!["UIKeyboardFrameEndUserInfoKey"] as! CGRect
        if endFrame.origin.y - UIScreen.main.bounds.height < 0 {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: endFrame.size.height, right: 0)
        } else {
            scrollView.contentInset = UIEdgeInsets.zero
        }

    }

    @IBAction func startImport(_ sender: Any) {

        view.endEditing(true)

        guard checkInputValueIsValid() else {
            return
        }

        showLoadingHUD()

        if importType == .mnemonic {
            let mnemonicString = self.mnemonicGridView?.getMnemonic()
//            WalletService.sharedInstance.import(mnemonic: mnemonicString!, walletName: nameTF.text!, walletPassword: pswTF.text!) { [weak self](wallet, error) in
//                self?.hideLoadingHUD(animated: false)
//                self?.importCompletion(wallet: wallet, error: error)
//            }
            WalletService.sharedInstance.import(mnemonic: mnemonicString!, walletName: nameTF.text!, walletPassword: pswTF.text!, physicalType: self.curWalletPhysicalType, completion: { [weak self](wallet, error) in
                self?.hideLoadingHUD(animated: false)
                self?.importCompletion(wallet: wallet, error: error)
            })
        } else {

            WalletService.sharedInstance.import(privateKey: textView.text!, walletName: nameTF.text!, walletPassword: pswTF.text!) { [weak self](wallet, error) in

                self?.hideLoadingHUD(animated: false)
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
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3, execute: {
            (UIApplication.shared.delegate as? AppDelegate)?.gotoMainTab()
        })
    }

    func checkCanEableButton() {
        if importType == .mnemonic {
            if self.checkInputValueIsValid() && (mnemonicGridView?.nonEmptyCount())! == 12 {
                importBtn.style = .blue
            } else {
                importBtn.style = .disable
            }
        } else {
            if self.checkInputValueIsValid() && textView.text!.length > 0 {
                importBtn.style = .blue
            } else {
                importBtn.style = .disable
            }
        }

    }

    func checkContentInput(showErrorMsg: Bool = false) -> Bool {
        if importType == .mnemonic {
            if showErrorMsg {
                if (self.mnemonicGridView?.nonEmptyCount())! < 12 {
                    textViewTipsLabel.localizedText = "importWalletVC_mnemonicInput_empty_tips"
                    textViewTipsLabel.isHidden = false
                    textViewTipsBottomLayout.priority = .defaultHigh
                } else {
                    textViewTipsLabel.isHidden = true
                    textViewTipsBottomLayout.priority = .defaultLow
                }
            }
            return (self.mnemonicGridView?.nonEmptyCount())! == 12

        } else {
            if showErrorMsg {
                if textView.text!.isEmpty {
                    if importType == .mnemonic {
                        textViewTipsLabel.localizedText = "importWalletVC_mnemonicInput_empty_tips"
                    } else {
                        textViewTipsLabel.localizedText = "importWalletVC_privateKeyInput_empty_tips"
                    }
                    textViewTipsLabel.isHidden = false
                    textViewTipsBottomLayout.priority = .defaultHigh
                } else {
                    textViewTipsLabel.isHidden = true
                    textViewTipsBottomLayout.priority = .defaultLow
                }
                view.layoutIfNeeded()
            }
            return !textView.text!.isEmpty
        }

    }

    func checkNameTF(showErrorMsg: Bool = false) -> Bool {
        let nameRes = CommonService.isValidWalletName(nameTF.text,checkDuplicate: true)
        if showErrorMsg {
            if (nameRes.0) {
                nameTFTipsLabel.isHidden = true
                nameTFTipsBottomLayout.priority = .defaultLow
                nameTF.setBottomLineStyle(style: .Normal)
            } else {
                nameTFTipsLabel.text = nameRes.1
                nameTFTipsLabel.isHidden = false
                nameTFTipsBottomLayout.priority = .defaultHigh
                nameTF.setBottomLineStyle(style: .Error)
            }
            view.layoutIfNeeded()
        }

        return nameRes.0
    }

    func checkPswTF(showErrorMsg: Bool = false,isConfirmPsw: Bool = false) -> Bool {

        let pswRes = CommonService.isValidWalletPassword(pswTF.text, confirmPsw: isConfirmPsw ? confirmPswTF.text : nil)
        if showErrorMsg {
            if (pswRes.0) {
                pswTipsLabel.isHidden = true
                pswAdviseLabel.isHidden = false
                pswTipsBottomLayout.priority = .defaultLow
                pswTF.setBottomLineStyle(style: .Normal)
                confirmPswTF.setBottomLineStyle(style: .Normal)
            } else {
                pswTipsLabel.text = pswRes.1
                pswTipsLabel.isHidden = false
                pswAdviseLabel.isHidden = true
                pswTipsBottomLayout.priority = .defaultHigh
                pswTF.setBottomLineStyle(style: .Error)
                confirmPswTF.setBottomLineStyle(style: .Error)
            }
            view.layoutIfNeeded()
        }

        return pswRes.0
    }

    func checkInputValueIsValid() -> Bool {
        return checkContentInput() && checkNameTF() && checkPswTF(isConfirmPsw: true)
    }

    // MARK: - User Interaction

    @IBAction func onPaste(_ sender: Any) {
        if let pasteBoardString = UIPasteboard.general.string {
            if self.importType == .privateKey && pasteBoardString.is128BytePrivateKey() {
                self.textView.text = pasteBoardString
                self.checkCanEableButton()
            }
        }
    }

}

extension ImportMnemonicOrPrivateKeyViewController :UITextFieldDelegate, UITextViewDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if textField == self.nameTF && string != "" {
            if let text = textField.text, let textRange = Range(range, in: text) {
                let appendtext = text.replacingCharacters(in: textRange, with: string)
                let result = CommonService.isValidWalletName(appendtext, checkDuplicate: true)
                return result.0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
            if textField == self.pswTF {
                self.passwordStrengthView.updateFor( password: self.pswTF.text ?? "")
            }
            self.checkCanEableButton()
        }

        return true
    }

    // MARK: - UITextFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {

        if textField == nameTF {
            _ = checkNameTF(showErrorMsg: true)
        } else if textField == pswTF {
            _ = checkPswTF(showErrorMsg: true)
        } else if textField == confirmPswTF {
            _ = checkPswTF(showErrorMsg: true,isConfirmPsw: true)
        }
        self.checkCanEableButton()
    }

    // MARK: - UITextViewDelegate
    func textViewDidEndEditing(_ textView: UITextView) {

        if self.textView == textView {
            _ = checkContentInput(showErrorMsg: true)
        }

    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTF {
            pswTF.becomeFirstResponder()
        } else if textField == pswTF {
            confirmPswTF.becomeFirstResponder()
        } else if textField == confirmPswTF {
            textField.resignFirstResponder()
        }
        return true
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.checkCanEableButton()
        }
        return true
    }

}
