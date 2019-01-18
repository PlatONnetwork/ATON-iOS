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


    
    @IBOutlet weak var walletIcon: UIImageView!
    @IBOutlet weak var walletName: UILabel!
    @IBOutlet weak var address: UILabel!
    
    @IBOutlet weak var deleteBtn: PButton!
    
    var wallet: Wallet!
    
    var alertPswInput: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
       setupUI()
    }
    
    func setupUI() {
        navigationItem.localizedText = "WalletManagerDetailVC_title"
        deleteBtn.style = .alert
        walletName.text = wallet.name
        address.text = wallet.key?.address ?? ""
        walletIcon.image = UIImage(named: wallet.avatar)?.circleImage()
        
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
    
    @IBAction func modifyWalletName(_ sender: Any) {
        let alertC = PAlertController(title: Localized("alert_modifyWalletName_title"), message: nil)
        alertC.addTextField() 
        alertC.addAction(title: Localized("alert_cancelBtn_title")) {
        }
        alertC.addAction(title: Localized("alert_modifyWalletName_confirmBtn_title")) {[weak self] in
            
            if  CommonService.isValidWalletName(alertC.textField!.text).0 {
                self?.updateWalletName(alertC.textField!.text!)
                alertC.dismiss(animated: true, completion: nil)
            }else {
                self!.showErrorNameAlert()
            }
        }
        alertC.inputVerify = { input in
            return CommonService.isValidWalletName(input).0
        }
        alertC.addActionEnableStyle(title: Localized("alert_modifyWalletName_confirmBtn_title"))
        alertC.show(inViewController: self, animated: false)
        alertC.textField?.becomeFirstResponder()
        
    }
    
    func updateWalletName(_ name:String) {
        
        WalletService.sharedInstance.updateWalletName(wallet, name: name)
        walletName.text = name
    }
    
    func showErrorNameAlert() {
        
        let alertC = PAlertController(title: Localized("alert_modifyWalletName_error_title"), message: Localized("alert_modifyWalletName_error_msg"))
        alertC.addAction(title: Localized("alert_modifyWalletName_error_backBtn_title")) { 
        }
        alertC.show(inViewController: self)
        
    }
    
    func showInputPswAlertFor(_ type: AlertActionType) {
        
        let alertC = PAlertController(title: Localized("alert_input_psw_title"), message: nil)
        alertC.addTextField(text: alertPswInput, placeholder: "", isSecureTextEntry: true)
        alertC.addAction(title: Localized("alert_cancelBtn_title")) {[weak self] in
            self?.alertPswInput = nil
        }
        alertC.addAction(title: Localized("alert_confirmBtn_title")) { [weak self] in
            
            let input = alertC.textField?.text ?? ""
            if !CommonService.isValidWalletPassword(alertC.textField?.text ?? "").0{
                return
            }
            alertC.dismiss(animated: true, completion: nil)
            switch type {
            case .modifyWalletName:
                self?.confirmToModifyWalletName(input)
            case .deleteWallet:
                self?.confirmToDeleteWallet(input)
            case .exportPrivateKey:
                self?.confirmToExportPrivateKey(input)
            case .exportKeystore:
                self?.confirmToExportKeystore(input)
            }
            
        }
        alertC.inputVerify = { input in
            return CommonService.isValidWalletPassword(input).0
        }
        alertC.addActionEnableStyle(title: Localized("alert_confirmBtn_title"))
        alertC.show(inViewController: self, animated: false)
        alertC.textField?.becomeFirstResponder() 
        
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
            AssetService.sharedInstace.assets.removeValue(forKey: (self?.wallet.key?.address)!)
            WalletService.sharedInstance.deleteWallet(self!.wallet)
            self?.navigationController?.popViewController(animated: true)
        }
        
    }
    
    func verifyPassword(_ psw: String, type: AlertActionType, completionCallback:@escaping (_ privateKey: String?) -> Void) {
        
        showLoading()
        WalletService.sharedInstance.exportPrivateKey(wallet: wallet, password: psw) { [weak self](privateKey, error) in
            
            self?.hideLoading()
            
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
