//
//  TransferInfoViewController.swift
//  platonWallet
//
//  Created by matrixelement on 26/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class TransactionDetailViewController: BaseViewController {
    
    public var transaction : AnyObject?
    public var wallet : Wallet?
    
    let transferDetailView = UIView.viewFromXib(theClass: TransferDetailView.self) as! TransferDetailView

    override func viewDidLoad() {
        super.viewDidLoad()
        initSubViews()
        super.leftNavigationTitle = "TransactionDetailVC_nav_title"
       
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveTransactionUpdate(_:)), name:NSNotification.Name(DidUpdateTransactionByHashNotification) , object: nil)
    }
    
    @objc func didReceiveTransactionUpdate(_ notification: Notification){
        guard let hash = notification.object as? String  else {
            return
        }
        if hash.ishexStringEqual(other: transaction?.txhash){
            let tx = TransferPersistence.getByTxhash(transaction?.txhash)
            if tx != nil{
                transferDetailView.updateContent(tx: tx! as AnyObject,wallet : wallet ?? nil)
            }
        }
        
    }
    
    func initSubViews() {
        view.addSubview(transferDetailView)
        transferDetailView.snp.makeConstraints { (make) in
                make.leading.trailing.top.bottom.equalTo(view)
            }
        transferDetailView.updateContent(tx: transaction! as AnyObject,wallet : wallet ?? nil)
    }
}
