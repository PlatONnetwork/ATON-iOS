//
//  UIViewController+Extenstions.swift
//  platonWallet
//
//  Created by matrixelement on 2018/10/23.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import MBProgressHUD
import Localize_Swift


private var VCIsLoadingAssociatedKey: UInt8 = 3

private let swizzling: (UIViewController.Type) -> () = { viewController in
    
    let originalSelector = #selector(viewController.viewWillAppear(_:))
    let swizzledSelector = #selector(viewController.proj_viewWillAppear(animated:))
    
    let originalMethod = class_getInstanceMethod(viewController, originalSelector)
    let swizzledMethod = class_getInstanceMethod(viewController, swizzledSelector)
    
    method_exchangeImplementations(originalMethod!, swizzledMethod!)
}

extension UIViewController {
    
    open class func doBadSwizzleStuff() {
        guard self === UIViewController.self else { return }
        swizzling(self)
    }
    
    @objc func proj_viewWillAppear(animated: Bool) {
        self.proj_viewWillAppear(animated: animated)
        
        let viewControllerName = NSStringFromClass(type(of: self))
        CustomLoading.viewWillAppear()
        
        guard isInCustomLoading != nil else{
            return
        }
        if self.isInCustomLoading!{
            CustomLoading.viewWillAppear()
        }
    }
    
