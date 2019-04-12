//
//  STransferConfrimView.swift
//  platonWallet
//
//  Created by matrixelement on 14/11/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift
import BigInt

let spacing = CGFloat(0)

let collectViewLeading = CGFloat(12)

let ConfrimItemWidth = (kUIScreenWidth - 15 * 2 - collectViewLeading * 2 - spacing * 4 )/5.0 - 2

class STransferConfirmView: UIView ,UICollectionViewDelegate,UICollectionViewDataSource{

    @IBOutlet weak var ConfirmTitle: UILabel!
    
    @IBOutlet weak var totalAssetLabel: UILabel!
    
    @IBOutlet weak var collectionViewContainer: UIView!
    
    @IBOutlet weak var collectionViewCHeight: NSLayoutConstraint!
 
    @IBOutlet weak var headerContainer: UIView!
    
    @IBOutlet weak var bottomContainer: UIView!
    
    @IBOutlet weak var confirmButton: PButton!
    
    @IBOutlet weak var rejectButton: PButton!
    
    @IBOutlet weak var fromAddressLabel: UILabel!
    
    @IBOutlet weak var copyButtonFrom: CopyButton!
    
    @IBOutlet weak var toAddressLabel: UILabel!
    
    @IBOutlet weak var copyButtonTo: CopyButton!
    
    @IBOutlet weak var typeLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var valueLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var walletNameLabel: UILabel!
    
    @IBOutlet weak var operationAreaHeight: NSLayoutConstraint!
    
    @IBOutlet weak var operationBtnHeight: NSLayoutConstraint!
    
    var operation : OperationAction?
    
    var confirmPopUpView : PopUpViewController?
    
    var approveGas : BigUInt?
    
    var revokeGas : BigUInt?
    
    let SWalletConfirmCellIdentifier = "SWalletConfirmCellIdentifier"
    
    var dataSource : [DeterminedResult] = []
    
    var t: STransaction?
    
    var sw: SWallet?
    
    //navigation from WalletDetailViewController
    var specifiedWallet : Wallet?
    
