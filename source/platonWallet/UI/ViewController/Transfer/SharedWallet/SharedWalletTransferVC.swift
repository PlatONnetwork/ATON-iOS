//
//  SharedWalletTransferVC.swift
//  platonWallet
//
//  Created by matrixelement on 20/11/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift
import platonWeb3

class SharedWalletTransferVC: BaseViewController ,UITextViewDelegate,UITextFieldDelegate{
    
    let transferView = UIView.viewFromXib(theClass: SharedWalletTransferView.self) as! SharedWalletTransferView

    var toAddress : String?
    var fromAddress : String?
    
    var amount : String?
    
    var submitGas : BigUInt?
    
    var confirmGas : BigUInt?
    
    var totalGas: BigUInt {
        get{
            if self.submitGas == nil || self.confirmGas == nil{
                return BigUIntZero
            }
            var total = BigUIntZero
            total.multiplyAndAdd(self.submitGas!, 1)
            if UIDisplay_addConfirmGas{
                total.multiplyAndAdd(self.confirmGas!, 1)
            }
            return total
        }
    }
    
    var totalFee: BigUInt{
        get{
            if self.submitGas == nil || self.confirmGas == nil{
                return BigUIntZero
            }
            return self.gasPrice.multiplied(by: self.totalGas)
        }
    }
    
    var gasPrice : BigUInt{
        get{
            let value = self.gasPricegweiValueMutiply10()
            let gasPrice = BigUInt.mutiply(a: String(value), by: THE8powerof10)
            return gasPrice!
        }
    }

    var confirmPopUpView : PopUpViewController?
    
    var selectedAddress : String?
    
