//
//  TransactionViewControllerV060.swift
//  platonWallet
//
//  Created by juzix on 2019/3/5.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift

protocol ChildScrollViewDidScrollDelegate: AnyObject {
    func childScrollViewDidScroll(childScrollView: UIScrollView)
}

class MultiGestureTableView: UITableView {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        //return true
        return true
    } 
}

class AssetTransactionViewControllerV060: BaseViewController, EmptyDataSetDelegate,EmptyDataSetSource {

    @IBOutlet weak var tableView: MultiGestureTableView!
    
    weak var delegate: ChildScrollViewDidScrollDelegate?
    
    var dataSource = [String: [Transaction]]()
    
    var localDataSource = [String: [Transaction]]()
    
    
    var walletAddress : String?
    
    var transactionsTimer: Timer? = nil
    
    var assetHeaderHide = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self 
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.emptyDataSetView { [weak self] view in
            let holder = self?.emptyViewForTableView(forEmptyDataSet: (self?.tableView)!, nil,"empty_no_data_img") as? TableViewNoDataPlaceHolder
            view.customView(holder)
        }
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
        tableView.registerCell(cellTypes: [WalletDetailCell.self])
        
        self.walletAddress = AssetVCSharedData.sharedData.selectedWalletAddress
        AssetVCSharedData.sharedData.registerHandler(object: self) {[weak self] in
            self?.walletAddress = AssetVCSharedData.sharedData.selectedWalletAddress
            self?.refreshData()
            self?.tableView.reloadData()
        }
        self.setplaceHolderBG(hide: true,tableView: tableView)
         
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        NotificationCenter.default.addObserver(self, selector: #selector(willDeleteWallet(_:)), name: NSNotification.Name(WillDeleateWallet_Notification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateWalletList), name: NSNotification.Name(updateWalletList_Notification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(nodeDidSwitch), name: NSNotification.Name(NodeStoreService.didSwitchNodeNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(initClassicData), name: NSNotification.Name(DidAddVoteTransactionNotification), object: nil)
    }
   
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setHeaderStyle(hide: Bool){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { 
            self.tableView.reloadData()
            self.assetHeaderHide = hide
            self.setplaceHolderBG(hide: hide,tableView: self.tableView)
        }
    }

}

// MARK: - business logic

extension AssetTransactionViewControllerV060{
    
    func refreshData(){
        commonInit()
        initClassicData()
        if AssetVCSharedData.sharedData.walletList.count == 0{
            self.tableNodataHolderView.descriptionLabel.localizedText = "IndividualWallet_EmptyView_tips"
        }else{
            self.tableNodataHolderView.descriptionLabel.localizedText = "walletDetailVC_no_transactions_text"
        }
    }
    
