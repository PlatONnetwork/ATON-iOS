//
//  ATPTransferViewController.swift
//  platonWallet
//
//  Created by matrixelement on 18/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift
import BigInt

class ATPTransferViewController: BaseViewController ,UITextViewDelegate,UITextFieldDelegate{
    
    let transferView = UIView.viewFromXib(theClass: TransferView.self) as! TransferView
    var toAddress : String?
    var fromAddress : String?
    var defalutWallet : Wallet?
    var estimatedGas = BigUInt("210000")
    var amount : String?
    
    var totalFee: BigUInt{
        get{
            return self.gasPrice.multiplied(by: self.estimatedGas!)
        }
    }
    
    var confirmPopUpView : PopUpViewController?
    
    var selectedAddress : String?
    
    var selectedWallet : Wallet?{
        didSet{
            transferView.payWalletAddress.text = selectedWallet?.key?.address
            transferView.payWalletName.text = selectedWallet?.name
            self.selectedAddress = selectedWallet?.key?.address
            
            let balance = AssetService.sharedInstace.assets[(selectedWallet!.key?.address)!]
            if let balance = balance{
                self.transferView.balanceLabel.text = (balance!.displayValueWithRound(round: 8)?.balanceFixToDisplay(maxRound: 8))!.ATPSuffix()
            }
        }
    }
     
