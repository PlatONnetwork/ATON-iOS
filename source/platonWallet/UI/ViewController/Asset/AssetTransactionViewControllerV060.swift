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
    
    var dataSource : [AnyObject]? = [] 
    
    var walletAddress : String?
    
    var timer : Timer? = nil
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateSharedWalletTransaction), name: NSNotification.Name(DidUpdateSharedWalletTransactionList_Notification), object: nil)

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
        initJointData()
        if AssetVCSharedData.sharedData.walletList.count == 0{
            self.tableNodataHolderView.descriptionLabel.localizedText = "IndividualWallet_EmptyView_tips"
        }else{
            self.tableNodataHolderView.descriptionLabel.localizedText = "walletDetailVC_no_transactions_text"
        }
    }
    
    func commonInit(){
        if jointWalletUpdateTxListTimerEnable{
            if timer == nil{
                timer = Timer.scheduledTimer(timeInterval:TimeInterval(jointWalletUpdateTxListTimerInterval), target: self, selector: #selector(pollingJointWalletTransaction), userInfo: nil, repeats: true)
            }
        }
    }
    
    func initClassicData() {
        if let _ = AssetVCSharedData.sharedData.selectedWallet as? Wallet{
            let wallet = AssetVCSharedData.sharedData.cWallet
            dataSource?.removeAll()
            let data = TransferPersistence.getAllByAddress(from: (wallet?.key?.address)!)
            
            dataSource?.append(contentsOf: data)
            var jointTxs : [STransaction] = []
            jointTxs.append(contentsOf:STransferPersistence.getAllByWalletOwner(address: (wallet?.key?.address)!))
            jointTxs.append(contentsOf:STransferPersistence.getAllATPTransferByReceiveAddress((wallet?.key?.address)!))
            jointTxs = jointTxs.removeDuplicate { $0.uuid }
            
            dataSource?.append(contentsOf: jointTxs)
            dataSource?.txSort()
            tableView.reloadData()
        }
    }
    
    func initJointData() {
        self.didUpdateSharedWalletTransaction()
    }
    
    @objc func pollingJointWalletTransaction(){
        
        initJointData()
        initClassicData()
        
        if let swallet = AssetVCSharedData.sharedData.selectedWallet as? SWallet{
            SWalletService.sharedInstance.getTransactionList(contractAddress: (swallet.contractAddress), sender: (swallet.walletAddress), from: 0, to: UInt64.max) { (ret, data) in
                switch ret{
                case .success:   
                    do{}
                case .fail(_, _):
                    do{}
                }
            }
        }else if let wallet = AssetVCSharedData.sharedData.selectedWallet as? Wallet{
            for swallet in wallet.getAssociatedJointWallets(){
                SWalletService.sharedInstance.getTransactionList(contractAddress: (swallet.contractAddress), sender: (swallet.walletAddress), from: 0, to: UInt64.max) { (ret, data) in
                    switch ret{
                    case .success:
                        do{}
                    case .fail(_, _):
                        do{}
                    }
                }
            }
        }
        
        
    }
    
    //MARK: - Notification
    
    @objc func didUpdateSharedWalletTransaction(){
        
        if let swallet = AssetVCSharedData.sharedData.selectedWallet as? SWallet{
            dataSource?.removeAll()
            let txs = STransferPersistence.getAllATPTransferByContractAddress((swallet.contractAddress))
            if txs.count > 0{
                dataSource?.append(contentsOf: txs)
            }
            
            let recvJointWalletTxs = STransferPersistence.getAllATPTransferByReceiveAddress((swallet.contractAddress))
            if recvJointWalletTxs.count > 0{
                dataSource?.append(contentsOf: recvJointWalletTxs)
            }
            
            let recvClassicTxs = TransferPersistence.getAllByAddress(from: (swallet.contractAddress))
            if recvClassicTxs.count > 0{
                dataSource?.append(contentsOf: recvClassicTxs)
            }
            
            dataSource?.txSort()
            self.tableView.reloadData()
        }
    }
    
    @objc func willDeleteWallet(_ notification: Notification){
        guard self.walletAddress != nil else {
            return 
        }
        if let cwallet = notification.object as? Wallet{
            if (self.walletAddress?.ishexStringEqual(other: cwallet.key?.address))!{
                self.dataSource?.removeAll()
                self.tableView.reloadData()
            }
        }else if let jwallet = notification.object as? SWallet{
            if (self.walletAddress?.ishexStringEqual(other: jwallet.contractAddress))!{
                self.dataSource?.removeAll()
                self.tableView.reloadData()
            }
        } 
    }
    
    @objc func updateWalletList(){
        self.refreshData()
    }
    
    @objc func nodeDidSwitch(){
        self.dataSource?.removeAll()
        self.tableView.reloadData()
    }

    
}
 
extension AssetTransactionViewControllerV060: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let wallet = AssetVCSharedData.sharedData.selectedWallet 
        let cell : WalletDetailCell = tableView.dequeueReusableCell(withIdentifier: String(describing: WalletDetailCell.self)) as! WalletDetailCell
        let tx = dataSource?[indexPath.row]
        cell.updateTransferCell(txAny: tx , walletAny: wallet)

        cell.updateCellStyle(count: dataSource?.count ?? 0, index: indexPath.row)
        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.childScrollViewDidScroll(childScrollView: scrollView)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 69
    }
     
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tx = dataSource?[indexPath.row]
        if let tx = tx as? STransaction{
            let vc = self.router(stransaction: tx)
            AssetViewControllerV060.pushViewController(viewController: vc)
            //update unread red dot
            STransferPersistence.updateAsRead(tx: tx)
            self.tableView.reloadData()
            NotificationCenter.default.post(name: NSNotification.Name(WillUpdateUnreadDot_Notification), object: nil)
        }else if let tx = tx as? Transaction{
            let transferVC = TransactionDetailViewController()
            transferVC.transaction = tx
            AssetViewControllerV060.pushViewController(viewController: transferVC)
        }
    }
    
}

//MARK: - Asset60

extension AssetTransactionViewControllerV060{
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat{
        let edgeToTop = (self.tableView.frame.size.height - self.tableNodataHolderView.frame.size.height) * 0.5
        return -edgeToTop
    }
}
