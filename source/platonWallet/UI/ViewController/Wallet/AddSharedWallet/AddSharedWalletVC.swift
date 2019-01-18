//
//  AddSharedWalletVC.swift
//  platonWallet
//
//  Created by matrixelement on 20/11/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class AddSharedWalletVC: BaseViewController, UITextFieldDelegate {

    @IBOutlet weak var walletName: PTextFieldWithPadding!
    
    @IBOutlet weak var walletNameTip: UILabel!
    @IBOutlet weak var walletAddress: UILabel!
    
    @IBOutlet weak var chooseWalletBtn: UIButton!
    
    @IBOutlet weak var contractAddressField: PTextFieldWithPadding!
    
    @IBOutlet weak var contractAddrTip: UILabel!
    @IBOutlet weak var addressBookBtn: UIButton!
    
    @IBOutlet weak var confirmButton: UIButton!
    
    @IBOutlet weak var chooseWalletName: UILabel!
    
    var selectedAddress : String?
    
    var selectedWallet : Wallet?{
        didSet{
            self.selectedAddress = selectedWallet?.key?.address
            self.walletAddress.text = selectedWallet?.key?.address
            self.chooseWalletName.text = selectedWallet?.name
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        walletName.delegate = self
        contractAddressField.delegate = self
        contractAddrTip.isHidden = true
        walletNameTip.isHidden = true
        
        navigationItem.localizedText = "AddSharedWalletVC_title"
        initSubViews()
        initNavigationItem()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        confirmButton.setCommonEanbleStyle(false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if WalletService.sharedInstance.wallets.count > 0{
            selectedWallet = WalletService.sharedInstance.wallets[0]
        }else{
            self.navigationController?.popViewController(animated: true)
            UIApplication.rootViewController().showMessage(text: Localized("create_Individual_first"))
            return
        }
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
        addressBookBtn.addMaskView(corners: [.bottomRight,.topRight], cornerRadiiV: 5)
        chooseWalletBtn.addMaskView(corners: [.bottomRight,.topRight], cornerRadiiV: 5)
        
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
        
    }
    
    func checkContractValidation() -> Bool{
        
        let nameRes = CommonService.isValidContractAddress(contractAddressField.text)
        if nameRes.0 {
            contractAddrTip.isHidden = true
        }else {
            contractAddrTip.text = nameRes.1 ?? ""
            contractAddrTip.isHidden = false
        }
        self.view.layoutIfNeeded()
        return nameRes.0
    }
    
    func checkWalletNameValidation() -> Bool {
        let nameRes = CommonService.isValidWalletName(walletName.text)
        
        if nameRes.0 {
            walletNameTip.isHidden = true
        }else {
            walletNameTip.text = nameRes.1 ?? ""
            walletNameTip.isHidden = false
        }
        self.view.layoutIfNeeded()
        return nameRes.0
    }

    func initNavigationItem(){
        let scanButton = UIButton(type: .custom)
        scanButton.setImage(UIImage(named: "navScanWhite"), for: .normal)
        scanButton.addTarget(self, action: #selector(onNavRight), for: .touchUpInside)
        scanButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        let rightBarButtonItem = UIBarButtonItem(customView: scanButton)
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    // MARK: - Button Actions
    
    @IBAction func onSwitchWallet(_ sender: Any) {
        
        let popUpVC = PopUpViewController()
        let view = UIView.viewFromXib(theClass: TransferSwitchWallet.self) as! TransferSwitchWallet
        view.selectedAddress = selectedAddress
        view.checkBalance = false
        popUpVC.setUpContentView(view: view, size: CGSize(width: kUIScreenWidth, height: 289))
        popUpVC.setCloseEvent(button: view.closeBtn)
        view.selectionCompletion = { wallet in
            popUpVC.onDismissViewController()
            self.selectedWallet = wallet as? Wallet
        }
        popUpVC.show(inViewController: self)
        
    }
    
    
    @objc func onNavRight(){
        let scanner = QRScannerViewController()
        scanner.hidesBottomBarWhenPushed = true
        scanner.scanCompletion = { result in
            if result.is40ByteAddress(){
                self.contractAddressField.text = result
                self.keyboardWillHide()
            }else{
                self.showMessage(text: Localized("QRScan_failed_tips"))
            }
            self.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(scanner, animated: true)
    }
    
    @IBAction func onAddressBook(_ sender: Any) {
        let addressBookVC = AddressBookViewController()
        addressBookVC.selectionCompletion = { [weak self](_ addressInfo : AddressInfo?) -> () in
            if let weakSelf = self{
                weakSelf.contractAddressField.text = addressInfo?.walletAddress
            }
        }
        navigationController?.pushViewController(addressBookVC, animated: true)
    }
    
    
    @IBAction func onConfirm(_ sender: Any) {
        
        if SWalletService.sharedInstance.getSWalletByContractAddress(contractAddress: contractAddressField.text!) != nil{
            self.showMessage(text: Localized("sharedWallet_sharedWallet_existed"))
            return
        }
        
        self.showLoading()
        SWalletService.sharedInstance.addShardWallet(contractAddress: self.contractAddressField.text!, sender: (selectedWallet?.key?.address)!, name: self.walletName.text!, walletAddress: (selectedWallet?.key?.address)!) { (result, data) in
            self.hideLoading()
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
            let _ = checkWalletNameValidation()
        }else if textField == contractAddressField {
            let _ = checkContractValidation()
        }
    }
    
    
    
    @objc func keyboardWillHide(){
        if CommonService.isValidContractAddress(contractAddressField.text).0 && CommonService.isValidWalletName(walletName.text).0{
            confirmButton.setCommonEanbleStyle(true)
        }else{
            confirmButton.setCommonEanbleStyle(false)
        }
    }
    
}
