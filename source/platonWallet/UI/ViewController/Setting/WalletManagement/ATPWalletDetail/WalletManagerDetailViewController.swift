//
//  WalletManagerDetailViewController.swift
//  platonWallet
//
//  Created by matrixelement on 2018/10/29.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift

enum AlertActionType {
    case modifyWalletName,deleteWallet,exportPrivateKey,exportKeystore
}

class WalletManagerDetailViewController: BaseViewController {

    @IBOutlet weak var walletName: UILabel!
    
    @IBOutlet weak var address: UILabel!
    
    @IBOutlet weak var deleteBtn: PButton!
    
    @IBOutlet weak var exportMnemonicContainer: UIView!
    
    @IBOutlet weak var renameContainer: UIView!
    
    @IBOutlet weak var exportPriContainer: UIView!
    
    @IBOutlet weak var exportKeyStore: UIView!
    
    var wallet: Wallet!
    
    var alertPswInput: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
       setupUI() 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let w = WalletService.sharedInstance.getWalletByAddress(address: wallet.address){
            self.wallet = w
        }
        if wallet.canBackupMnemonic{
            deleteBtn.isHidden = true
            self.exportMnemonicContainer.isHidden = false
        }else{
            deleteBtn.isHidden = false
            self.exportMnemonicContainer.isHidden = true
        }
    }
    
    func setupUI() {
        super.leftNavigationTitle = wallet.name
        deleteBtn.style = .delete
        walletName.text = wallet.name
        address.text = wallet.address
        self.exportMnemonicContainer.isHidden = !self.wallet.canBackupMnemonic
        
        if self.wallet.type == .observed{
            self.exportMnemonicContainer.isHidden = true
            self.renameContainer.isHidden = true
            self.exportPriContainer.isHidden = true
            self.exportKeyStore.isHidden = true
        }
        
    }

    @IBAction func exportPrivateKey(_ sender: Any) {
        showInputPswAlertFor(.exportPrivateKey)
    }
    
    @IBAction func exportKeystore(_ sender: Any) {
        showInputPswAlertFor(.exportKeystore)
    }
    
    @IBAction func deleteWallet(_ sender: Any) {
        showInputPswAlertFor(.deleteWallet)
    }
    
    @IBAction func exportMnemonics(_ sender: Any) {
        print("exportMnemonics")
        self.showWalletBackup(wallet: self.wallet)
    }
    
    
    @IBAction func modifyWalletName(_ sender: Any) {
        self.showCommonRenameInput(completion: { [weak self] text in
            self?.updateWalletName(text!)
        }, checkDuplicate: true)
    }
    
    func updateWalletName(_ name:String) {
        
        WalletService.sharedInstance.updateWalletName(wallet, name: name)
        walletName.text = name
        if let titleLabel = super.titleLabel{
            titleLabel.text = name
        }
    }
    
    func showErrorNameAlert() {
        let alertVC = AlertStylePopViewController.initFromNib()
        let style = PAlertStyle.AlertWithRedTitle(title: "alert_modifyWalletName_error_title", message: "alert_modifyWalletName_error_msg")
        alertVC.onAction(confirm: { (text, _) -> (Bool) in
            return true
        }) { (_, _) -> (Bool) in
            return true
        }
        alertVC.style = style
        alertVC.showInViewController(viewController: self)
    }
    
    func showInputPswAlertFor(_ type: AlertActionType) {
        if wallet.type == .observed && type == .deleteWallet {
            confirmToDeleteObserverWallet()
            return
        }
        
        let alertVC = AlertStylePopViewController.initFromNib()
        alertVC.style = PAlertStyle.passwordInput(walletName: self.wallet.name)
        alertVC.onAction(confirm: {[weak self] (text, _) -> (Bool)  in
            let valid = CommonService.isValidWalletPassword(text ?? "")
            if !valid.0{
                alertVC.showInputErrorTip(string: valid.1)
                return false
            }
            if self?.isInCustomLoading != nil && self?.isInCustomLoading == true{
                return false
            }
            self?.showLoadingHUD()
            WalletService.sharedInstance.exportPrivateKey(wallet: (self?.wallet!)!, password: (alertVC.textFieldInput?.text)!, completion: { (pri, err) in
                if (err == nil && (pri?.length)! > 0) {
                    self?.hideLoadingHUD()
                    switch type {
                    case .modifyWalletName:
                        self?.confirmToModifyWalletName(text!)
                    case .deleteWallet:
                        self?.confirmToDeleteWallet(text!)
                    case .exportPrivateKey:
                        self?.confirmToExportPrivateKey(text!)
                    case .exportKeystore:
                        self?.confirmToExportKeystore(text!)
                    }
                    alertVC.dismissWithCompletion()
                }else{
                    self?.hideLoadingHUD()
//                    alertVC.hideLoadingHUD()
                    alertVC.showErrorMessage(text: Localized(err?.errorDescription ?? ""), delay: 2.0)
                }
            })
            return false
            
        }) { (_, _) -> (Bool) in
            return true
        }
        
        alertVC.showInViewController(viewController: self)
    }
    
    func showErrorPswAlertFor(_ type: AlertActionType) {
        
        let alertC = PAlertController(title: Localized("alert_psw_input_error_title"), message: Localized("alert_psw_input_error_msg"))
        
        alertC.addAction(title: Localized("alert_psw_input_error_backBtn_title")) { [weak self] in
            
            self?.showInputPswAlertFor(type)
            
        }
        alertC.show(inViewController: self)
    }
    
    func confirmToModifyWalletName(_ psw: String) {
        
        verifyPassword(psw, type: .modifyWalletName) { [weak self](_) in
            
            let alertC = PAlertController(title: Localized("alert_modifyWalletName_title"), message: nil)
            alertC.addTextField()
            alertC.addAction(title: Localized("alert_cancelBtn_title")) { 
            }
            alertC.addAction(title: Localized("alert_modifyWalletName_confirmBtn_title")) {[weak self] in
                
                if  CommonService.isValidWalletName(alertC.textField!.text).0 {
                    self?.updateWalletName(alertC.textField!.text!)
                }else {
                    self!.showErrorNameAlert()
                }
                
            }
            alertC.inputVerify = { input in
                return CommonService.isValidWalletName(input).0
            }
            alertC.addActionEnableStyle(title: Localized("alert_modifyWalletName_confirmBtn_title"))
            alertC.show(inViewController: self!, animated: false)
            alertC.textField?.becomeFirstResponder()
            
        }
        
    }
    
    
    func confirmToExportPrivateKey(_ psw: String) {
        
        verifyPassword(psw, type: .exportPrivateKey) {[weak self](privateKey) in
            
            let vc = ExportPrivateKeyOrKeystoreViewController(exportType: .privateKey)
            vc.plainText = privateKey!
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    func confirmToExportKeystore(_ psw: String) {
        
        verifyPassword(psw, type: .exportKeystore) {[weak self] (_) in
            
            let vc = ExportPrivateKeyOrKeystoreViewController(exportType: .keystore)
            
            let res = WalletService.sharedInstance.exportKeystore(wallet: self!.wallet)
            
            guard let json = res.keystore else {
                self!.showMessage(text: res.error?.errorDescription ?? "")
                return
            }
            
            vc.plainText = json
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    func confirmToDeleteWallet(_ psw: String) {
        
        verifyPassword(psw, type: .deleteWallet) { [weak self](_) in
            
            // fix waiting
            AssetService.sharedInstace.balances = AssetService.sharedInstace.balances.filter { $0.addr.lowercased() != self?.wallet.address.lowercased() }
            WalletService.sharedInstance.deleteWallet(self!.wallet)
            self?.navigationController?.popViewController(animated: true)
            NotificationCenter.default.post(name: Notification.Name.ATON.updateWalletList, object: nil)
        }
    }
    
    func confirmToDeleteObserverWallet() {
        
        AssetService.sharedInstace.balances = AssetService.sharedInstace.balances.filter { $0.addr.lowercased() != wallet.address.lowercased() }
        WalletService.sharedInstance.deleteWallet(wallet)
        navigationController?.popViewController(animated: true)
        NotificationCenter.default.post(name: Notification.Name.ATON.updateWalletList, object: nil)
    }
    
    func verifyPassword(_ psw: String, type: AlertActionType, completionCallback:@escaping (_ privateKey: String?) -> Void) {
        
        showLoadingHUD()
        WalletService.sharedInstance.exportPrivateKey(wallet: wallet, password: psw) { [weak self](privateKey, error) in
            
            self?.hideLoadingHUD()
            
            if error != nil {
                self?.alertPswInput = psw
                self?.showErrorPswAlertFor(type)
            }else {
                
                self?.alertPswInput = nil
                completionCallback(privateKey)
            }
            
        }
        
    }
    
}
