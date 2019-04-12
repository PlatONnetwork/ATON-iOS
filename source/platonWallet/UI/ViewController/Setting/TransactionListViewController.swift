//
//  TransactionListViewController.swift
//  platonWallet
//
//  Created by matrixelement on 1/11/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class TransactionListViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource {

    let tableView = UITableView()
    
    var dataSource : [AnyObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSubView()
        initData()
    }
    
    func initData(){
        dataSource.removeAll()
        let data = TransferPersistence.getAll()
        dataSource.append(contentsOf: data)
        
        let sdata = STransferPersistence.getAllTransactionForTransactionList()
        dataSource.append(contentsOf: sdata)
        dataSource.txSort()
        tableView.reloadData()
    }

    func initSubView(){
        
        tableView.backgroundColor = UIViewController_backround
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        tableView.registerCell(cellTypes: [TransactionCell.self])
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(0)
            make.right.equalToSuperview().offset(0)
        }
        
        super.leftNavigationTitle = "TransactionListVC_nav_title"
        tableView.emptyDataSetView { [weak self] view in
            view.customView(self?.emptyViewForTableView(forEmptyDataSet: (self?.tableView)!, Localized("walletDetailVC_no_transactions_text")))
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TransactionCell.self)) as! TransactionCell 
        let tx = dataSource[indexPath.row]
        cell.updateCell(tx: tx)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 69
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let tx = dataSource[indexPath.row]
        
        if let tx = tx as? Transaction{
            for wallet in WalletService.sharedInstance.wallets{
                if(wallet.key?.address == tx.from){
                    let transferVC = TransactionDetailViewController()
                    transferVC.transaction = tx
                    transferVC.wallet = wallet
                    transferVC.hidesBottomBarWhenPushed = true
                    navigationController?.pushViewController(transferVC, animated: true)
                    break
                }
            }
        }else if let tx = tx as? STransaction{
            let vc = self.router(stransaction: tx)
            navigationController?.pushViewController(vc, animated: true)
        }

        

    }

}
