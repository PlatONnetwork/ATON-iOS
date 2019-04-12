//
//  SendAssetViewControllerV060.swift
//  platonWallet
//
//  Created by juzix on 2019/3/5.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import Localize_Swift
import BigInt


//MARK: - UI

class AssetSendViewControllerV060: BaseViewController, UITextFieldDelegate{
    
    var confirmPopUpView : PopUpViewController?
    
    var estimatedGas = BigUInt("210000")
    
    var gasPrice : BigUInt?{
        get{ 
            //gas prise: 1gwei ~ 10gwei
            
            let mul = String(1 + 3 * (self.gasPriceLevel - 1))
            return BigUInt.mutiply(a: mul, by: THE9powerof10)
        }
    }
    
    //level int 1~4
    var gasPriceLevel = 1
    
    //Joint wallet property
    var submitGas : BigUInt?
    
    var confirmGas : BigUInt?
    
    //Joint wallet property - end
    
    
    func gasPricegweiValueMutiply10() -> Int{
        self.feeView.levelView.levelChanged = { level in 
            print("level: \(level)")
        }
        //let gweiValueMutiply10 = Int(transferView.feeSlider.value/18.0) * 18 + 10
        let gweiValueMutiply10 = 100
        return gweiValueMutiply10 
    }

    var walletType : WalletType{
        get{
            if let _ = AssetVCSharedData.sharedData.selectedWallet as? Wallet{
                return WalletType.ClassicWallet
            }
            return WalletType.JointWallet
        }
    }
        
    lazy var walletAddressView = { () -> PTextFieldView in 
        let walletView = PTextFieldView.create(title: "Wallet Address:")
        walletView.checkInput(mode: .endEdit, check: {[weak self] (text) -> (Bool, String) in
            self?.checkQuickAddAddress()
            return CommonService.checkTransferAddress(text: text)
        }, heightChange: { [weak self](view) in
            self?.textFieldViewUpdateHeight(view: view)
        })
        //walletView.textField.textAlignment = .center
        
        walletView.shouldChangeCharactersCompletion = {[weak self] (concatenated,replacement) in
            return true
        }
        walletView.endEditCompletion = {[weak self] text in
            let _ = self?.checkConfirmButtonAvailable()
        }
        return walletView 
        
    }()
    
    lazy var quickSaveAddrBtn = { () -> QuickSaveAddressButton in
        let button = QuickSaveAddressButton(type: .custom)
        button.localizedNormalTitle = "savetoaddressbook"
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.setTitleColor(UIColor(rgb: 0x105CFE ), for: .normal)
        return button
    }()
    
    lazy var amountView = { () -> PTextFieldView in 
        
        let amountView = PTextFieldView.create(title: "Amount:")
        
        amountView.addAction(title: "All", action: {[weak self] in
            self?.onSendAll()
        }) 
        
        amountView.checkInput(mode: .all, check: {[weak self] text -> (Bool, String) in
             
            let inputformat = CommonService.checkTransferAmoutInput(text: text, checkBalance: false, fee: nil)
            if !inputformat.0{
                return inputformat
            }
            return (self?.checkSufficient(text: text))!
                
        }, heightChange: { [weak self](view) in
            self?.textFieldViewUpdateHeight(view: view)
        })
        
        amountView.shouldChangeCharactersCompletion = {[weak self] (concatenated,replacement) in
            if replacement == ""{
                return true
            }
            if !replacement.validFloatNumber(){
                return false
            }
            return concatenated.trimNumberLeadingZero().isValidInputAmoutWith8DecimalPlace()
        }
        
        amountView.endEditCompletion = {[weak self] text in
            let _ = self?.checkConfirmButtonAvailable()
        }
        
        return amountView
        
    }()
    
    lazy var balanceLabel = { () -> UILabel in 
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = common_lightGray_color
        label.textAlignment = .right
        label.text = "Balance:- Energon"
        return label
    }()
    
