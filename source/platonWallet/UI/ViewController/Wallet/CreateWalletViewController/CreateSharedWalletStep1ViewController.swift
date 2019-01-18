//
//  CreateSharedWalletStep1ViewController.swift
//  platonWallet
//
//  Created by matrixelement on 2018/11/13.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift

let defaultOwnerNumber = "2"

class CreateSharedWalletStep1ViewController: BaseViewController {
    
    @IBOutlet weak var nameTF: PTextFieldWithPadding!
    
    @IBOutlet weak var nameTipsLabel: UILabel!
    
    @IBOutlet weak var walletInfoContainerView: UIView!
    
    @IBOutlet weak var walletNameLabel: UILabel!
    
    @IBOutlet weak var walletAddrLabel: UILabel!
    
    @IBOutlet weak var chooseWalletBtn: UIButton!
    
    @IBOutlet weak var numOfOwnerLabel: UILabel!
    
    @IBOutlet weak var numOfSignLabel: UILabel!
    
    @IBOutlet weak var nextBtn: PButton!
    
    @IBOutlet weak var showNameTipsLayout: NSLayoutConstraint!
    
    var selectedAddress : String?
    
    var selectedWallet: Wallet! {
        didSet {
            walletNameLabel.text = selectedWallet.name
            walletAddrLabel.text = selectedWallet.key?.address
            selectedAddress = selectedWallet.key?.address
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        if WalletService.sharedInstance.wallets.count > 0{
            selectedWallet = WalletService.sharedInstance.wallets[0]
        }else{
            self.navigationController?.popViewController(animated: true)
            UIApplication.rootViewController().showMessage(text: Localized("create_Individual_first"))
            return
        }
        
        var allWalletssInsufficient = true
        for item in WalletService.sharedInstance.wallets{
            if let b = AssetService.sharedInstace.assets[(item.key?.address)!],String((b?.balance)!) != "0"{
                allWalletssInsufficient = false
            }
        }
        
        if allWalletssInsufficient{
            self.navigationController?.popViewController(animated: true)
            UIApplication.rootViewController().showMessage(text: Localized("SharedWallet_create_with_insufficient_balance"))
            return
        }
        
        self.numOfOwnerLabel.text = defaultOwnerNumber
    }
    
    func setupUI() {
        
        title = Localized("CreateSharedWalletVC_Create Shared Wallet")
        
        endEditingWhileTapBackgroundView = true
        walletInfoContainerView.layer.cornerRadius = 5.0
        walletInfoContainerView.layer.masksToBounds = true
        
        nextBtn.isEnabled = false
        
        chooseWalletBtn.setupSwitchWalletStyle()
    }
    
    func checkNameTF() -> Bool {
        let nameRes = CommonService.isValidWalletName(nameTF.text)
        
        if nameRes.0 {
            nameTipsLabel.isHidden = true
            showNameTipsLayout.priority = .defaultLow
        }else {
            nameTipsLabel.text = nameRes.1 ?? ""
            nameTipsLabel.isHidden = false
            showNameTipsLayout.priority = .defaultHigh
        }
        self.view.layoutIfNeeded()
        return nameRes.0
    }
    
    func checkCanEnableNextBtn() {
        nextBtn.isEnabled = nameTF.text!.length > 0
    }
    
    //MARK: Click Handler
    @IBAction func changeWallet(_ sender: Any) {

        let popUpVC = PopUpViewController()
        let view = UIView.viewFromXib(theClass: TransferSwitchWallet.self) as! TransferSwitchWallet
        view.selectedAddress = selectedAddress
        popUpVC.setUpContentView(view: view, size: CGSize(width: kUIScreenWidth, height: 289))
        popUpVC.setCloseEvent(button: view.closeBtn)
        view.selectionCompletion = { wallet in
            popUpVC.onDismissViewController()
            self.selectedWallet = wallet as! Wallet
        }
        popUpVC.show(inViewController: self)
        
    }
    
    @IBAction func selectNumOfOwner(_ sender: Any) {
        
        view.endEditing(true)
        
        var dataSource = [String]()
        for i in 2...10 {
            dataSource.append("\(i)")
        }
        
        CustomPickerView.show(inViewController: self, dataSource: dataSource, curSelected: numOfOwnerLabel.text) { (selected) in
            self.numOfOwnerLabel.text = selected
            if Int(self.numOfSignLabel.text!)! > Int(self.numOfOwnerLabel.text!)! {
                self.numOfSignLabel.text = selected
            }
        }
        
    }
    
    @IBAction func selectNumOfSign(_ sender: Any) {
        
        view.endEditing(true)
        
        var dataSource = [String]()
        let max = Int(numOfOwnerLabel.text!)!
        //let min = Int(self.numOfOwnerLabel.text!)!
        for i in 2...max {
            dataSource.append("\(i)")
        }
        
        CustomPickerView.show(inViewController: self, dataSource: dataSource, curSelected: numOfSignLabel.text) { (selected) in
            self.numOfSignLabel.text = selected
        }
        
    }
    
    
    @IBAction func next(_ sender: Any) {
        
        view.endEditing(true)
        
        guard checkNameTF() else {
            return
        }
        let vc = CreateSharedWalletStep2ViewController()
        vc.numOfMembers = Int(numOfOwnerLabel.text!)!
        vc.signRequired = Int(self.numOfSignLabel.text!)!
        vc.wallet = self.selectedWallet
        vc.sharedWalletName = self.nameTF.text!
        navigationController?.pushViewController(vc, animated: true) 
        
    }
    
}

extension CreateSharedWalletStep1ViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == nameTF {
            let _ = checkNameTF()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) { 
            self.checkCanEnableNextBtn()
        }
        
        return true
    }
    
}