    var gasPrice : BigUInt{
        get{
            let value = self.gasPricegweiValueMutiply10()
            let gasPrice = BigUInt.mutiply(a: String(value), by: THE8powerof10)
            return gasPrice!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSubViews()
        initNavigationItem()
        super.leftNavigationTitle = "transferVC_nav_title"
        selectedWallet = defalutWallet
        
        let _ = self.checkConfirmButtonAvaible(showTip : false)
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
        transferView.payWalletAddress.text = defalutWallet?.key?.address
        transferView.payWalletName.text = defalutWallet?.name
        
        transferView.feeSlider.minimumValue = 10
        transferView.feeSlider.maximumValue = 100
        transferView.feeSlider.value = 5.0
        self.refreshLabel(true)
        transferView.feeSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        transferView.memoTextView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(onTextFiledTextChange(_:)), name: UITextField.textDidChangeNotification, object: transferView.sendAmoutTextField)
        NotificationCenter.default.addObserver(self, selector: #selector(onTextFiledTextChange(_:)), name: UITextField.textDidChangeNotification, object: transferView.toWalletAddressTextField)
        transferView.sendAmoutTextField.delegate = self
        transferView.toWalletAddressTextField.delegate = self
        
    }
    
    func initNavigationItem(){
        let scanButton = UIButton(type: .custom)
        scanButton.setImage(UIImage(named: "navScanBlack"), for: .normal)
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
        
        if (self.selectedWallet?.key?.address.ishexStringEqual(other: transferView.toWalletAddressTextField.text))!{
            showMessage(text: Localized("cannot_send_itself"))
            return
        }
        
        if !self.checkSufficient(){
            return
        }
        
        confirmPopUpView = PopUpViewController()
        let confirmView = UIView.viewFromXib(theClass: TransferConfirmView.self) as! TransferConfirmView
        confirmView.submitBtn.addTarget(self, action: #selector(onSubmit), for: .touchUpInside)
        confirmPopUpView!.setUpContentView(view: confirmView, size: CGSize(width: kUIScreenWidth, height: 314))

        confirmView.totalLabel.text = transferView.sendAmoutTextField.text!.ATPSuffix()
        confirmView.toAddressLabel.text = transferView.toWalletAddressTextField.text!
        confirmView.feeLabel.text = transferView.feeLabel.text
        confirmPopUpView!.show(inViewController: self)
    }
    
    @objc func onSubmit(){
        resignViewsFirstResponse()
        confirmPopUpView?.onDismissViewController()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            //self.showInputPswAlert()
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
        popUpVC.setUpContentView(view: view, size: CGSize(width: PopUpContentWidth, height: 289))
        popUpVC.setCloseEvent(button: view.closeBtn)
        view.selectionCompletion = { wallet in
            self.selectedWallet = (wallet as! Wallet)
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
                let _ = weakSelf.checkConfirmButtonAvaible(showTip: false)
            }
            
        }
        navigationController?.pushViewController(addressBookVC, animated: true)
    }
    
    
    func getAvailbleBalance() -> BigUInt{
        let balanceObj = AssetService.sharedInstace.assets[(selectedWallet!.key?.address)!]
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
        
        self.refreshLabel(true)
        
        var maxSendAmout = BigUInt(String((balance)))
        //let overflow = maxSendAmout?.subtractingReportingOverflow(fee!)
        let overflow = maxSendAmout?.subtractReportingOverflow(self.totalFee)
        if overflow! {
            transferView.resportSufficiency(isSufficient: false)
            return
        }
        transferView.resportSufficiency(isSufficient: true)
        transferView.sendAmoutTextField.text = maxSendAmout?.divide(by: ETHToWeiMultiplier, round: 8).balanceFixToDisplay(maxRound: 8)
        let _ = checkSufficient()
        let _ = checkConfirmButtonAvaible(showTip : true)
        
    }
    
    
    func presendByQueryEstimageGas(pri : String){
        
        self.doTransfer(pri: pri, data: nil)
        
        /*
        let memo = self.transferView.memoTextView.text
        TransactionService.service.getEstimateGas(memo: memo) { (result, data) in
            switch result{
            case .success:
                self.doTransfer(pri: pri, data: data!)
            case .fail(let code, let des):
                self.hideLoading()
                self.showMessageWithCodeAndMsg(code: code!, text: des!, delay: 2.5)                
            }
        }
        */
 
    }
    
    
    func doTransfer(pri: String, data: AnyObject?){
        
        if let bret = data as? BigUInt{
            NSLog("getEstimateGas:" + String(bret))
            self.estimatedGas = bret
        }
        
        let from = self.selectedWallet?.key?.address
        let to = self.transferView.toWalletAddressTextField.text
        let amount = self.transferView.sendAmoutTextField.text
        let memo = self.transferView.memoTextView.text
        
        let _ = TransactionService.service.sendAPTTransfer(from: from!, to: to!, amount: amount!, InputGasPrice: self.gasPrice, estimatedGas: String(self.estimatedGas!), memo: memo!, pri: pri, completion: { (result, txHash) in
            self.hideLoadingHUD()
            switch result{
            case .success:
                UIApplication.rootViewController().showMessage(text: Localized("transferVC_transfer_success_tip"))
                self.navigationController?.popViewController(animated: true)
            case .fail(let code, let des):
                self.showMessageWithCodeAndMsg(code: code!, text: des!)
            }
            
        })
    }
    
    //MARK: - UISlider
    
    @objc func sliderValueChanged(){
        self.refreshLabel(true)
        let _ = checkSufficient()
        let _ = checkConfirmButtonAvaible(showTip : true)
    }
    
    
    func refreshLabel(_ refreshLabel : Bool){
        if refreshLabel{
            let feeString = self.totalFee.divide(by: ETHToWeiMultiplier
                , round: 18)
            transferView.feeLabel.text = feeString.ATPSuffix()
        }
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
        self.estimateMemoGas(refreshFee: true)
    }
    
    func estimateMemoGas(refreshFee: Bool){
        if self.transferView.memoTextView.text.length == 0{
            return
        }
        TransactionService.service.getEstimateGas(memo: self.transferView.memoTextView.text ?? "") { (result, data) in
            switch result{
                
            case .success:
                let gas = data as? BigUInt
                self.estimatedGas = gas
                self.refreshLabel(true)
            case .fail(_, _):
                do {}
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
        let amountOfwei = BigUInt.mutiply(a: transferView.sendAmoutTextField.text!, by: ETHToWeiMultiplier)
        var overflow = false
        self.refreshLabel(true)
        
        let balance = getAvailbleBalance()
        var newBalance = BigUInt(String(balance))
        overflow = (newBalance?.subtractReportingOverflow(self.totalFee, shiftedBy: 0))!
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