    lazy var feeView = { () -> AssetFeeViewV060 in 

        let view = AssetFeeViewV060(frame:.zero)
        return view
    }()
    
    lazy var sendBtn = { () -> PButton in 
        let btn = PButton(frame: .zero)
        btn.localizedNormalTitle = "walletDetailVC_send_button"
        btn.style = .plain
        btn.addTarget(self, action: #selector(onSendButton(_:)), for: .touchUpInside)
        return btn
    }()
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSubViews()
        initdata()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if sendBtn.style == .plain && !sendBtn.frame.equalTo(.zero){
            let _ = self.checkConfirmButtonAvailable()
        }
    }
    
    //MARK: - Data init
    
    override func viewWillAppear(_ animated: Bool) {
        self.refreshData()
        let commonbgcolor = UIColor(red: 247, green: 250, blue: 255, alpha: 1)
        self.view.backgroundColor = commonbgcolor
        self.amountView.backgroundColor = commonbgcolor
        self.walletAddressView.backgroundColor = commonbgcolor
        self.feeView.backgroundColor = commonbgcolor
        self.feeView.levelView.backgroundColor = commonbgcolor
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.cleanInputEmptyErrorState()
    }
    
    func cleanInputEmptyErrorState(){
        if self.amountView.textField.text?.length == 0{
            self.amountView.cleanErrorState()
        }
        if self.walletAddressView.textField.text?.length == 0{
            self.walletAddressView.cleanErrorState()
        }
    }
    
    func initdata(){
        self.refreshData()
        AssetVCSharedData.sharedData.registerHandler(object: self) { 
            self.refreshData()
            let _ = self.checkConfirmButtonAvailable()
        }
    }
     
    func refreshData(){
        NotificationCenter.default.addObserver(self, selector: #selector(DidNodeGasPriceUpdate), name: NSNotification.Name(DidNodeGasPriceUpdateNotification), object: nil)
        guard AssetVCSharedData.sharedData.selectedWallet != nil else {
            return
        }
        self.estimateMemoGas()
        self.estimateSubmitAndConfirm()
        
    }
    
    func initSubViews() {
        view.addSubview(walletAddressView)
        walletAddressView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(20)
            make.height.equalTo(walletAddressView.internalHeight)
        }
        
        walletAddressView.addSubview(quickSaveAddrBtn)
        quickSaveAddrBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(0)
        }
        quickSaveAddrBtn.addTarget(self, action: #selector(onQuickAddAddress), for: .touchUpInside)
        
        view.addSubview(amountView)
        amountView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(walletAddressView.snp.bottom).offset(20)
            make.height.equalTo(amountView.internalHeight)
        }
        