    func commonInit(){
        
        if transactionsTimer == nil {
            transactionsTimer = Timer.scheduledTimer(timeInterval:TimeInterval(jointWalletUpdateTxListTimerInterval), target: self, selector: #selector(pollingWalletTransactions), userInfo: nil, repeats: true)
        }
    }
    
    @objc func initClassicData() {
        guard let selectedAddress = AssetVCSharedData.sharedData.selectedWalletAddress else { return }
        var transactions = TransferPersistence.getAllByAddress(from: selectedAddress)
        transactions.txSort()
        
        guard let existTxs = dataSource[selectedAddress], existTxs.count > 0 else {
            dataSource[selectedAddress] = transactions
            return
        }
        
        let txHashes = existTxs.map { $0.txhash! }
        let newTxs = transactions.filter { !txHashes.contains($0.txhash!) }
        dataSource[selectedAddress]?.insert(contentsOf: newTxs, at: 0)
        tableView.reloadData()
    }
    
    //MARK: - Notification
    
    @objc func willDeleteWallet(_ notification: Notification){
        guard self.walletAddress != nil else {
            return 
        }
        if let cwallet = notification.object as? Wallet{
            if (self.walletAddress?.ishexStringEqual(other: cwallet.key?.address))!{
                self.dataSource[self.walletAddress!]?.removeAll()
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func updateWalletList(){
        self.refreshData()
    }
    
    @objc func nodeDidSwitch(){
        dataSource = [String: [Transaction]]()
        self.tableView.reloadData()
    }
    
    
    
    func fetchTransaction(beginSequence: Int, direction: String) {
        guard let selectedAddress = AssetVCSharedData.sharedData.selectedWalletAddress else { return }
        TransactionService.service.getBatchTransaction(addresses: [selectedAddress], beginSequence: beginSequence, listSize: 20, direction: direction) { (result, response) in
            switch result {
            case .success:
                if beginSequence == -1 {
                    let _ = self.dataSource[selectedAddress]?.filter { $0.sequence != nil }
                    self.tableView.reloadData()
                }
                
                guard let transactions = response as? [Transaction], transactions.count > 0 else { return }
                if beginSequence != -1 && direction == "new" {
                    AssetService.sharedInstace.fetchWalletBanlance()
                }
                
                guard let selectedAddress = AssetVCSharedData.sharedData.selectedWalletAddress else { return }
                if let existTxs = self.dataSource[selectedAddress], existTxs.count > 0 {
                    let txHashes = transactions.map { $0.txhash! }
                    
                    self.dataSource[selectedAddress] = self.dataSource[selectedAddress]?.filter { !txHashes.contains($0.txhash!) }
                    if direction == "new" && beginSequence > -1 {
                        self.dataSource[selectedAddress]?.insert(contentsOf: transactions, at: 0)
                    } else {
                        self.dataSource[selectedAddress]?.append(contentsOf: transactions)
                    }
                } else {
                    self.dataSource[selectedAddress] = transactions
                }
                
//                self.dataSource[selectedAddress]?.removingDuplicates()
                self.tableView.reloadData()
            case .fail(_, let error):
                break
            }
        }
    }
    
    func fetchTransactionLastest() {
        fetchTransaction(beginSequence: -1, direction: "new")
    }
    
    @objc func pollingWalletTransactions() {
        guard let selectedAddress = AssetVCSharedData.sharedData.selectedWalletAddress else { return }
        guard let lastestTransaction = dataSource[selectedAddress]?.firstTransactionNoNilSequence() else {
            fetchTransactionLastest()
            return
        }
        
        guard let sequence = Int(lastestTransaction.sequence ?? "0") else { return }
        fetchTransaction(beginSequence: sequence, direction: "new")
    }
    
    func fetchTransactionMore() {
        guard let selectedAddress = AssetVCSharedData.sharedData.selectedWalletAddress else { return }
        guard let lastTransaction = dataSource[selectedAddress]?.last else {
            fetchTransactionLastest()
            return
        }
        
        guard let sequenceString = lastTransaction.sequence, let sequence = Int(sequenceString) else {
            return
        }
        fetchTransaction(beginSequence: sequence, direction: "old")
    }
}
 
extension AssetTransactionViewControllerV060: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let selectedAddress = AssetVCSharedData.sharedData.selectedWalletAddress else { return 0 }
        return dataSource[selectedAddress]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let wallet = AssetVCSharedData.sharedData.selectedWallet
        let cell : WalletDetailCell = tableView.dequeueReusableCell(withIdentifier: String(describing: WalletDetailCell.self)) as! WalletDetailCell
        if let selectedAddress = AssetVCSharedData.sharedData.selectedWalletAddress, let count = dataSource[selectedAddress]?.count, count > indexPath.row {
            let tx = dataSource[selectedAddress]?[indexPath.row]
            cell.updateTransferCell(transaction: tx, wallet: wallet as? Wallet)
            cell.updateCellStyle(count: dataSource[selectedAddress]?.count ?? 0, index: indexPath.row)
        }
        
        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.childScrollViewDidScroll(childScrollView: scrollView)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 69
    }
     
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedAddress = AssetVCSharedData.sharedData.selectedWalletAddress else { return }
        let tx = dataSource[selectedAddress]?[indexPath.row]
        let transferVC = TransactionDetailViewController()
        transferVC.transaction = tx
        AssetViewControllerV060.pushViewController(viewController: transferVC)
    }
    
}

//MARK: - Asset60

extension AssetTransactionViewControllerV060{
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat{
        let edgeToTop = (self.tableView.frame.size.height - self.tableNodataHolderView.frame.size.height) * 0.5
        return -edgeToTop
    }
}
