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
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var ownerNameLabel: UILabel!
    
    @IBOutlet weak var ownerAddressLabel: UILabel!
    
    @IBOutlet weak var walletName: UILabel!
    
    var alertPswInput: String?
    
    
    @IBOutlet weak var deleteButton: PButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.registerCell(cellTypes: [SharedWalletMemberCell.self])

        updateUI()
        
        self.reloadDataSource()
        
    }
    
    func reloadDataSource(){
        owners.removeAll()
        
        for item in swallet!.owners{
            if (item.walletAddress?.ishexStringEqual(other: swallet?.walletAddress))!{
                continue
            }
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
        if (swallet?.isWatchAccount)!{
            self.ownerNameLabel.text = Localized("sharedWalletDefaltMemberName") + String(1)
        }else{
            self.ownerNameLabel.text = swallet?.name
        }
        
        let wallet = SWalletService.sharedInstance.getATPWalletByAddress(address: (swallet?.walletAddress)!)
        ownerNameLabel.text = wallet?.name
        ownerAddressLabel.text = swallet?.walletAddress.addressForDisplay()
        
        super.leftNavigationTitle = swallet?.name
        walletName.text = swallet?.name
        if let label = self.titleLabel{
            label.text = swallet?.name
        }
        
        self.deleteButton.style = .delete
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

        self.showCommonRenameInput(completion: {[weak self] (text) in
            self?.updateOwnerName(name: text!, index: indexPath.row)
        }, checkDuplicate: false)
        
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
    
  
    
    //MARK: - User Interaction
    
    @IBAction func onDeleteSharedWallet(_ sender: Any) {
        if (self.swallet?.isWatchAccount)!{
            self.doDelete()
        }else{
            showInputPswAlertFor()
        }
    } 
    
    func showInputPswAlertFor() {
        let alertVC = AlertStylePopViewController.initFromNib()
        alertVC.style = PAlertStyle.passwordInput(walletName: self.swallet?.name)
        alertVC.onAction(confirm: {[weak self] (text, _) -> (Bool)  in
            let valid = CommonService.isValidWalletPassword(text ?? "")
            if !valid.0{
                alertVC.showInputErrorTip(string: valid.1)
                return false
            }
            self?.showLoadingHUD()
            WalletService.sharedInstance.exportPrivateKey(wallet: (self?.swallet?.ownerWallet()!)!, password: (alertVC.textFieldInput?.text)!, completion: { (pri, err) in
                self?.hideLoadingHUD()
                if (err == nil && (pri?.length)! > 0) {
                    self?.doDelete()
                    alertVC.dismissWithCompletion()
                }else{
                    alertVC.showInputErrorTip(string: Localized((err?.errorDescription)!))
                }
            }) 
            return false
            
        }) { (_, _) -> (Bool) in
            return true
        }
        
        alertVC.showInViewController(viewController: self)
    }

       
    func doDelete(){
        SWalletService.sharedInstance.deleteWallet(swallet: self.swallet!)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func onRename(_ sender: Any) {
        self.showCommonRenameInput(completion: { [weak self] text in
            self?.updateWalletName(name: text!)
        }, checkDuplicate: true)
    }
}
