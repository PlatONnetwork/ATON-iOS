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

    @IBOutlet weak var walletPhysicalTypeLabel: UILabel!
    @IBOutlet weak var walletTypeBottomLine: UIView!
    @IBOutlet weak var nameTF: PTextFieldWithPadding!
    @IBOutlet weak var pswTF: PTextFieldWithPadding!
    @IBOutlet weak var confirmPswTF: PTextFieldWithPadding!

    @IBOutlet weak var pswAdviseLabel: UILabel!
    @IBOutlet weak var nameTipsLabel: UILabel!
    @IBOutlet weak var pswTipsLabel: UILabel!

    @IBOutlet weak var noteLabelTopLayoutWithPswTips: NSLayoutConstraint!

    @IBOutlet weak var pswLabelTopLayoutWithNameTips: NSLayoutConstraint!

    @IBOutlet weak var pswAdviseLabelTopToStrengthLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var pswAdviseLabelTopToConfirmPSWLayoutConstraint: NSLayoutConstraint!

    @IBOutlet weak var strengthView: PasswordStrengthView!

    @IBOutlet weak var createBtn: PButton!

    var wallet:Wallet!
    var alertPswInput: String?
    
    /// 当前的钱包物理类型
    var curWalletPhysicalType: WalletPhysicalType! {
        didSet {
            if curWalletPhysicalType == .normal {
                self.walletPhysicalTypeLabel.text = Localized("createWalletVC_walletType_normal")
            } else if curWalletPhysicalType == .hd {
                self.walletPhysicalTypeLabel.text = Localized("createWalletVC_walletType_hd")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        prepareData()
        NotificationCenter.default.addObserver(self, selector: #selector(afterBackup), name: Notification.Name.ATON.BackupMnemonicFinish, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        AnalysisHelper.handleEvent(id: event_newWallet, operation: .begin)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        AnalysisHelper.handleEvent(id: event_newWallet, operation: .cancel)
    }
    
    /// 初始化准备数据
    func prepareData() {
        curWalletPhysicalType = .normal
    }

    func setupUI() {
        walletTypeBottomLine.backgroundColor = bottomLineNormalColor
        endEditingWhileTapBackgroundView = true

        super.leftNavigationTitle = "createWalletVC_title"

        //showNavigationBarShadowImage()

//        nameTF.becomeFirstResponder()

        createBtn.style = .disable

        pswAdviseLabelTopToStrengthLayoutConstraint.priority = .defaultLow
        pswAdviseLabelTopToConfirmPSWLayoutConstraint.priority = .defaultHigh
        self.strengthView.isHidden = true
    }

    override func rt_customBackItem(withTarget target: Any!, action: Selector!) -> UIBarButtonItem! {
        return self.getBasicLeftBarButtonItemWithBasicStyle(localizedText: "createWalletVC_title")
    }

    @IBAction func createWallet(_ sender: Any) {

        view.endEditing(true)

        guard checkInputValueIsValid() else {
            return
        }

        if self.isInCustomLoading != nil && self.isInCustomLoading! {
            return
        }
        showLoadingHUD()
        WalletService.sharedInstance.createWallet(name: nameTF.text!, password: pswTF.text!, physicalType: self.curWalletPhysicalType) { [weak self](wallet, error) in

            AnalysisHelper.handleEvent(id: event_newWallet, operation: .end)

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

    @IBAction func chooseWalletPhysicalType(_ sender: Any) {
        print("选择钱包类型")
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
    
    // MARK: - Check Input

    func checkCanEableButton() {
        if self.checkInputValueIsValid() {
            createBtn.style = .blue
        } else {
            createBtn.style = .disable
        }
    }

    func checkInputValueIsValid() -> Bool {

        return checkNameTF() && checkPswTF(isConfirmPsw: true)

    }

    func checkNameTF(showErrorMsg: Bool = false) -> Bool {
        let nameRes = CommonService.isValidWalletName(nameTF.text,checkDuplicate: true)
        if showErrorMsg {
            if nameRes.0 {
                nameTipsLabel.isHidden = true
                pswLabelTopLayoutWithNameTips.priority = .defaultLow
                nameTF.setBottomLineStyle(style: .Normal)
            } else {
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
        if showErrorMsg {
            if pswRes.0 {
                pswTipsLabel.isHidden = true
                pswAdviseLabel.isHidden = false
                noteLabelTopLayoutWithPswTips.priority = .defaultLow
                pswTF.setBottomLineStyle(style: .Normal)
                confirmPswTF.setBottomLineStyle(style: .Normal)
            } else {
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
        showWalletBackup(wallet: wallet)
    }

}

extension CreateIndividualWalletViewController :UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if textField == self.pswTF || textField == self.confirmPswTF {
            if string == " " {
                return false
            }
        }

        if textField == self.nameTF && string != "" {
            if let text = textField.text, let textRange = Range(range, in: text) {
                let appendtext = text.replacingCharacters(in: textRange, with: string)
                let result = CommonService.isValidWalletName(appendtext, checkDuplicate: false)
                return result.0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.checkCanEableButton()
            self.strengthView.isHidden = !(self.pswTF.text?.count ?? 0 > 0)
            self.pswAdviseLabelTopToStrengthLayoutConstraint.priority = self.strengthView.isHidden ? .defaultLow : .defaultHigh
            self.pswAdviseLabelTopToConfirmPSWLayoutConstraint.priority = self.strengthView.isHidden ? .defaultHigh : .defaultLow

            if textField == self.pswTF {
                self.strengthView.updateFor(password: self.pswTF.text ?? "")
            }

        }

        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {

        if textField == nameTF {
            _ = checkNameTF(showErrorMsg: true)
        } else if textField == pswTF {
            _ = checkPswTF(showErrorMsg: true,isConfirmPsw: confirmPswTF.text!.length > 0)
        } else if textField == confirmPswTF {
            _ = checkPswTF(showErrorMsg: true,isConfirmPsw: true)
        }

        strengthView.isHidden = !(pswTF.text?.count ?? 0 > 0)
        pswAdviseLabelTopToStrengthLayoutConstraint.priority = strengthView.isHidden ? .defaultLow : .defaultHigh
        pswAdviseLabelTopToConfirmPSWLayoutConstraint.priority = strengthView.isHidden ? .defaultHigh : .defaultLow
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        if textField == nameTF {
            pswTF.becomeFirstResponder()
        } else if textField == pswTF {
            confirmPswTF.becomeFirstResponder()
        } else if textField == confirmPswTF {
            confirmPswTF.resignFirstResponder()
        }

        return true
    }

}