    weak var viewController : BaseViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        copyButtonFrom.attachTextView = fromAddressLabel
        copyButtonTo.attachTextView = toAddressLabel
        self.rejectButton.style = .gray
        self.confirmButton.style = .blue
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveTransactionUpdate(_:)), name:NSNotification.Name(DidUpdateTransactionByHashNotification) , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateSharedWalletTransactionList(_:)), name:NSNotification.Name(DidUpdateSharedWalletTransactionList_Notification) , object: nil)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let extraPedding = CGFloat(38)
        let h = self.bottomContainer.frame.size.height + extraPedding + self.headerContainer.frame.size.height
        if h  < self.frame.size.height{
            self.bottomContainer.frame = CGRect(x: self.bottomContainer.frame.origin.x,
                                                y: self.bottomContainer.frame.origin.y,
                                                width: self.bottomContainer.frame.size.width,
                                                height: self.frame.size.height - extraPedding - self.headerContainer.frame.size.height)
        }
    }
    
    func updateUI(transaction : STransaction){ 
        
        t = transaction
        let totalOwnerCount = sw?.owners.count
        let collViewNumber = ceilf(Float(totalOwnerCount!)*0.2)
        
        //for i in 0...Int(collViewNumber - 1){}
        let colletionView = self.newCollectionView(number : Int(collViewNumber))
        colletionView.isScrollEnabled = false
        collectionViewCHeight.constant = ConfrimItemWidth * CGFloat(collViewNumber)
        
        updateOperateArea(tx: t!)
        updateDisplayView(tx: t!) 
        
        dataSource.removeAll()
        if (t?.determinedResult.count)! > 0 {
            for item in (t?.determinedResult)!{
                dataSource.append(item)
            }
        }
        dataSource.sort { (result1, result2) -> Bool in
            return result1.operation > result2.operation
        }
        
        dataSource.sort { (result1, result2) -> Bool in
            if result1.operation == result2.operation &&
                result1.operation == OperationAction.undetermined.rawValue &&
                (result1.walletAddress?.ishexStringEqual(other: self.sw?.walletAddress))!{
                return true
            }
            return false
        }
        
        colletionView.reloadData()
        
    }
    
    func updateOperateArea(tx : STransaction){
        
        if (sw?.isWatchAccount)! || !(sw?.isOwner)!{
            setOperateAreaHidden(true)
            return
        }
        
        if tx.isWaitForConfirmation{
            setOperateAreaHidden(true)
            return
        }
        
        if specifiedWallet != nil{
            
            var isJointMember = false
            
            for item in tx.determinedResult{
                if !(specifiedWallet?.key?.address.ishexStringEqual(other: item.walletAddress))!{
                    continue
                }
                isJointMember = true
                if (item.operation == OperationAction.undetermined.rawValue){
                    self.setOperateAreaHidden(false)
                }else{
                    self.setOperateAreaHidden(true)
                }
                break
            }
            
            if !isJointMember{
                self.setOperateAreaHidden(true)
                return
            }
            
        }else{
            for item in tx.determinedResult{
                if !(item.walletAddress?.ishexStringEqual(other: sw?.walletAddress))!{
                    continue
                }
                if (item.operation == OperationAction.undetermined.rawValue){
                    self.setOperateAreaHidden(false)
                }else{
                    self.setOperateAreaHidden(true)
                }
                break
            }
        }
        

    }
    
    func setOperateAreaHidden(_ hidden: Bool){
        if hidden{
            self.operationAreaHeight.constant = 0
            self.operationBtnHeight.constant = 0
            self.confirmButton.isHidden = true
            self.rejectButton.isHidden = true
        }

    }
    
    func updateDisplayView(tx : STransaction){
        
        self.ConfirmTitle.text = Localized("MemberSignDetailVC_Confirms") + "(" + String(tx.approveNumber) + "/" + String(sw?.required ?? 0) + ")"
        self.fromAddressLabel.text = tx.contractAddress
        self.toAddressLabel.text = tx.to
        self.timeLabel.text = Date.toStanderTimeDescrition(millionSecondsTimeStamp: Int(tx.createTime))

        if let valueBn = BigUInt(tx.value!){
            self.valueLabel.text = valueBn.divide(by: ETHToWeiMultiplier, round: 8)
            self.totalAssetLabel.text = self.valueLabel.text
        }else{
            self.valueLabel.text = ""
            self.totalAssetLabel.text = self.valueLabel.text
        }
        
        if let _ = BigUInt(tx.fee!){
            //self.priceLabel.text = txFeeBn.divide(by: ETHToWeiMultiplier, round: 8).ATPSuffix()
            self.priceLabel.text = "-"
        }else{
            self.priceLabel.text = ""
        }
        
        self.walletNameLabel.text = sw?.name
        
        self.typeLabel.text = tx.transanctionTypeLazy?.localizedDesciption
        
    }
    
    func newCollectionView(number :Int) -> UICollectionView {
        
        let alignedFlowLayout : UICollectionViewFlowLayout
        
        if number == 1{
            alignedFlowLayout = JYEqualCellSpaceFlowLayout.init(.center, 0)
        }else{
            alignedFlowLayout = UICollectionViewFlowLayout.init()
        }
        
        alignedFlowLayout.itemSize = CGSize(width: ConfrimItemWidth, height: ConfrimItemWidth)
        alignedFlowLayout.minimumLineSpacing = CGFloat(0)
        alignedFlowLayout.minimumInteritemSpacing = CGFloat(spacing)
        alignedFlowLayout.scrollDirection = .vertical
        
        let collectionView = UICollectionView.init(frame: CGRect(x:0, y:0, width:0, height:0), collectionViewLayout: alignedFlowLayout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionViewContainer.addSubview(collectionView)
         
        // 注册cell
        collectionView.register(UINib.init(nibName: String(describing: SWalletConfirmCell.self), bundle: nil), forCellWithReuseIdentifier: SWalletConfirmCellIdentifier)
        
        collectionView.snp.makeConstraints({ (make) in
            make.bottom.top.equalToSuperview()
            make.leading.equalToSuperview().offset(collectViewLeading)
            make.trailing.equalToSuperview().offset(-collectViewLeading)
        })
        
        return collectionView
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard sw != nil else {
            return 0
        }
        return (sw?.owners.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: SWalletConfirmCell = collectionView.dequeueReusableCell(withReuseIdentifier: SWalletConfirmCellIdentifier, for: indexPath) as! SWalletConfirmCell
        
        let result = dataSource[indexPath.row]
        let copyResult = DeterminedResult(value: result as Any)
        
        cell.updateCell(result: copyResult, transaction: self.t!, swallet: self.sw!,specifyWallet: specifiedWallet)

        return cell
    }
    
    func showInputPswAlertWithExportPrivateKey(completion: @escaping (_ sender: String, _ privateKey : String) -> ()) {
        
        var wallet : Wallet?
        if self.specifiedWallet != nil{
            wallet = self.specifiedWallet
        }else{
            wallet = SWalletService.sharedInstance.getATPWalletByAddress(address: (self.sw?.walletAddress)!)
        }
        guard wallet != nil else{
            return
        }
        
        let alertVC = AlertStylePopViewController.initFromNib()
        let style = PAlertStyle.passwordInput(walletName: wallet?.name) 
        alertVC.onAction(confirm: {[weak self] (text, _) -> (Bool)  in
            let valid = CommonService.isValidWalletPassword(text ?? "")
            if !valid.0{
                alertVC.showInputErrorTip(string: valid.1)
                return false
            } 
            self?.viewController?.showLoadingHUD()
            WalletService.sharedInstance.exportPrivateKey(wallet: wallet!, password: (alertVC.textFieldInput?.text)!, completion: { (pri, err) in
                self?.viewController?.hideLoadingHUD()
                if (err == nil && (pri?.length)! > 0) {
                    completion((wallet?.key?.address)!, pri!)
                    alertVC.dismissWithCompletion()
                }else{
                    alertVC.showInputErrorTip(string: (err?.errorDescription)!)
                }
            })
            return false
            
        }) { (_, _) -> (Bool) in
            return true
        }
        alertVC.style = style
        alertVC.showInViewController(viewController: self.viewController!)
        alertVC.textFieldInput.becomeFirstResponder()

    }
    
    @IBAction func onConfirm(_ sender: Any) {
        
        if TransactionService.service.ethGasPrice == nil{
            self.viewController?.showMessage(text: Localized("RPC_Response_serverError"))
            TransactionService.service.getEthGasPrice(completion: nil)
            return
        }
        
        operation = OperationAction.approval
        self.viewController?.showLoadingHUD()
        SWalletService.sharedInstance.estimateConfirmTransaction(contractAddress: (self.sw?.contractAddress)!, transactionId: UInt64(self.t!.transactionID)!) { (result, data) in
            self.viewController?.hideLoadingHUD()
            switch result{
            case .success:
                let gas = data as? BigUInt
                self.showCreateContractFee(gasPrice: gas!, gas: TransactionService.service.ethGasPrice!)
                self.approveGas = gas
            case .fail(let code, let errMsg):
                self.viewController!.showMessageWithCodeAndMsg(code: code!, text: errMsg!, delay: 2.5)
            }
        }
    }
    
    @IBAction func onReject(_ sender: Any) {
        
        if TransactionService.service.ethGasPrice == nil{
            self.viewController?.showMessage(text: Localized("RPC_Response_serverError"))
            TransactionService.service.getEthGasPrice(completion: nil)
            return
        }
        
        operation = OperationAction.revoke
        self.viewController?.showLoadingHUD()
        SWalletService.sharedInstance.estimateRevokeConfirmation(contractAddress: (self.sw?.contractAddress)!, transactionId: UInt64(self.t!.transactionID)!) { (result, data) in
            self.viewController?.hideLoadingHUD()
            switch result{
            case .success:
                let gas = data as? BigUInt
                self.showCreateContractFee(gasPrice: gas!, gas: TransactionService.service.ethGasPrice!)
                self.revokeGas = gas
            case .fail(let code, let errMsg):
                self.viewController!.showMessageWithCodeAndMsg(code: code!, text: errMsg!, delay: 2.5)
            }
        }
        
    }
    
    func showCreateContractFee(gasPrice: BigUInt,gas: BigUInt){
        
        confirmPopUpView = PopUpViewController()
        let confirmView = UIView.viewFromXib(theClass: JointWalletCreationFeeConfirmView.self) as! JointWalletCreationFeeConfirmView
        confirmView.setViewType(.ExecuteContract)
        confirmView.submitButton.addTarget(self, action: #selector(onFinalSubmit), for: .touchUpInside)
        confirmPopUpView?.setUpContentView(view: confirmView, size: CGSize(width: PopUpContentWidth, height: 292))
        confirmPopUpView?.setCloseEvent(button: confirmView.closeButton)
        
        let fee = gas.multiplied(by: gasPrice)
        let feeDescription = fee.divide(by: ETHToWeiMultiplier, round: 8).balanceFixToDisplay(maxRound: 8)
        
        confirmView.feeLabel.text = feeDescription
        confirmPopUpView?.show(inViewController: self.viewController!)
    } 
    
    @objc func onFinalSubmit(){
        confirmPopUpView?.onDismissViewController()
        if operation == .revoke{
            self.showInputPswAlertWithExportPrivateKey { [weak self](sender,privateKey) in
                SWalletService.sharedInstance.revokeConfirmation(walltAddress: sender, privateKey: privateKey, contractAddress: (self?.sw?.contractAddress)!, gasPrice: TransactionService.service.ethGasPrice!, gas: self?.revokeGas! ?? revoke_StipulatedGas, tx: self!.t!, estimated: false, completion: { (result, data) in
                    self?.viewController?.hideLoadingHUD()
                    switch result{
                        
                    case .success:
                        UIApplication.rootViewController().showMessage(text: Localized("ConfrimVC_Revoke_success"))
                        self?.updateData()
                        //self.viewController?.navigationController?.popViewController(animated: true)
                    case .fail(let code, let errMsg):
                        self?.viewController!.showMessageWithCodeAndMsg(code: code!, text: errMsg!)
                    }
                })
            }
        }else if operation == .approval{
            
            self.showInputPswAlertWithExportPrivateKey { [weak self](sender, privateKey) in
                SWalletService.sharedInstance.confirmTransaction(walltAddress: sender, privateKey: privateKey, contractAddress: (self?.sw?.contractAddress)!, gasPrice: TransactionService.service.ethGasPrice!, gas: self?.approveGas! ?? approve_StipulatedGas, tx: self!.t!, estimated: false, completion: { (result, data) in
                    self?.viewController?.hideLoadingHUD()
                    switch result{
                    case .success:
                        UIApplication.rootViewController().showMessage(text: Localized("ConfrimVC_approve_success"))
                        self?.updateData()
                        //self.viewController?.navigationController?.popViewController(animated: true)
                    case .fail(let code, let errMsg):
                        self?.viewController?.showMessageWithCodeAndMsg(code: code!, text: errMsg!, delay: 2.5)
                    }
                })
            }
        }
    }
    
    func updateData(){
        if let tx = STransferPersistence.getByTxhash(self.t?.txhash){
            self.updateUI(transaction: tx)
            self.viewController?.hideLoadingHUD()
        }
    }
    
    //MAKR: - Notification
    @objc func didReceiveTransactionUpdate(_ notification: Notification){
        guard let hash = notification.object as? String  else {
            return
        }
        if hash.ishexStringEqual(other: self.t?.txhash){
            self.updateData()
        }
    }
    
    @objc func didUpdateSharedWalletTransactionList(_ notification: Notification){
        DispatchQueue.main.async {
            self.updateData()
        }
    }
    
    func willDeinit(){
        self.t = nil
        self.sw = nil
        self.viewController = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        print(String(describing: self) + "no circular refrence ")
    }

    
}