    var selectedWallet : SWallet?{
        didSet{
            transferView.payWalletAddress.text = selectedWallet?.contractAddress
            transferView.payWalletName.text = selectedWallet?.name
            selectedAddress = selectedWallet?.contractAddress
            
            let balance = AssetService.sharedInstace.assets[(selectedWallet?.contractAddress)!]
            if let balance = balance{
                self.transferView.balanceLabel.text = (balance!.displayValueWithRound(round: 8)?.balanceFixToDisplay(maxRound: 8))!.ATPSuffix()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSubViews()
        initNavigationItem()
        navigationItem.localizedText = "transferVC_nav_title"
        let _ = self.checkConfirmButtonAvaible(showTip : false)
        self.estimateSubmitAndConfirm(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    func initSubViews() {
        view.addSubview(transferView)
        transferView.snp.makeConstraints { (make) in
            make.leading.trailing.top.bottom.equalTo(view)
        }
        transferView.toWalletAddressTextField.text = toAddress
        transferView.confirmBtn.addTarget(self, action: #selector(onConfirm), for: .touchUpInside)
        transferView.chooseWalletBtn.addTarget(self, action: #selector(onSwitchWallet), for: .touchUpInside)
        transferView.addressBookBtn.addTarget(self, action: #selector(onAddressBook), for: .touchUpInside)
        transferView.sendAllButton.addTarget(self, action: #selector(onSendAll), for: .touchUpInside)
        transferView.payWalletAddress.text = selectedWallet?.contractAddress
        transferView.payWalletName.text = selectedWallet?.name
        
        transferView.feeSlider.minimumValue = 10
        transferView.feeSlider.maximumValue = 100
        transferView.feeSlider.value = 5.0
        let _ = self.refreshLabel(true)
        transferView.feeSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        transferView.memoTextView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(onTextFiledTextChange(_:)), name: UITextField.textDidChangeNotification, object: transferView.sendAmoutTextField)
        NotificationCenter.default.addObserver(self, selector: #selector(onTextFiledTextChange(_:)), name: UITextField.textDidChangeNotification, object: transferView.toWalletAddressTextField)
        transferView.sendAmoutTextField.delegate = self
        transferView.toWalletAddressTextField.delegate = self
        
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
    
    @objc func onNavRight(){
        let scanner = QRScannerViewController()
        scanner.hidesBottomBarWhenPushed = true
        scanner.scanCompletion = { result in
            if result.is40ByteAddress(){
                self.transferView.toWalletAddressTextField.text = result
                let _ = self.transferView.checkInputAddress(showTip: true)
                let _ = self.checkConfirmButtonAvaible(showTip: false)
            }else{
                self.showMessage(text: Localized("QRScan_failed_tips"))
            }
            self.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(scanner, animated: true)
    }
    
    @objc func onConfirm() {
        resignViewsFirstResponse()
        
        if !checkConfirmButtonAvaible(showTip: false){
            return
        }
        
        if !self.checkInputMemoValid() {
            return
        }
        var validForSend = transferView.checkInputAddress(showTip: true)
        validForSend = transferView.checkInputAmout(showTip : true) && validForSend
        if !validForSend {
            return
        }
        
        let balance = self.getAvailbleBalance()
        
        if (String(balance)) == "0"{
            showMessage(text: Localized("transferVC_Insufficient_balance"))
            return
        }
        
        if !self.checkSufficient(){
            return
        }
        
        if (self.selectedWallet?.contractAddress.ishexStringEqual(other: transferView.toWalletAddressTextField.text))!{
            showMessage(text: Localized("cannot_send_itself"))
            return
        }
        
        self.showConfirmView()
    }
    
    func showConfirmView(){
        confirmPopUpView = PopUpViewController()
        let confirmView = UIView.viewFromXib(theClass: TransferConfirmView.self) as! TransferConfirmView
        confirmView.submitBtn.addTarget(self, action: #selector(onSubmit), for: .touchUpInside)
        confirmPopUpView!.setUpContentView(view: confirmView, size: CGSize(width: kUIScreenWidth, height: 314))
        confirmPopUpView!.setCloseEvent(button: confirmView.closeButton)
        confirmView.totalLabel.text = transferView.sendAmoutTextField.text!.ATPSuffix()
        confirmView.toAddressLabel.text = transferView.toWalletAddressTextField.text!
        confirmView.feeLabel.text = transferView.feeLabel.text
        confirmPopUpView!.show(inViewController: self)
    }
    
    @objc func onSubmit(){
        resignViewsFirstResponse()
        confirmPopUpView?.onDismissViewController()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.showInputPswAlert()
        }
    }
    
    func resignViewsFirstResponse(){
        if transferView.toWalletAddressTextField.isFirstResponder{
            transferView.toWalletAddressTextField.resignFirstResponder()
        }
        
        if transferView.sendAmoutTextField.isFirstResponder {
            transferView.sendAmoutTextField.resignFirstResponder()
        }
        
        if transferView.memoTextView.isFirstResponder {
            transferView.memoTextView.resignFirstResponder()
        }
    }
    
    @objc func onSwitchWallet(){
        let popUpVC = PopUpViewController()
        let view = UIView.viewFromXib(theClass: TransferSwitchWallet.self) as! TransferSwitchWallet
        view.selectedAddress = selectedAddress
        view.type = 1
        popUpVC.setUpContentView(view: view, size: CGSize(width: kUIScreenWidth, height: 289))
        popUpVC.setCloseEvent(button: view.closeBtn)
        view.selectionCompletion = { wallet in
            if let wallet = wallet as? SWallet{
                self.selectedWallet = wallet
            }
            popUpVC.onDismissViewController()
        }
        popUpVC.show(inViewController: self)
    }
    
    @objc func onAddressBook(){
        let addressBookVC = AddressBookViewController()
        addressBookVC.selectionCompletion = { [weak self](_ addressInfo : AddressInfo?) -> () in
            if let weakSelf = self{
                weakSelf.toAddress = addressInfo!.walletAddress
                weakSelf.transferView.toWalletAddressTextField.text = addressInfo!.walletAddress
                let _ = weakSelf.transferView.checkInputAddress(showTip: true)
                let _ = weakSelf.checkConfirmButtonAvaible(showTip : false)
            }
            
        }
        navigationController?.pushViewController(addressBookVC, animated: true)
    }
    
    
    func getAvailbleBalance() -> BigUInt{
        let balanceObj = AssetService.sharedInstace.assets[(selectedWallet?.contractAddress)!]
        if balanceObj == nil {
            return BigUInt("0")!
        }
        //8 digits after the decimal point
        let floorBalance = balanceObj??.balance?.floorToDecimal(round: (18 - 8))
        return floorBalance!
    }
    
    @objc func onSendAll(){
        
        let balance = getAvailbleBalance()
        if String((balance)) == "0"{
            transferView.sendAmoutTextField.text = "0"
            showMessage(text: Localized("transferVC_Insufficient_balance"))
            return
        }
        
        let fee = self.refreshLabel(true)
        var maxSendAmout = BigUInt(String((balance)))
        //let overflow = maxSendAmout?.subtractingReportingOverflow(fee!)
        let overflow = maxSendAmout?.subtractReportingOverflow(fee)
        if overflow! {
            transferView.resportSufficiency(isSufficient: false)
            return
        }
        transferView.resportSufficiency(isSufficient: true)
        transferView.sendAmoutTextField.text = maxSendAmout?.divide(by: ETHToWeiMultiplier, round: 8).balanceFixToDisplay(maxRound: 8)
        let _ = checkSufficient()
        let _ = checkConfirmButtonAvaible(showTip : true)
        
    }
    
    // MARK: - PopUp
    
    func showInputPswAlert() {
        
        let alertC = PAlertController(title: Localized("alert_input_psw_title"), message: nil)
        alertC.addTextField(text: "", placeholder: "", isSecureTextEntry: true)
        
        alertC.addAction(title: Localized("alert_cancelBtn_title")) {
        }
        
        alertC.addAction(title: Localized("alert_confirmBtn_title")) { [weak self] in
            
            if !CommonService.isValidWalletPassword(alertC.textField?.text ?? "").0{
                return
            }
            alertC.dismiss(animated: true, completion: nil)
            
            self?.showLoading()
            let wallet = SWalletService.sharedInstance.getATPWalletByAddress(address: (self!.selectedWallet?.walletAddress)!)
            WalletService.sharedInstance.exportPrivateKey(wallet: (wallet)!, password: (alertC.textField?.text)!, completion: { (pri, err) in
                if (err == nil && (pri?.length)! > 0) {
                    self?.doSubmitAndConfirm(pri!)
                }else{
                    self?.hideLoading()
                    self?.showMessage(text: (err?.errorDescription)!)
                }
            })
            
        }
        alertC.inputVerify = { input in
            return CommonService.isValidWalletPassword(input).0
        }
        alertC.addActionEnableStyle(title: Localized("alert_confirmBtn_title"))
        alertC.show(inViewController: self, animated: false)
        alertC.textField?.becomeFirstResponder()
        
    }
    
 
    
    func doSubmitAndConfirm(_ pri: String){
    
        let from = self.selectedWallet?.walletAddress
        let to = self.transferView.toWalletAddressTextField.text
        let amount = self.transferView.sendAmoutTextField.text
        let time = Date().millisecondsSince1970
        let value = BigUInt.mutiply(a: amount!, by: ETHToWeiMultiplier)!
        let memo = self.transferView.memoTextView.text ?? ""

        let fee = self.totalFee
        
        SWalletService.sharedInstance.submitTransaction(walltAddress: from!, privateKey: pri, contractAddress: (self.selectedWallet?.contractAddress)!,
                                                        submitGasPrice: self.gasPrice,
                                                        submitGas: self.submitGas!,
                                                        confirmGasPrice: self.gasPrice,
                                                        confirmGas: self.confirmGas!,
                                                        memo: memo,
                                                        destination: to!,
                                                        value: value,
                                                        time: UInt64(time),
                                                        fee: fee,
                                                        completion: { (result, data) in
                                                            self.hideLoading()
                                                            
                                                            switch result{
                                                            case .success:
                                                                UIApplication.rootViewController().showMessage(text: Localized("transferVC_transfer_success_tip")); self.navigationController?.popViewController(animated: true)
                                                            case .fail(let code, let errMsg):
                                                                self.showMessageWithCodeAndMsg(code: code!, text: errMsg!, delay: 1.5)
                                                            }
        })
        
    }
    
    //MARK: - UISlider
    
    @objc func sliderValueChanged(){
        let _ = self.refreshLabel(true)
        let _ = checkSufficient()
        let _ = checkConfirmButtonAvaible(showTip : true)
        self.estimateSubmitAndConfirm(true)
    }
    
    func refreshLabel(_ refreshLabel : Bool) -> BigUInt{
        if refreshLabel{
                    let feeString = self.totalFee.divide(by: ETHToWeiMultiplier
            , round: 18)
        transferView.feeLabel.text = feeString.ATPSuffix()
        }
        return self.totalFee
        
    }
    
  
    func gasPricegweiValueMutiply10() -> Int{
        let gweiValueMutiply10 = Int(transferView.feeSlider.value/18.0) * 18 + 10
        return gweiValueMutiply10
    }
    
    //MARK: - UITextViewDelegate
    
    public func textViewDidEndEditing(_ textView: UITextView){
        if !self.checkInputMemoValid() {
            return
        }
        self.estimateSubmitAndConfirm(true)
        let _ = self.refreshLabel(true)
    }
    
    func estimateSubmitAndConfirm(_ refreshFee: Bool){

        SWalletService.sharedInstance.estimateSubmitAndConfirm(walltAddress: (self.selectedWallet?.walletAddress)!, privateKey: "", contractAddress: (self.selectedWallet?.contractAddress)!, gasPrice: BigUIntZero, gas: BigUIntZero, memo: self.transferView.memoTextView.text ?? "", destination: DefaultAddress, value: BigUIntZero, len: BigUIntZero, time: 0, fee: BigUIntZero) { (result, data) in
            switch result{
            case .success:
                if let data = data as? (BigUInt, BigUInt){
                    self.submitGas = data.0
                    self.confirmGas = data.1
                    let _ = self.refreshLabel(refreshFee)
                }
            case .fail(_, _):
                do{}
            }
        }
    }
    
    func checkInputMemoValid() -> Bool{
        let dataContent = Data((transferView.memoTextView.text)!.utf8)
        if dataContent.count > maxRequestContentLength{
            self.showMessage(text: Localized("exceed max input"))
            return false
        }
        return true
    }
    
    @objc func onTextFiledTextChange(_ notification: Notification){
        let textField  = notification.object as! UITextField
        if textField == transferView.sendAmoutTextField{
            if (textField.text?.length)! > 0{
                let validForSend = transferView.checkInputAmout(showTip : false)
                if !validForSend {
                    return
                }
                let _ = self.checkSufficient()
            }
        }
        
        let _ = checkConfirmButtonAvaible(showTip : true)
    }
    
    
    
    func checkSufficient() -> Bool{
        if transferView.sendAmoutTextField.text?.length == 0{
            return true
        }
        var amountOfwei = BigUInt.mutiply(a: transferView.sendAmoutTextField.text!, by: ETHToWeiMultiplier)
        var overflow = false
        let fee = self.refreshLabel(true)
        
        let balance = getAvailbleBalance()
        var newBalance = BigUInt(String(balance))
        overflow = (newBalance?.subtractReportingOverflow(fee, shiftedBy: 0))!
        if overflow{
            //balance < fee
            transferView.resportSufficiency(isSufficient: false)
            return false
        }
        overflow = (newBalance?.subtractReportingOverflow(amountOfwei!, shiftedBy: 0))!
        if overflow{
            //amount < balance
            transferView.resportSufficiency(isSufficient: false)
            return false
        }else{
            transferView.resportSufficiency(isSufficient: true)
            return true
        }
    }
    
    func checkConfirmButtonAvaible(showTip : Bool) -> Bool{
        let inputValid = transferView.checkInputAmout()
        let addressValid = transferView.checkInputAddress()
        let sufficient = checkSufficient()
        if  sufficient && addressValid && inputValid && (transferView.toWalletAddressTextField.text?.length)! > 0 && (transferView.sendAmoutTextField.text?.length)! > 0{
            transferView.confirmBtn.backgroundColor = UIColor(rgb: 0xEFF0F5)
            return true
            
        }else{
            transferView.confirmBtn.backgroundColor = UIColor(rgb: 0x272F46)
            return false
        }
    }
    
    //MARK: - UITextFieldDelegate
    
    public func textFieldDidEndEditing(_ textField: UITextField){
        
        if textField == transferView.sendAmoutTextField{
            let _ = transferView.checkInputAmout(showTip: true)
            let _ = checkSufficient()
        }else if textField == transferView.toWalletAddressTextField{
            let _ = transferView.checkInputAddress(showTip: true)
        }
        let _ = checkConfirmButtonAvaible(showTip: false)
    }
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == transferView.sendAmoutTextField && textField.text != nil{
            
            //allow delete back
            if string == ""{
                return true
            }
            if !string.validFloatNumber(){
                return false
            }
            
            if let text = textField.text,let textRange = Range(range, in: text) {
                let updatedText = text.replacingCharacters(in: textRange,
                                                           with: string)
                return updatedText.trimNumberLeadingZero().isValidInputAmoutWith8DecimalPlace()
            }
            return false
        }
        return true
    }
}