        view.addSubview(balanceLabel)
        balanceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(amountView.snp.bottom).offset(8)
            make.right.equalToSuperview().offset(-16)
        }
        
        view.addSubview(feeView)
        feeView.snp.makeConstraints { (make) in
            make.top.equalTo(balanceLabel.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
            make.height.equalTo(72)
        }
        
        view.addSubview(sendBtn)
        sendBtn.snp.makeConstraints { (make) in
            make.top.equalTo(feeView.snp.bottom).offset(32)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(44)
        } 
        
        walletAddressView.addAction(icon: UIImage(named: "textField_icon_addressBook"), action: {
            
            let addressBookVC = AddressBookViewController()
            addressBookVC.selectionCompletion = { [weak self](_ addressInfo : AddressInfo?) -> () in
                if let weakSelf = self{
                    weakSelf.walletAddressView.textField.text = addressInfo!.walletAddress
                    weakSelf.walletAddressView.cleanErrorState()
                    let _ = weakSelf.checkConfirmButtonAvailable()
                }
                
            }
            AssetViewControllerV060.pushViewController(viewController: addressBookVC)
            
        })
        walletAddressView.addAction(icon: UIImage(named: "textField_icon_scan"), action: {
            
            let scanner = QRScannerViewController()
            scanner.hidesBottomBarWhenPushed = true
            scanner.scanCompletion = {[weak self] result in
                if result.is40ByteAddress(){
                    self?.walletAddressView.textField.text = result
                    self?.walletAddressView.cleanErrorState()
                    let _ = self?.checkConfirmButtonAvailable()
                }else{
                    //self.showMessage(text: Localized("QRScan_failed_tips"))
                }
                AssetViewControllerV060.popViewController()
            }
            AssetViewControllerV060.pushViewController(viewController: scanner)
            
        })
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap(gesture:)))
        self.view.addGestureRecognizer(tapGesture)
        
        self.feeView.levelView.levelChanged = { level in 
            self.gasPriceLevel = level
            self.DidNodeGasPriceUpdate()
        }
        self.DidNodeGasPriceUpdate()
        self.checkQuickAddAddress()
        
        walletAddressView.textFieldShouldReturnCompletion = {[weak self] textField in
            self?.amountView.textField.becomeFirstResponder()
            return true
        }
        amountView.textFieldShouldReturnCompletion = {[weak self] textField in
            self?.amountView.textField.resignFirstResponder()
            return true
        }
        amountView.textField.keyboardType = UIKeyboardType.decimalPad
        
    }
    
    //MARK: - User Interaction
    
    @objc func onQuickAddAddress(){
        guard let addressText = walletAddressView.textField.text,addressText.is40ByteAddress() else{
            return
        }
        if self.quickSaveAddrBtn.status == QuickSaveStatus.QuickSaveDisable{
            return
        }
        let alertVC = AlertStylePopViewController.initFromNib()
        let style = PAlertStyle.commonInputWithItemDes(itemDes: Localized("addressbook_wallet_address_with_Colon"),
                                           itemContent: addressText.addressForDisplay(),
                                           inputDes: Localized("addressbook_wallet_name_with_Colon"),
                                           placeHoder: "",
                                           preInputText: "")
        alertVC.textFieldInput.checkInput(mode: CheckMode.textChange, check: { (input) -> (Bool, String) in
            let ret = CommonService.isValidWalletName(input)
            return (ret.0,ret.1 ?? "")
        }) { textField in
            
        }
        alertVC.onAction(confirm: {[weak self] (text, _) -> (Bool) in
            
            let ret = CommonService.isValidWalletName(text)
            if !ret.0{
                alertVC.showInputErrorTip(string: ret.1)
                return false
            }else{
                self?.quickSaveAddrBtn.quickSave(address: addressText, name: text)
                self?.quickSaveAddrBtn.checkAndUpdateStatus(address: addressText,name: text)
                return true
            }
        }) { (_, _) -> (Bool) in
            return true
        }
        alertVC.style = style
        alertVC.showInViewController(viewController: self)
    }
    
    @objc func onSendButton(_ sender: UIButton) {
        
        if !self.checkConfirmButtonAvailable(){
            return
        }
        
        confirmPopUpView = PopUpViewController()
        let confirmView = UIView.viewFromXib(theClass: TransferConfirmView.self) as! TransferConfirmView
        confirmView.submitBtn.addTarget(self, action: #selector(onConfirmButton), for: .touchUpInside)
        confirmPopUpView?.setCloseEvent(button: confirmView.closeButton)
        
        confirmPopUpView?.dismissCompletion = {
            
        }
        
        if let wallet = AssetVCSharedData.sharedData.selectedWallet as? Wallet{
            confirmPopUpView!.setUpContentView(view: confirmView, size: CGSize(width: PopUpContentWidth, height: 357))
            confirmView.hideExecutor()
            confirmView.totalLabel.text = amountView.textField.text!
            confirmView.toAddressLabel.text = walletAddressView.textField.text!
            confirmView.feeLabel.text = balanceLabel.text
            confirmView.walletName.text = wallet.name
            
            let feeString = self.totalFee().divide(by: ETHToWeiMultiplier
                , round: 18)
            confirmView.feeLabel.text = feeString.ATPSuffix()

        }else if let swallet = AssetVCSharedData.sharedData.selectedWallet as? SWallet{
            
            guard let owner = WalletService.sharedInstance.getWalletByAddress(address: swallet.walletAddress) else{
                self.showMessage(text: "wallet not exist")
                return
            }
            
            confirmPopUpView!.setUpContentView(view: confirmView, size: CGSize(width: PopUpContentWidth, height: 391))
            confirmView.totalLabel.text = amountView.textField.text!
            confirmView.toAddressLabel.text = walletAddressView.textField.text!
            confirmView.feeLabel.text = balanceLabel.text
            confirmView.executorLabel.text = owner.name
            confirmView.walletName.text = AssetVCSharedData.sharedData.selectedWalletName

        }
            
        confirmPopUpView!.show(inViewController: self)
        
    }
    
    @objc func onConfirmButton(){
        //confirmPopUpView?.onDismissViewController(animated: false)
        confirmPopUpView?.onDismissViewController(animated: true, completion: { 
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.showPasswordInputPswAlert()
            }
        })
        //delay show pass input
        
    } 
    
    //MARK: - Check method
    
    func checkConfirmButtonAvailable() -> Bool{
        self.checkQuickAddAddress()
        if self.amountView.checkInvalidNow(showText: false)!.0 && self.walletAddressView.checkInvalidNow(showText: false)!.0{
            self.sendBtn.style = .blue
            return true
        }
        self.sendBtn.style = .disable
        return false
    }
    
    @objc func onTap(gesture: UITapGestureRecognizer){
        if self.amountView.textField.isFirstResponder{
            self.amountView.textField.resignFirstResponder()
        }
        if self.walletAddressView.textField.isFirstResponder{
            self.walletAddressView.textField.resignFirstResponder()
        }
    }
    
    func checkQuickAddAddress(){
       self.quickSaveAddrBtn.checkAndUpdateStatus(address: walletAddressView.textField.text, name: "nametoinput")
    }
    
    func textFieldViewUpdateHeight(view: PTextFieldView) {
        view.snp.updateConstraints { (make) in
            make.height.equalTo(view.internalHeight)
        }
    }
    
    
    // MARK: - PopUp
    
    func showPasswordInputPswAlert() { 
        
        var executorWallet : Wallet?
        if let w = AssetVCSharedData.sharedData.selectedWallet as? Wallet{
            executorWallet = w
        }else{
            executorWallet = AssetVCSharedData.sharedData.jWallet!.ownerWallet()
        }
            
        let alertVC = AlertStylePopViewController.initFromNib()
        passwordInputAlert = alertVC
        let style = PAlertStyle.passwordInput(walletName: AssetVCSharedData.sharedData.selectedWalletName)
        alertVC.onAction(confirm: {[weak self] (text, _) -> (Bool)  in
            let valid = CommonService.isValidWalletPassword(text ?? "")
            if !valid.0{
                alertVC.showInputErrorTip(string: valid.1)
                return false
            }
            if let notnilAlertVC = self?.passwordInputAlert{
                notnilAlertVC.showLoadingHUD()
            }
            
            WalletService.sharedInstance.exportPrivateKey(wallet: executorWallet!, password: (alertVC.textFieldInput?.text)!, completion: { (pri, err) in
                
                if (err == nil && (pri?.length)! > 0) {
                    if self?.walletType == WalletType.ClassicWallet{
                        self?.doClassicTransfer(pri: pri!, data: nil)
                    }else{
                        self?.doJointWalletSubmitAndConfirm(pri!)
                    }
                    alertVC.dismissWithCompletion()
                }else{
                    if let notnilAlertVC = self?.passwordInputAlert{
                        notnilAlertVC.hideLoadingHUD()
                    }
                    alertVC.showInputErrorTip(string: (err?.errorDescription)!)
                }
            })
            return false
            
        }) { (_, _) -> (Bool) in
            return true
        }
        alertVC.style = style
        alertVC.showInViewController(viewController: self)
        
        return
    }
    
    func updateBalance(balance: BigUInt){
        let ret = balance.divide(by: ETHToWeiMultiplier, round: 8)
        self.balanceLabel.text = ret.balanceFixToDisplay(maxRound: 8).ATPSuffix()
    }
    
    func resportSufficiency(isSufficient: Bool){
        
    }
    

    func didTransferSuccess(){
        self.walletAddressView.textField.text = ""
        self.amountView.textField.text = ""
        AssetViewControllerV060.setPageViewController(index: 0)
        AssetViewControllerV060.reloadTransactionList()
    }
    
    
}