    public var isInCustomLoading: Bool? {
        get {
            return objc_getAssociatedObject(self, &VCIsLoadingAssociatedKey) as? Bool
        }
        set(newValue) {
            objc_setAssociatedObject(self, &VCIsLoadingAssociatedKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}

extension UIViewController {
     
    func showLoadingHUD(text: String = Localized("loading") ,animated: Bool = true) {
        self.isInCustomLoading = true
        CustomLoading.startLoading(viewController: self)
        //return
        /*
        DispatchQueue.main.async {
            let hud = MBProgressHUD.showAdded(to: self.view, animated: animated)
            hud.label.text = text
        }*/
    }
    
    func hideLoadingHUD(animated: Bool = true,delay: Double = 0) {
        if delay == 0{
            self.isInCustomLoading = false
            CustomLoading.hideLoading(viewController: self)
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { 
                self.isInCustomLoading = false
                CustomLoading.hideLoading(viewController: self)
            }        
        }
    }
    
    func showMessage(text: String, delay: TimeInterval = 0.8) {
        let view = UIApplication.shared.keyWindow?.rootViewController?.view
        DispatchQueue.main.async {
            let hud = MBProgressHUD.showAdded(to: view!, animated: true)
            hud.mode = .text
            //hud.label.text = text
            hud.detailsLabel.text = text
            hud.hide(animated: true, afterDelay: delay)
        }
    }
    
    
    
    func showMessageWithCodeAndMsg(code: Int, text: String, delay:TimeInterval = 1.2) {
        
        DispatchQueue.main.async {
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.mode = .text
            //hud.label.text = text
            
            if let msg = self.messageWithCode(code: code){
                hud.detailsLabel.text = msg
            }else{
                hud.detailsLabel.text = text
            }
            
            hud.hide(animated: true, afterDelay: delay)
        }
        
    }

    
    func messageWithCode(code: Int) -> String?{
        if code == -111{
            return Localized("transferVC_Insufficient_balance")
        }
        return nil
    }
    
    //MARK: - common Alert style pop up view utilities
    
    func showWalletBackup(wallet: Wallet){
        let alertVC = AlertStylePopViewController.initFromNib()
        let style = PAlertStyle.passwordInput(walletName: wallet.name)
        
        alertVC.onAction(confirm: {[weak self] (text, _) -> (Bool)  in
            let valid = CommonService.isValidWalletPassword(text ?? "")
            if !valid.0{
                alertVC.showInputErrorTip(string: valid.1)
                return false
            }
            WalletService.sharedInstance.exportMnemonic(wallet: wallet, password: text!, completion: { (res, error) in
                if (error == nil && (res!.length) > 0) {
                    let vc = BackupMnemonicViewController()
                    vc.mnemonic = res
                    vc.walletAddress = wallet.key?.address
                    vc.view.backgroundColor = .white
                    vc.hidesBottomBarWhenPushed = true
                    self?.rt_navigationController!.pushViewController(vc, animated: true)
                    alertVC.dismissWithCompletion()
                }else{
                    alertVC.showInputErrorTip(string: error?.errorDescription)
                }
            })
            return false
            
        }) { (_, _) -> (Bool) in
            return true
        }
        alertVC.style = style
        alertVC.showInViewController(viewController: self)   
    }
    
    func showCommonRenameInput(completion: ((_ text: String?) -> ())?,checkDuplicate: Bool = false){
        let alertVC = AlertStylePopViewController.initFromNib()
        let style = PAlertStyle.commonInput(title: "alert_modifyWalletName_title", placeHoder: "Wallet name", preInputText: "")
        alertVC.textFieldInput.checkInput(mode: CheckMode.textChange, check: { (input) -> (Bool, String) in
            let ret = CommonService.isValidWalletName(input,checkDuplicate: true)
            return (ret.0,ret.1 ?? "")
        }) { textField in
            
        }
        alertVC.onAction(confirm: {(text, _) -> (Bool) in
            
            let ret = CommonService.isValidWalletName(text,checkDuplicate: checkDuplicate)
            if ret.0{
                if let completion = completion{
                    completion(text)
                }
                return true 
            }else{
                alertVC.showInputErrorTip(string: ret.1)
                return false
            }
        }) { (_, _) -> (Bool) in
            return true
        }
        alertVC.style = style
        alertVC.showInViewController(viewController: self)
    }
    
    func showAlertWithRedTitle(localizedTitle: String?,localizedMessage: String?,localizedConfirmButton: String = "alert_screenshot_ban_confirmBtn_title"){
        let alertVC = AlertStylePopViewController.initFromNib()
        alertVC.style = PAlertStyle.AlertWithRedTitle(title: localizedTitle, message: localizedMessage)
        alertVC.confirmButton.localizedNormalTitle = localizedConfirmButton
        alertVC.onAction(confirm: { (text, _) -> (Bool) in
            return true
        }) { (_, _) -> (Bool) in
            return true
        }
        alertVC.showInViewController(viewController: self)
    }
    
    
    func afterBackupRouter(){
        
        let obj = self.navigationController?.viewControllers.filter({ vc -> Bool in
            //!!! WalletManagerDetailViewController is in front of WalletListViewController
            if type(of: vc) == AssetViewControllerV060.self ||
                type(of: vc) == WalletManagerDetailViewController.self ||
                type(of: vc) == WalletListViewController.self{
                return true
            }
            return false
        })
        
        if (obj?.count)! > 0{
            let walletmanagervc = obj?.filter({ (vc) -> Bool in
                if type(of: vc) == WalletManagerDetailViewController.self{
                    return true
                }
                return false
            })
            if (walletmanagervc?.count)! > 0{
                self.navigationController?.popToViewController((walletmanagervc?.first)!, animated: true)
            }else{
                self.navigationController?.popToViewController((obj?.first)!, animated: true)
            }
            
        }else{
            (UIApplication.shared.delegate as? AppDelegate)?.gotoMainTab()
        }
    }
}

extension UIViewController {
    func showPasswordInputPswAlert(for wallet: Wallet, completion: ((_ privateKey: String?) -> Void)?) {
        
        let alertVC = AlertStylePopViewController.initFromNib()
        let style = PAlertStyle.passwordInput(walletName: wallet.name)
        alertVC.onAction(confirm: { [weak self] (text, _) -> (Bool)  in
            let valid = CommonService.isValidWalletPassword(text ?? "")
            if !valid.0{
                alertVC.showInputErrorTip(string: valid.1)
                return false
            }
            
            alertVC.showLoadingHUD()
            
            WalletService.sharedInstance.exportPrivateKey(
                wallet: wallet,
                password: (alertVC.textFieldInput?.text)!, completion: { (pri, err) in
                if (err == nil && (pri?.length)! > 0) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                        AssetViewControllerV060.getInstance()?.showLoadingHUD()
                    })
                    
                    completion?(pri)
                    alertVC.dismissWithCompletion()
                }else{
                    completion?(nil)
                    alertVC.showInputErrorTip(string: (err?.errorDescription)!)
                    alertVC.hideLoadingHUD()
                }
            })
            return false
            
        }) { (_, _) -> (Bool) in
            completion?(nil)
            return true
        }
        alertVC.style = style
        alertVC.showInViewController(viewController: self)
        
        return
    }
}

