//
//  SWalletManagerViewController.swift
//  platonWallet
//
//  Created by matrixelement on 16/11/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class SWalletManagerViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate {
    
    var swallet : SWallet?
    
    var owners : [AddressInfo] = []
    
    @IBOutlet weak var walletAvatar: UIImageView!
    
    @IBOutlet weak var walletNameLabel: UILabel!
    
    @IBOutlet weak var walletAddressLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var ownerNameLabel: UILabel!
    
    @IBOutlet weak var ownerAddressLabel: UILabel!
    
    var alertPswInput: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.registerCell(cellTypes: [SharedWalletMemberCell.self])
        navigationItem.localizedText = "SharedWalletVC_title"
        updateUI()
        
        self.reloadDataSource()
        
    }
    
    func reloadDataSource(){
        owners.removeAll()
        for item in swallet!.owners{
            /*
            if item.walletAddress?.lowercased() == swallet?.walletAddress.lowercased(){
                continue
            }
             */
            owners.append(item)
        }
        
        owners.sort { (a, b) -> Bool in
            if (a.walletAddress?.ishexStringEqual(other: swallet?.walletAddress))!{
                return true
            }
            return false
        }
        tableView.reloadData()
    }
    
    func updateUI(){
        
        walletNameLabel.text = swallet?.name
        walletAddressLabel.text = swallet?.contractAddress
        
        let wallet = SWalletService.sharedInstance.getATPWalletByAddress(address: (swallet?.walletAddress)!)
        ownerNameLabel.text = wallet?.name
        ownerAddressLabel.text = swallet?.walletAddress
        
        walletAvatar.image = UIImage(named: (swallet?.contractAddress.walletRandomAvatar())!)?.circleImage()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return owners.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SharedWalletMemberCell.self)) as! SharedWalletMemberCell
        let addrinfo = owners[indexPath.row]
        cell.updateData(info: addrinfo)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let alertC = PAlertController(title: Localized("alert_modifyWalletName_title"), message: nil)
        alertC.addTextField()
        alertC.addAction(title: Localized("alert_cancelBtn_title")) {
        }
        alertC.addAction(title: Localized("alert_modifyWalletName_confirmBtn_title")) {[weak self] in
            
            if  CommonService.isValidWalletName(alertC.textField!.text).0 {
                self?.updateOwnerName(name: alertC.textField!.text!, index: indexPath.row)
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
    
    func updateOwnerName(name : String, index : Int){
        let addrInfo = owners[index]
        RealmInstance?.beginWrite()
        addrInfo.walletName = name
        try? RealmInstance?.commitWrite()
        self.reloadDataSource()
    }
    
    func updateWalletName(name : String){
        RealmInstance?.beginWrite()
        swallet?.name = name
        try? RealmInstance?.commitWrite()
        updateUI()
    }
    
    func showErrorNameAlert() {
        let alertC = PAlertController(title: Localized("alert_modifyWalletName_error_title"), message: Localized("alert_modifyWalletName_error_msg"))
        alertC.addAction(title: Localized("alert_modifyWalletName_error_backBtn_title")) {
        }
        alertC.show(inViewController: self)
    }
    
    @IBAction func onTableHeaderButton(_ sender: Any) {
        
        let alertC = PAlertController(title: Localized("alert_modifyWalletName_title"), message: nil)
        alertC.addTextField()
        alertC.addAction(title: Localized("alert_cancelBtn_title")) {
        }
        alertC.addAction(title: Localized("alert_modifyWalletName_confirmBtn_title")) {[weak self] in
            if  CommonService.isValidWalletName(alertC.textField!.text).0 {
                self?.updateWalletName(name: alertC.textField!.text!)
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
    
    @IBAction func onDeleteSharedWallet(_ sender: Any) {
        if (self.swallet?.isWatchAccount)!{
            self.doDelete()
        }else{
            showInputPswAlertFor()
        }
        
    }
    
    
    func showInputPswAlertFor() {
        
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
            
            self?.confirmToDeleteWallet(input)
        }
        alertC.inputVerify = { input in
            return CommonService.isValidWalletPassword(input).0
        }
        alertC.addActionEnableStyle(title: Localized("alert_confirmBtn_title"))
        alertC.show(inViewController: self, animated: false)
        alertC.textField?.becomeFirstResponder()
        
    }
    
    func confirmToDeleteWallet(_ psw: String) {
        
        verifyPassword(psw, type: .deleteWallet) { [weak self](_) in
            self?.doDelete()
        }
        
    }
    
    
    func showErrorPswAlertFor(_ type: AlertActionType) {
        
        let alertC = PAlertController(title: Localized("alert_psw_input_error_title"), message: Localized("alert_psw_input_error_msg"))
        
        alertC.addAction(title: Localized("alert_psw_input_error_backBtn_title")) { [weak self] in
            
            self?.showInputPswAlertFor()
            
        }
        alertC.show(inViewController: self)
    }
    
    func verifyPassword(_ psw: String, type: AlertActionType, completionCallback:@escaping (_ privateKey: String?) -> Void) {
        
        showLoading()
        let wallet = SWalletService.sharedInstance.getATPWalletByAddress(address: (swallet?.walletAddress)!)
        WalletService.sharedInstance.exportPrivateKey(wallet: wallet!, password: psw) { [weak self](privateKey, error) in
            
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
    
    func doDelete(){
        SWalletService.sharedInstance.deleteWallet(swallet: self.swallet!)
        self.navigationController?.popViewController(animated: true)
    }
}