//MARK: - Classic transfer Logic

extension AssetSendViewControllerV060{

    
    func estimateMemoGas(){
        TransactionService.service.getEstimateGas(memo: "") { (result, data) in
            switch result{
            case .success:
                if let gas = data as? BigUInt{
                    //use fixed value 21000
                    //self.estimatedGas = gas
                    //print("estimatedGas:\(String(self.estimatedGas!))")
                }
            case .fail(_, _):
                do {}
            }
        }
    }
    
    //MARK : - Notification
    
    @objc func DidNodeGasPriceUpdate(){
        let feeString = self.totalFee().divide(by: ETHToWeiMultiplier
            , round: 18)
        self.feeView.fee.text = feeString.ATPSuffix()
    }
    
    func checkSufficient(text: String?) -> (Bool, String){
        if text == nil{
            return (true,"")
        }
        let amountOfwei = BigUInt.mutiply(a: text!, by: ETHToWeiMultiplier)
        var overflow = false
        
        let balance = getAvailbleBalance()
        var newBalance = BigUInt(String(balance))
        overflow = (newBalance?.subtractReportingOverflow(self.totalFee(), shiftedBy: 0))!
        if overflow{
            //balance < fee
            self.resportSufficiency(isSufficient: false)
            return (false,Localized("transferVC_Insufficient_balance"))
        }
        overflow = (newBalance?.subtractReportingOverflow(amountOfwei!, shiftedBy: 0))!
        if overflow{
            //amount < balance
            self.resportSufficiency(isSufficient: false)
            return (false,Localized("transferVC_Insufficient_balance"))
        }else{
            self.resportSufficiency(isSufficient: true)
            return (true,"")
        }
    }
    
