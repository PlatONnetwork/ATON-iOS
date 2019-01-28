//
//  STransferResultView.swift
//  platonWallet
//
//  Created by matrixelement on 15/11/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift
import BigInt

class STransferDetailView: UIView ,UITableViewDataSource,UITableViewDelegate{

    
    
    @IBOutlet weak var statusImageView: UIImageView!
    
    @IBOutlet weak var bottomContainer: UIView!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var ConfirmTitle: UILabel!
    
    @IBOutlet weak var headerContainer: UIView!
    
    
    @IBOutlet weak var tableViewContainer: UIView!
    
    @IBOutlet weak var collectionViewCHeight: NSLayoutConstraint!
    
    @IBOutlet weak var fromAddressLabel: UILabel!
    
    @IBOutlet weak var copyButtonFrom: CopyButton!
    
    @IBOutlet weak var toAddressLabel: UILabel!
    
    @IBOutlet weak var copyButtonTo: CopyButton!
    
    @IBOutlet weak var typeLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var valueLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var walletNameLabel: UILabel!
    
    @IBOutlet weak var memoLabel: UILabel!

    @IBOutlet weak var hashLabel: UILabel!
    
    @IBOutlet weak var hashDes: UILabel!
    
    @IBOutlet weak var hashContainer: UIView!
    
    @IBOutlet weak var hashDesHeight: NSLayoutConstraint!
    
    @IBOutlet weak var hashContainerHeight: NSLayoutConstraint!
    
    var t: STransaction?
    
    var sw: SWallet?
    
    let tableView = UITableView(frame: .zero)
    
