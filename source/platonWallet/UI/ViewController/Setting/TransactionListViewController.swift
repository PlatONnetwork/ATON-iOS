//
//  TransactionListViewController.swift
//  platonWallet
//
//  Created by matrixelement on 1/11/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift
import MJRefresh

class TransactionListViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource {
    
    let listSize = 20

    let tableView = UITableView()
    
    var dataSource : [Transaction] = []
    
    lazy var refreshHeader: MJRefreshHeader = {
        let header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(fetchTransactionLastest))!
        return header
    }()
    
    lazy var refreshFooter: MJRefreshFooter = {
        let footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(fetchTransactionMore))!
        return footer
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSubView()
        tableView.mj_header.beginRefreshing()
    }
    
    @objc func fetchTransactionLastest() {
        let addressStrs = AssetVCSharedData.sharedData.walletList.filterClassicWallet.map { cwallet in
            return cwallet.key!.address
        }
        guard addressStrs.count > 0 else {
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            return
        }
        fetchTransaction(addressStrs: addressStrs, beginSequence: -1, direction: "new")
    }
    
    @objc func fetchTransactionMore() {
        let addressStrs = AssetVCSharedData.sharedData.walletList.filterClassicWallet.map { cwallet in
            return cwallet.key!.address
        }
        guard addressStrs.count > 0 else {
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            return
        }
        
        guard let lastTransaction = dataSource.last else {
            return
        }
        
        guard let sequence = Int(lastTransaction.sequence ?? "0") else { return }
        fetchTransaction(addressStrs: addressStrs, beginSequence: sequence, direction: "old")
    }
    
    func fetchTransaction(addressStrs: [String], beginSequence: Int, direction: String) {
        TransactionService.service.getBatchTransaction(addresses: addressStrs, beginSequence: beginSequence, listSize: listSize, direction: direction) { (result, response) in
            
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            
            switch result {
            case .success:
                if beginSequence == -1 {
                    self.dataSource.removeAll()
                    self.tableView.reloadData()
                }
                
                guard let transactions = response as? [Transaction], transactions.count > 0 else {
                    return
                }
                
                if transactions.count >= self.listSize {
                    self.tableView.mj_footer.resetNoMoreData()
                } else {
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                }
                
                if beginSequence != -1 && direction == "new" {
                    
                    AssetService.sharedInstace.fetchWalletBanlance()
                }
                
                self.dataSource.append(contentsOf: transactions)
                self.tableView.reloadData()
                self.tableView.mj_footer.isHidden = self.dataSource.count == 0
            case .fail(_, let error):
                break
            }
        }
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
            view.customView(self?.emptyViewForTableView(forEmptyDataSet: (self?.tableView)!, Localized("walletDetailVC_no_transactions_text"),"empty_no_data_img"))
        }
        
        tableView.mj_header = refreshHeader
        tableView.mj_footer = refreshFooter
        tableView.mj_footer.isHidden = true
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
        let transferVC = TransactionDetailViewController()
        transferVC.transaction = dataSource[indexPath.row]
        transferVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(transferVC, animated: true)
    }

}
