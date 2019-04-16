//
//  AddSharedWalletVC.swift
//  platonWallet
//
//  Created by matrixelement on 20/11/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift
import SnapKit

class AddSharedWalletVC: BaseViewController, UITextFieldDelegate {

    @IBOutlet weak var walletName: PTextFieldWithPadding!
    
    @IBOutlet weak var walletNameTip: UILabel!
    @IBOutlet weak var walletAddress: UILabel!
    
    @IBOutlet weak var chooseWalletBtn: UIButton!
    
    @IBOutlet weak var contractAddressField: PTextFieldWithPadding!
    
    @IBOutlet weak var contractAddrTip: UILabel!
    
    @IBOutlet weak var addressBookBtn: UIButton!
    
    @IBOutlet weak var chooseWalletName: UILabel!
    
    @IBOutlet weak var walletAvatar: UIImageView!
    
    @IBOutlet weak var confirmButton: PButton!
    
    @IBOutlet weak var topToWalletTextField: NSLayoutConstraint!
    
    @IBOutlet weak var topToWalletTipView: NSLayoutConstraint!
    
    
    
    
    
    var selectedAddress : String?
    
    var selectedWallet : Wallet?{ 
        didSet{
            self.selectedAddress = selectedWallet?.key?.address
            self.walletAddress.text = selectedWallet?.key?.address
            self.chooseWalletName.text = selectedWallet?.name
            self.walletAvatar.image = selectedWallet?.image()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        walletName.delegate = self
        contractAddressField.delegate = self
        contractAddrTip.isHidden = true
        walletNameTip.isHidden = true
        
        super.leftNavigationTitle = "AddSharedWalletVC_title"
        initSubViews()
        initNavigationItem()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        var wallets = AssetVCSharedData.sharedData.walletList.filterClassicWallet
        wallets.userArrangementSort()
        if wallets.count > 0{
            for item in wallets{
                if item.WalletBalanceStatus() == BalanceStatus.Sufficient{
                    selectedWallet = item
                    break
                }
            }
            if selectedWallet == nil{
                selectedWallet = WalletService.sharedInstance.wallets[0]
            }
            
        }else{
            self.navigationController?.popViewController(animated: true)
            UIApplication.rootViewController().showMessage(text: Localized("create_Individual_first"))
            return
        }
        self.confirmButton.style = .disable
    }
    
    @objc func onTap() {
        if walletName.isFirstResponder{
            walletName.resignFirstResponder()
        }
        if contractAddressField.isFirstResponder{
            contractAddressField.resignFirstResponder()
        }
    }
    
    func initSubViews() {

        let chooseWalletImgView = UIImageView(image: UIImage(named: "chooseWallet"))
        chooseWalletBtn.addSubview(chooseWalletImgView)
        chooseWalletImgView.snp.makeConstraints { (make) in
            make.leading.equalTo(chooseWalletBtn).offset(2)
            make.size.equalTo(CGSize(width: 16, height: 16))
            make.centerY.equalTo(chooseWalletBtn)
        }
        
        let Label = UILabel()
        Label.localizedText = "AddSharedWalletVC_Change"
        Label.textColor = UIColor(rgb: 0x1b2137)
        Label.font = UIFont.systemFont(ofSize: 14)
        chooseWalletBtn.addSubview(Label)
        Label.snp.makeConstraints { (make) in
            make.leading.equalTo(chooseWalletImgView.snp_leadingMargin).offset(10)
            make.centerY.equalTo(chooseWalletBtn)
            make.trailing.equalTo(chooseWalletBtn)
        }
         
        contractAddressField.bottomSeplineView?.snp.updateConstraints { (make) in
            make.trailing.equalTo(5+30+30)
        }
    }
    
    func checkWalletNameValidation(showErrorMsg: Bool = false) -> Bool {
        let nameRes = CommonService.isValidWalletName(walletName.text,checkDuplicate: true)
        
        if showErrorMsg{
            if nameRes.0 { 
                walletNameTip.isHidden = true
                self.topToWalletTipView.priority = UILayoutPriority(rawValue: 998)
                self.topToWalletTextField.priority = UILayoutPriority(rawValue: 999)
                self.walletName.setBottomLineStyle(style: .Normal)
            }else {
                walletNameTip.text = nameRes.1 ?? ""
                walletNameTip.isHidden = false
                self.topToWalletTipView.priority = UILayoutPriority(rawValue: 999)
                self.topToWalletTextField.priority = UILayoutPriority(rawValue: 998)
                self.walletName.setBottomLineStyle(style: .Error)
            }
            self.view.layoutIfNeeded() 
        }
        
        return nameRes.0
    }
    
    func checkContractValidation(showErrorMsg: Bool = false) -> Bool{
        let nameRes = CommonService.isValidContractAddress(contractAddressField.text)
        if showErrorMsg{
            
            if nameRes.0 {
                contractAddrTip.isHidden = true
                self.contractAddressField.setBottomLineStyle(style: .Normal)
            }else {
                contractAddrTip.text = nameRes.1 ?? ""
                contractAddrTip.isHidden = false
                self.contractAddressField.setBottomLineStyle(style: .Error)
            }
            self.view.layoutIfNeeded()
        }
        
        return nameRes.0
    }
    


    func initNavigationItem(){
        /*
        let scanButton = UIButton(type: .custom)
        scanButton.setImage(UIImage(named: "navScanBlack"), for: .normal)
        scanButton.addTarget(self, action: #selector(onNavRight), for: .touchUpInside)
        scanButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        let rightBarButtonItem = UIBarButtonItem(customView: scanButton)
        navigationItem.rightBarButtonItem = rightBarButtonItem
         */
    }
    
    // MARK: - Button Actions
    
    @IBAction func onSwitchWallet(_ sender: Any) {
        
        let popUpVC = PopUpViewController()
        let view = UIView.viewFromXib(theClass: TransferSwitchWallet.self) as! TransferSwitchWallet
        view.selectedAddress = selectedAddress
        view.checkBalance = false
        popUpVC.setUpContentView(view: view, size: CGSize(width: PopUpContentWidth, height: 289))
        popUpVC.setCloseEvent(button: view.closeBtn)
        view.selectionCompletion = { wallet in
            popUpVC.onDismissViewController()
            self.selectedWallet = wallet as? Wallet 
        }
        popUpVC.show(inViewController: self)
        
    }
    
    
    @objc func onNavRight(){
 
    }
    
    
    @IBAction func onScan(_ sender: Any) {
        let scanner = QRScannerViewController()
        scanner.hidesBottomBarWhenPushed = true
        scanner.scanCompletion = {[weak self] result in
            if result.is40ByteAddress(){
                self?.contractAddressField.text = result
                self?.keyboardWillHide()
                let _  = self?.checkContractValidation()
            }else{
                self?.showMessage(text: Localized("QRScan_failed_tips"))
            }
            self?.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(scanner, animated: true)
    }
    
    @IBAction func onAddressBook(_ sender: Any) {
        let addressBookVC = AddressBookViewController()
        addressBookVC.selectionCompletion = { [weak self](_ addressInfo : AddressInfo?) -> () in
            if let weakSelf = self{
                weakSelf.contractAddressField.text = addressInfo?.walletAddress
                let _  = self?.checkContractValidation()
            }
        }
        navigationController?.pushViewController(addressBookVC, animated: true)
    }
    
    
    @IBAction func onConfirm(_ sender: Any) {
        
        if !self.checkConfirmButtonEnable(){
            return 
        }
        
        if SWalletService.sharedInstance.getSWalletByContractAddress(contractAddress: contractAddressField.text!) != nil{
            self.showMessage(text: Localized("sharedWallet_sharedWallet_existed"))
            return
        }
        
        self.showLoadingHUD()
        SWalletService.sharedInstance.addShardWallet(contractAddress: self.contractAddressField.text!, sender: (selectedWallet?.key?.address)!, name: self.walletName.text!, walletAddress: (selectedWallet?.key?.address)!) { (result, data) in
            self.hideLoadingHUD()
            switch result{
                
            case .success:
                do{
                    self.navigationController?.popToRootViewController(animated: true)
                }
            case .fail(let code, let errMsg):
                self.showMessageWithCodeAndMsg(code: code!, text: errMsg!, delay: 2.5)
            }
        }
    }
    
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == walletName {
            let _ = checkWalletNameValidation(showErrorMsg: true)
        }else if textField == contractAddressField {
            let _ = checkContractValidation(showErrorMsg: true)
        }
        let _ = self.checkConfirmButtonEnable()
    }
    
    
    
    @objc func keyboardWillHide(){
        
    }
    
    func checkConfirmButtonEnable() -> Bool{
        if checkWalletNameValidation() && checkContractValidation(){
            self.confirmButton.style = .blue
            return true
        }else{
            self.confirmButton.style = .disable
            return false
        }
    }
    
}
