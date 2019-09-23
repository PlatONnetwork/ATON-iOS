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
    var gasPriceLevel: Float = 1/6.5
    
    var gasPrice : BigUInt?{
        get{  
            //gas prise: 1gwei ~ 10gwei
            let platonGasPrice = TransactionService.service.ethGasPrice ?? BigUInt.zero
            let minGasPrice = platonGasPrice.multiplied(by: BigUInt(Int(0.5 * 10))) / BigUInt(10)
            let maxGasPrice = platonGasPrice.multiplied(by: BigUInt(6))
            
            let price = minGasPrice + (((maxGasPrice - minGasPrice) * BigUInt(Int(self.gasPriceLevel * 10000000)) / BigUInt(10000000)))
            return price
        }
    }
    
    //Joint wallet property
    var submitGas : BigUInt?
    
    var confirmGas : BigUInt?
    
    lazy var amountView = { () -> ATextFieldView in
        let amountView = ATextFieldView.create(title: "send_amout_colon")
        amountView.textField.LocalizePlaceholder = "send_amount_placeholder"
        amountView.textField.keyboardType = .decimalPad
        amountView.addAction(title: "send_sendAll", action: {[weak self] in
            self?.onSendAll()
        })
        amountView.checkInput(mode: .all, check: {[weak self] text -> (Bool, String) in
            
            let inputformat = CommonService.checkTransferAmoutInput(text: text, checkBalance: false, fee: nil)
            if !inputformat.0{
                return inputformat
            }
            return (self?.checkSufficient(text: text))!
            
            }, heightChange: { [weak self](view) in
                self?.textFieldViewUpdateHeight(atextFieldView: view)
        })
        
        amountView.shouldChangeCharactersCompletion = { [weak self] (concatenated,replacement) in
            if replacement == ""{
                return true
            }
            if !replacement.validFloatNumber(){
                return false
            }
            return concatenated.trimNumberLeadingZero().isValidInputAmoutWith8DecimalPlace()
        }
        
        amountView.endEditCompletion = { [weak self] text in
            let _ = self?.checkConfirmButtonAvailable()
            let _ = amountView.checkInvalidNow(showErrorMsg: false)
        }
        
        return amountView
    }()
    
    
        
    lazy var walletAddressView = { () -> PTextFieldView in 
        let walletView = PTextFieldView.create(title: "send_wallet_colon")
        walletView.textField.LocalizePlaceholder = "send_address_placeholder"
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
            let _ = self?.amountView.checkInvalidNow(showErrorMsg: false)
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
    
    lazy var balanceLabel = { () -> UILabel in 
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = common_lightGray_color
        label.textAlignment = .right
        label.text = Localized("transferVC_transfer_balance") + "- LAT"
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
        NotificationCenter.default.addObserver(self, selector: #selector(DidUpdateAllAsset), name: Notification.Name.ATON.DidUpdateAllAsset, object: nil)
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
        
        AnalysisHelper.handleEvent(id: event_send, operation: .begin)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.cleanInputEmptyErrorState()
        
        AnalysisHelper.handleEvent(id: event_send, operation: .cancel)
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
        NotificationCenter.default.addObserver(self, selector: #selector(DidNodeGasPriceUpdate), name: Notification.Name.ATON.DidNodeGasPriceUpdate, object: nil)
        guard AssetVCSharedData.sharedData.selectedWallet != nil else {
            return
        }
        
        if let obj = AssetVCSharedData.sharedData.selectedWallet as? Wallet{
            self.balanceLabel.text = Localized("transferVC_transfer_balance") + obj.balanceDescription()
        }
    }
    
    //MARK: - Notification
    
    @objc func DidUpdateAllAsset(){
        self.refreshData()
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
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(walletAddressView.snp.bottom).offset(20)
//            make.height.equalTo(amountView.internalHeight)
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
                    AssetViewControllerV060.getInstance()?.showMessage(text: Localized("QRScan_failed_tips"))
                }
                AssetViewControllerV060.popViewController()
            }
            AssetViewControllerV060.pushViewController(viewController: scanner)
            
        })
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap(gesture:)))
        self.view.addGestureRecognizer(tapGesture)
        
        self.feeView.levelView.curLevel = gasPriceLevel
        self.feeView.levelView.levelChanged = { [weak self] level in
            self?.gasPriceLevel = level
            self?.DidNodeGasPriceUpdate()
            let _ = self?.amountView.checkInvalidNow(showErrorMsg: true)
            let _ = self?.checkConfirmButtonAvailable()
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
        
    }
    
    //MARK: - User Interaction
    private func saveToAddressBook(addressText: String?, name: String?) {
        quickSaveAddrBtn.quickSave(address: addressText, name: name)
        quickSaveAddrBtn.checkAndUpdateStatus(address: addressText,name: name)
    }
    
    @objc func onQuickAddAddress(){
        guard let addressText = walletAddressView.textField.text,addressText.is40ByteAddress() else{
            return
        }
        if self.quickSaveAddrBtn.status == QuickSaveStatus.QuickSaveDisable{
            return
        }
        
        // 改地址已存在客户端，则直接写入
        if let wallet = AssetVCSharedData.sharedData.walletList.filter({ ($0 as! Wallet).address.ishexStringEqual(other: addressText)
        }).first {
            saveToAddressBook(addressText: addressText, name: (wallet as! Wallet).name)
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
                self?.saveToAddressBook(addressText: addressText, name: text)
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
        let toAddress = self.walletAddressView.textField.text ?? ""
        if let wallet = AssetVCSharedData.sharedData.selectedWallet as? Wallet{
            if toAddress.ishexStringEqual(other: wallet.address){
                AssetViewControllerV060.getInstance()?.showMessage(text: Localized("cannot_send_itself"))
                return
            }
        }
        
        confirmPopUpView = PopUpViewController()
        let confirmView = UIView.viewFromXib(theClass: TransferConfirmView.self) as! TransferConfirmView
        confirmView.submitBtn.addTarget(self, action: #selector(onConfirmButton), for: .touchUpInside)
        confirmPopUpView?.setCloseEvent(button: confirmView.closeButton)
        
        confirmPopUpView?.dismissCompletion = {
            
        }
        
        if let wallet = AssetVCSharedData.sharedData.selectedWallet as? Wallet{
            confirmPopUpView!.setUpConfirmView(view: confirmView, width: PopUpContentWidth)
            confirmView.hideExecutor()
            
            let unionAttr = NSAttributedString(string: " LAT", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)])
            let amountAttr = NSMutableAttributedString(string: amountView.textField.text!.displayForMicrometerLevel(maxRound: 8))
            amountAttr.append(unionAttr)
            confirmView.totalLabel.attributedText = amountAttr
            confirmView.toAddressLabel.text = walletAddressView.textField.text!.addressDisplayInLocal() ?? "--"
            confirmView.walletName.text = wallet.address.addressDisplayInLocal() ?? "--"
            let feeString = self.totalFee().divide(by: ETHToWeiMultiplier
                , round: 8)
            confirmView.feeLabel.text = feeString.ATPSuffix()

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
        if self.amountView.checkInvalidNow(showErrorMsg: false)!.0 && self.walletAddressView.checkInvalidNow(showErrorMsg: false)!.0{
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
    
    func textFieldViewUpdateHeight(atextFieldView: ATextFieldView) {
//        view.snp.updateConstraints { (make) in
//            make.height.equalTo(atextFieldView.internalHeight)
//        }
//        view.layoutIfNeeded()
    }
    
    
    // MARK: - PopUp
    
    func showPasswordInputPswAlert() { 
        
        var executorWallet : Wallet? 
        if let w = AssetVCSharedData.sharedData.selectedWallet as? Wallet{
            executorWallet = w
        }
        
        if executorWallet?.type == WalletType.ObservedWallet {
            return
        }
            
        let alertVC = AlertStylePopViewController.initFromNib()
        let style = PAlertStyle.passwordInput(walletName: AssetVCSharedData.sharedData.selectedWalletName)
        alertVC.onAction(confirm: {[weak self] (text, _) -> (Bool)  in
            let valid = CommonService.isValidWalletPassword(text ?? "")
            if !valid.0{
                alertVC.showInputErrorTip(string: valid.1)
                return false
            }
              
            alertVC.showLoadingHUD()
            WalletService.sharedInstance.exportPrivateKey(wallet: executorWallet!, password: (alertVC.textFieldInput?.text)!, completion: { (pri, err) in
                
                if (err == nil && (pri?.length)! > 0) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { 
                        AssetViewControllerV060.getInstance()?.showLoadingHUD()
                    })
                    
                    self?.doClassicTransfer(pri: pri!, data: nil)
                    alertVC.dismissWithCompletion()
                }else{
                    if let notnilAlertVC = self?.passwordInputAlert{
                        notnilAlertVC.hideLoadingHUD()
                    }
                    alertVC.showInputErrorTip(string: (err?.errorDescription)!)
                    alertVC.hideLoadingHUD()
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
    
    //MARK : - Notification
    
    @objc func DidNodeGasPriceUpdate(){
        DispatchQueue.global().async {
            let feeString = self.totalFee().divide(by: ETHToWeiMultiplier
                , round: 8)
            DispatchQueue.main.async {
                self.feeView.fee.text = feeString.ATPSuffix()
            }
        }
    }
    
    func checkSufficient(text: String?) -> (Bool, String){
        if text == nil{
            return (true,"")
        }
        guard let amountOfwei = BigUInt.mutiply(a: text!, by: ETHToWeiMultiplier) else {
            return (true, "")
        }
        var overflow = false
        
        let balance = getAvailbleBalance()
        var newBalance = BigUInt(String(balance))
        overflow = (newBalance?.subtractReportingOverflow(self.totalFee(), shiftedBy: 0))!
        if overflow{
            //balance < fee
            self.resportSufficiency(isSufficient: false)
            return (false,Localized("transferVC_Insufficient_balance"))
        }
        overflow = (newBalance?.subtractReportingOverflow(amountOfwei, shiftedBy: 0))!
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
            return (self.gasPrice?.multiplied(by: self.estimatedGas))!
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
        amountView.textField.text = maxSendAmout?.divide(by: ETHToWeiMultiplier, round: 8)
        let _ = amountView.checkInvalidNow(showErrorMsg: true)
        let _ = self.checkConfirmButtonAvailable()
    }
    
    func getAvailbleBalance() -> BigUInt {
        guard
            let balance = AssetService.sharedInstace.balances.first(where: { $0.addr.lowercased() == AssetVCSharedData.sharedData.selectedWalletAddress?.lowercased() }),
            let freeString = balance.free,
            let freeBalanceValue = BigUInt(freeString) else { return BigUInt.zero }
        
        return freeBalanceValue.floorToDecimal(round: (18 - 8))
    }
    
    //MARK: - Transfer
    
    func doClassicTransfer(pri: String, data: AnyObject?){
        
        AnalysisHelper.handleEvent(id: event_send, operation: .end)
        
        let from = AssetVCSharedData.sharedData.cWallet?.address
        let to = self.walletAddressView.textField.text!
        let amount = self.amountView.textField.text!
        let memo = ""
        
        let _ = TransactionService.service.sendAPTTransfer(from: from!, to: to, amount: amount, InputGasPrice: self.gasPrice!, estimatedGas: String(self.estimatedGas), memo: memo, pri: pri, completion: {[weak self] (result, txHash) in
            AssetViewControllerV060.getInstance()?.hideLoadingHUD(delay: 0.2)
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