    func totalFee() -> BigUInt{
        if let _ = AssetVCSharedData.sharedData.selectedWallet as? Wallet{
            return (self.gasPrice?.multiplied(by: self.estimatedGas!))!
        }else if let _ = AssetVCSharedData.sharedData.selectedWallet as? SWallet{
            return BigUInt("0")!
        }
        return BigUInt("0")!
    }
    
    func onSendAll(){
        let balance = getAvailbleBalance()
        if String((balance)) == "0"{
            amountView.textField.text = "0"
            showMessage(text: Localized("transferVC_Insufficient_balance"))
            return
        }
        var maxSendAmout = BigUInt(String((balance)))
        //let overflow = maxSendAmout?.subtractingReportingOverflow(fee!)
        let overflow = maxSendAmout?.subtractReportingOverflow(self.totalFee())
        if overflow! {
            self.resportSufficiency(isSufficient: false)
            return
        }
        self.resportSufficiency(isSufficient: true)
        amountView.textField.text = maxSendAmout?.divide(by: ETHToWeiMultiplier, round: 8).balanceFixToDisplay(maxRound: 8)
        let _ = self.checkConfirmButtonAvailable()
    }
    
    func getAvailbleBalance() -> BigUInt{
        let balanceObj = AssetService.sharedInstace.assets[AssetVCSharedData.sharedData.selectedWalletAddress!]
        if balanceObj == nil {
            return BigUInt("0")!
        }
        //8 digits after the decimal point
        let floorBalance = balanceObj??.balance?.floorToDecimal(round: (18 - 8))
        return floorBalance!
    }
    
    //MARK: - Transfer
    
