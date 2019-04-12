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
    
    @IBOutlet weak var walletAvatar: UIImageView!
    
    @IBOutlet weak var nextBtn: PButton!
    
    @IBOutlet weak var showNameTipsLayout: NSLayoutConstraint!
    
    var selectedAddress : String?
    
    var selectedWallet: Wallet! {
        didSet {
            walletNameLabel.text = selectedWallet.name
            walletAddrLabel.text = selectedWallet.key?.address
            selectedAddress = selectedWallet.key?.address
            self.walletAvatar.image = selectedWallet.image()
        }
    } 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        if WalletService.sharedInstance.wallets.count > 0{
            var wallets = AssetVCSharedData.sharedData.walletList.filterClassicWallet
            wallets.userArrangementSort()
            selectedWallet = wallets.first
            for item in wallets{
                if let b = AssetService.sharedInstace.assets[(item.key?.address)!],String((b?.balance)!) != "0"{
                    selectedWallet = item
                    break
                }
            }

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
        
        super.leftNavigationTitle = "CreateSharedWalletVC_Create Shared Wallet"
        
        endEditingWhileTapBackgroundView = true
        walletInfoContainerView.layer.cornerRadius = 5.0
        walletInfoContainerView.layer.masksToBounds = true
        
        nextBtn.style = .disable
        
        chooseWalletBtn.setupSwitchWalletStyle()
        
        let _ = self.checkButtonEnable()
    }
    
    func checkNameTF(showError: Bool = true) -> Bool {
        let nameRes = CommonService.isValidWalletName(nameTF.text,checkDuplicate: true)
        if showError{
            if nameRes.0 {
                nameTipsLabel.isHidden = true
                showNameTipsLayout.priority = .defaultLow
                nameTF.setBottomLineStyle(style: .Normal)
            }else {
                nameTipsLabel.text = nameRes.1 ?? ""
                nameTipsLabel.isHidden = false
                showNameTipsLayout.priority = .defaultHigh
                nameTF.setBottomLineStyle(style: .Error)
            }
            self.view.layoutIfNeeded()
        }
        
        return nameRes.0 
    }
    
    
    //MARK: Click Handler
    @IBAction func changeWallet(_ sender: Any) {

        let popUpVC = PopUpViewController()
        let view = UIView.viewFromXib(theClass: TransferSwitchWallet.self) as! TransferSwitchWallet
        view.selectedAddress = selectedAddress
        popUpVC.setUpContentView(view: view, size: CGSize(width: PopUpContentWidth, height: 265))
        popUpVC.setCloseEvent(button: view.closeBtn)
        view.selectionCompletion = { wallet in
            popUpVC.onDismissViewController()
            self.selectedWallet = wallet as? Wallet
        }
        popUpVC.show(inViewController: self)
        
    }
    
    @IBAction func selectNumOfOwner(_ sender: Any) {
        
        view.endEditing(true) 
        
        var dataSource = [String]()
        for i in 2...8 {
            dataSource.append("\(i)")
        }
        
        CustomPickerView.show(inViewController: self, dataSource: dataSource, curSelected: numOfOwnerLabel.text,title: Localized("CreateSharedWalletVC_Shared Owners")) { (selected) in
            self.numOfOwnerLabel.text = selected
            if Int(self.numOfSignLabel.text!)! > Int(self.numOfOwnerLabel.text!)! {
                self.numOfSignLabel.text = selected
            }
        }
        let _ = self.checkButtonEnable()
        
    }
    
    @IBAction func selectNumOfSign(_ sender: Any) {
        
        view.endEditing(true)
        
        var dataSource = [String]()
        let max = Int(numOfOwnerLabel.text!)!
        //let min = Int(self.numOfOwnerLabel.text!)!
        for i in 2...max {
            dataSource.append("\(i)")
        }
        
        CustomPickerView.show(inViewController: self, dataSource: dataSource, curSelected: numOfSignLabel.text,title: Localized("CreateSharedWalletVC_Required Signatures")) { (selected) in
            self.numOfSignLabel.text = selected
        }
        let _ = self.checkButtonEnable()
        
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
    
    func checkButtonEnable() -> Bool{
        if self.numOfSignLabel.text != "0" &&
            self.numOfSignLabel.text != "0" &&
            checkNameTF(showError: false)
        {
            //self.nextBtn.setHorizontalLinerTitleAndImage(image: UIImage(named: "nextBtnIcon")!)
            self.nextBtn.style = .blue
            return true
        }
        //self.nextBtn.setHorizontalLinerTitleAndImage(image: UIImage(named: "nextBtnIconDisable")!)
        self.nextBtn.style = .disable
        return false
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
            let _ = self.checkButtonEnable()
        }
        
        return true
    }
    
}