    var dataSource : [DeterminedResult] = []
    
    
    override func awakeFromNib() {
        self.hashDes.isHidden = true
        self.hashContainer.isHidden = true
        
        self.hashDesHeight.constant = 0
        self.hashContainerHeight.constant = 0
        
        copyButtonFrom.attachTextView = fromAddressLabel
        copyButtonTo.attachTextView = toAddressLabel
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveTransactionUpdate(_:)), name:NSNotification.Name(DidUpdateTransactionByHashNotification) , object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(txlistUpdate), name: NSNotification.Name(DidUpdateSharedWalletTransactionList_Notification), object: nil)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let extraPedding = CGFloat(170)
        let h = self.bottomContainer.frame.size.height + extraPedding + self.headerContainer.frame.size.height
        if h  < self.frame.size.height{
            self.bottomContainer.frame = CGRect(x: self.bottomContainer.frame.origin.x,
                                                y: self.bottomContainer.frame.origin.y,
                                                width: self.bottomContainer.frame.size.width,
                                                height: self.frame.size.height - extraPedding - self.headerContainer.frame.size.height)
        }
    }
    
    func updateUI(transaction : STransaction, swallet: SWallet){
        t = transaction
        newTableView(t: t!)
        sw = swallet
        
        dataSource.removeAll()
        for item in transaction.determinedResult{
            if item.operation != OperationAction.undetermined.rawValue{
                dataSource.append(item)
            }
        }
        
        dataSource.sort { (result1, result2) -> Bool in
            return result1.operation > result2.operation
        }
        
        if transaction.transactionCategory != TransanctionCategory.ATPTransfer.rawValue{
            headerContainer.isHidden = true
            collectionViewCHeight.constant = 0
            /*
            tableView.snp.remakeConstraints { (make) in
                make.edges.equalTo(tableView.superview!)
            }
            ConfirmTitle.snp.remakeConstraints { (make) in
                make.edges.equalTo(ConfirmTitle.superview!)
            }
             */
            tableView.reloadData()
        }else{
            collectionViewCHeight.constant = CGFloat(51 * (dataSource.count))
            collectionViewCHeight.constant = CGFloat((dataSource.count) * 60)
            tableView.reloadData()
        }
        

    
        self.updateTransactionDetail(tx: transaction, swallet: swallet)
        
    }
    
    func updateTransactionDetail(tx : STransaction, swallet: SWallet){
        
        if let valueBn = BigUInt(tx.value!){
            self.valueLabel.text = valueBn.divide(by: ETHToWeiMultiplier, round: 8).ATPSuffix()
        }else{
            self.valueLabel.text = ""
        }
    
        self.walletNameLabel.text = sw?.name
        
        if (tx.memo != nil) && (tx.memo?.length)! > 0{
            self.memoLabel.text = tx.memo
        }else{
            self.memoLabel.localizedText = "TransactionDetailVC_memo_none"
        }
        
        self.typeLabel.text = tx.transanctionTypeLazy?.localizedDesciption
        
        var approvals = 0
        for item in tx.determinedResult{
            if item.operation == OperationAction.approval.rawValue || item.operation == OperationAction.revoke.rawValue{
                approvals = approvals + 1
            }
        }
        ConfirmTitle.text = String(format: "%@ (%d/%d) :", Localized("SharedWalletDetailVC_Confirmations"),approvals,swallet.required)
        
        fromAddressLabel.text = tx.contractAddress
        toAddressLabel.text = tx.to
        timeLabel.text = Date.toStanderTimeDescrition(millionSecondsTimeStamp: Int(tx.createTime))
        
        if tx.transactionCategory == TransanctionCategory.ATPTransfer.rawValue{
            self.priceLabel.text = "-"
        }else{
            
            if let txFeeBn = BigUInt(tx.fee!){
                self.priceLabel.text = txFeeBn.divide(by: ETHToWeiMultiplier, round: 8).ATPSuffix()
            }else{
                self.priceLabel.text = ""
            }
        }
        
        
        if tx.transactionCategory == TransanctionCategory.ATPTransfer.rawValue{
            if (tx.txhash?.length)! > 0  {
                
                if (tx.blockNumber?.length)! > 0{
                    guard TransactionService.service.lastedBlockNumber != nil, (TransactionService.service.lastedBlockNumber?.length)! > 0 else{
                        //netwrok unavailable
                        statusImageView.image = UIImage(named: "statusPending")
                        statusLabel.text = "--"
                        return
                    }
                    
                    /*
                    let lastedBlockNumber = BigUInt(TransactionService.service.lastedBlockNumber!)
                    let txBlockNumber = BigUInt((tx.blockNumber)!)
                    let blockDiff = BigUInt.safeSubStractToUInt64(a: lastedBlockNumber!, b: txBlockNumber!)
                    if Int64(blockDiff) < MinTransactionConfirmations{
                        //confriming
                        statusImageView.image = UIImage(named: "statusPending")
                        statusLabel.text = String(format: "%@(%d/%d)", Localized("walletDetailVC_tx_status_confirming"),blockDiff,MinTransactionConfirmations)
                        statusLabel.textColor = UIColor(rgb: 0xFFED54)
                    }else{
                        self.transactionReachTrustworthyStatus(tx: tx, swallet: swallet)
                    }
                    */
                    
                    self.transactionReachTrustworthyStatus(tx: tx, swallet: swallet)
                    
                }else{
                    //pending
                    statusImageView.image = UIImage(named: "statusPending")
                    statusLabel.text = String(format: "%@", Localized("walletDetailVC_tx_status_confirming"),0,MinTransactionConfirmations)
                    statusLabel.textColor = UIColor(rgb: 0xFFED54)
                }
                
            }else{
                //no txhash, transfer transaction from other co-account holders
                self.transactionReachTrustworthyStatus(tx: tx, swallet: swallet)
            }
        }else if tx.transanctionCategoryLazy == TransanctionCategory.JointWalletCreation ||
             tx.transanctionCategoryLazy == TransanctionCategory.JointWalletExecution ||
             tx.transanctionCategoryLazy == TransanctionCategory.JointWalletSubmit ||
             tx.transanctionCategoryLazy == TransanctionCategory.JointWalletApprove ||
             tx.transanctionCategoryLazy == TransanctionCategory.JointWalletRevoke{
            
            if tx.isWaitForConfirmation{
                statusImageView.image = UIImage(named: "statusPending")
                statusLabel.text = String(format: "%@", Localized("walletDetailVC_tx_status_confirming"),0,MinTransactionConfirmations)
                statusLabel.textColor = UIColor(rgb: 0xFFED54)
            }else{
                //success
                statusImageView.image = UIImage(named: "statusSuccess")
                statusLabel.localizedText = "MemberSignDetailVC_transfer_success"
                typeLabel.localizedText = "STranctionType_create"
            }

        }

    }
    
    func transactionReachTrustworthyStatus(tx : STransaction, swallet: SWallet) {
        
        //update header
        if ((t?.executed)!) {
            statusImageView.image = UIImage(named: "statusSuccess")
            statusLabel.localizedText = "MemberSignDetailVC_transfer_success"
        }else if (!(t?.executed)!){
            
            if t?.signStatus == SignStatus.voting{
                
                statusLabel.text = String(format: "%@(%d/%d)", Localized("walletDetailVC_no_transactions_Signing"),(t?.approveNumber)!,swallet.required)
                statusLabel.textColor = UIColor(rgb: 0xFFED54)
                statusImageView.image = UIImage(named: "statusPending")
                
                assert(false, "should be in ShareWalletConfirmVC not me!")
                
            }else if t?.signStatus == SignStatus.reachApproval {
                
                statusImageView.image = UIImage(named: "statusFail")
                statusLabel.localizedText = "Transaction.Fail"
                /*
                if tx.pending{
                    // all member sign ,wait for contract call transfer action
                    statusImageView.image = UIImage(named: "statusPending")
                    statusLabel.localizedText = "walletDetailVC_tx_status_confirming"
                }else{
                    //no pending,and exected == false, insufficient fund or node fatal malfunction
                    statusImageView.image = UIImage(named: "statusSuccess")
                    statusLabel.localizedText = "MemberSignDetailVC_transfer_success"
                    //assert(false, "should not be in in this status!")
                }
                */
 
                }else if t?.signStatus == SignStatus.reachRevoke{
                    statusImageView.image = UIImage(named: "statusFail")
                    statusLabel.localizedText = "Transaction.Fail"
            }
            
        }

    }
    
    func newTableView(t : STransaction) {
    
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.registerCell(cellTypes: [MemberOperTableViewCell.self])
        tableView.tableFooterView = UIView()
        
        self.tableViewContainer.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MemberOperTableViewCell.self), for: indexPath) as! MemberOperTableViewCell
        let result = dataSource[indexPath.row]
        cell.updateCell(result: result, swallet: sw!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    //MARK: - Notification
    
    @objc func didReceiveTransactionUpdate(_ notification: Notification){
        
        guard let hash = notification.object as? String  else {
            return
        }
        
        
        if hash.ishexStringEqual(other: self.t?.txhash){
            let tx = STransferPersistence.getByTxhash(self.t?.txhash)
            if tx != nil{
                self.updateUI(transaction: tx!, swallet: sw!)
            }
        }
        
    }
    
    @objc func txlistUpdate(){
        
    }
}