    func doClassicTransfer(pri: String, data: AnyObject?){
        
        let from = AssetVCSharedData.sharedData.cWallet?.key?.address
        let to = self.walletAddressView.textField.text!
        let amount = self.amountView.textField.text!
        let memo = ""
        
        let _ = TransactionService.service.sendAPTTransfer(from: from!, to: to, amount: amount, InputGasPrice: self.gasPrice!, estimatedGas: String(self.estimatedGas!), memo: memo, pri: pri, completion: {[weak self] (result, txHash) in
            if let notnilAlertVC = self?.passwordInputAlert{
                notnilAlertVC.hideLoadingHUD()
            }
            switch result{
            case .success:
                self?.didTransferSuccess()
                UIApplication.rootViewController().showMessage(text: Localized("transferVC_transfer_success_tip"))
                self?.navigationController?.popViewController(animated: true)
            case .fail(let code, let des):
                self?.showMessageWithCodeAndMsg(code: code!, text: des!)
            }
            
        }) 
    }
    
    



}

//MARK: - Joint wallet logic

extension AssetSendViewControllerV060{
    
    func estimateSubmitAndConfirm(){
        
        guard self.walletType == WalletType.JointWallet else {
            return
        }
        
        let from = AssetVCSharedData.sharedData.jWallet?.walletAddress
        /*
        let to = self.walletAddressView.textField.text!
        let amount = self.amountView.textField.text!
        let time = Date().millisecondsSince1970
        let value = BigUInt("0")
        let memo = ""
        */
        let contractAddress = AssetVCSharedData.sharedData.jWallet?.contractAddress
        guard contractAddress != nil else {
            return
        }
        SWalletService.sharedInstance.estimateSubmitAndConfirm(walltAddress: from!, privateKey: "", contractAddress: contractAddress!, gasPrice: BigUIntZero, gas: BigUIntZero, memo: "", destination: DefaultAddress, value: BigUIntZero, len: BigUIntZero, time: 0, fee: BigUIntZero) { (result, data) in
            switch result{
            case .success:
                if let data = data as? (BigUInt, BigUInt){
                    self.submitGas = data.0
                    self.confirmGas = data.1
                    //let _ = self.refreshLabel(refreshFee)
                }
            case .fail(_, _):
                do{}
            }
        }
    }
    
    func doJointWalletSubmitAndConfirm(_ pri: String){
        
        let from = AssetVCSharedData.sharedData.jWallet?.walletAddress
        let to = self.walletAddressView.textField.text!
        let amount = self.amountView.textField.text!
        let time = Date().millisecondsSince1970
        let value = BigUInt.mutiply(a: amount, by: ETHToWeiMultiplier)!
        let memo = ""
        let contractAddress = AssetVCSharedData.sharedData.jWallet?.contractAddress
        
        let fee = self.totalFee()
        
        SWalletService.sharedInstance.submitTransaction(walltAddress: from!, 
                                                        privateKey: pri, 
                                                        contractAddress: contractAddress!,
                                                        submitGasPrice: self.gasPrice!,
                                                        submitGas: self.submitGas!,
                                                        confirmGasPrice: self.gasPrice!,
                                                        confirmGas: self.confirmGas!,
                                                        memo: memo,
                                                        destination: to,
                                                        value: value,
                                                        time: UInt64(time),
                                                        fee: fee,
                                                        completion: {[weak self] (result, data) in
                                                            if let notnilAlertVC = self?.passwordInputAlert{
                                                                notnilAlertVC.hideLoadingHUD()
                                                            }
                                                            switch result{
                                                            case .success:
                                                                UIApplication.rootViewController().showMessage(text: Localized("transferVC_transfer_success_tip")); self?.navigationController?.popViewController(animated: true)
                                                                self?.didTransferSuccess()
                                                            case .fail(let code, let errMsg):
                                                                self?.showMessageWithCodeAndMsg(code: code!, text: errMsg!, delay: 1.5)
                                                            }
        })
        
    }
}


