//
//  SharedWalletDetailVC.swift
//  platonWallet
//
//  Created by matrixelement on 16/11/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class SharedWalletDetailVC: BaseViewController ,UITableViewDelegate,UITableViewDataSource{

    let tableView = UITableView()
    var tableViewHeader : WalletDetailHeader?
    var dataSource : [AnyObject]? = []
    var swallet : SWallet?
    var timer : Timer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = swallet?.name
        
        customeNavigationStyle()
        initSubViews()
        initTxQueryTimer()
        initData()
         
        
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateAllAsset), name: NSNotification.Name(DidUpdateAllAssetNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateSharedWalletTransaction), name: NSNotification.Name(DidUpdateSharedWalletTransactionList_Notification), object: nil)
        didUpdateAllAsset()
        didUpdateSharedWalletTransaction()
    }
    
    func initTxQueryTimer(){
        if jointWalletUpdateTxListTimerEnable{
            if timer == nil{
                timer = Timer.scheduledTimer(timeInterval:TimeInterval(jointWalletUpdateTxListTimerInterval), target: self, selector: #selector(timerFirer), userInfo: nil, repeats: true)
            }
        }
    }
    
    @objc func timerFirer(){
        initData()
    }
    
    func tableviewHeader() -> WalletDetailHeader? {
        if tableViewHeader == nil{
            tableViewHeader = UIView.viewFromXib(theClass: WalletDetailHeader.self) as? WalletDetailHeader
            tableViewHeader?.sendBtn.addTarget(self, action: #selector(onSend), for: .touchUpInside)
            tableViewHeader?.recvBtn.addTarget(self, action: #selector(onRecv), for: .touchUpInside)
            tableViewHeader?.addressLabel.text = swallet?.contractAddress

            if ((swallet?.isWatchAccount)!){
                tableViewHeader?.setSWalletType(.watchAccount)
            }else if ((swallet?.isOwner)!){
                tableViewHeader?.setSWalletType(.ownerAccount)
            }else{
                tableViewHeader?.setSWalletType(.watchAccount)
            }
        }
        return tableViewHeader
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        initTxQueryTimer()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        if (timer != nil){
            timer?.invalidate()
            timer = nil
        }
    }
    
    func initData() {
        SWalletService.sharedInstance.getTransactionList(contractAddress: (swallet?.contractAddress)!, sender: (swallet?.walletAddress)!, from: 0, to: UInt64.max) { (ret, data) in
            switch ret{
            case .success:
                do{}
            case .fail(_, _):
                do{}
            }
        }
    }
    
    func customeNavigationStyle() {
        let backgrouImage = UIImage(color: nav_bar_backgroud)
        self.navigationController?.navigationBar.setBackgroundImage(backgrouImage, for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
    }
    
    func initSubViews() {
        
        view.backgroundColor = UIViewController_backround
        
        tableView.backgroundColor = UIViewController_backround
        tableView.separatorStyle = .none
        tableView.delegate = self as UITableViewDelegate
        tableView.dataSource = (self as UITableViewDataSource)
        tableView.backgroundView = UIView()
        /*
        tableView.backgroundView?.backgroundColor = .white
        tableView.backgroundView!.addMaskView(corners: [.bottomRight,.bottomLeft], cornerRadiiV: 4)
        */
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        /*
         if #available(iOS 11.0, *) {
         tableView.contentInsetAdjustmentBehavior = .never
         } else {
         automaticallyAdjustsScrollViewInsets = false
         }
         */
        
        tableView.registerCell(cellTypes: [WalletDetailCell.self])
        tableView.emptyDataSetView { [weak self] view in
            view.customView(self?.emptyViewForTableView(forEmptyDataSet: (self?.tableView)!, Localized("walletDetailVC_no_transactions_text")))
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let header = tableviewHeader()
        let height = header?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        var newFrame = header?.frame
        newFrame?.size.height = height!;
        header?.frame = newFrame!
        tableView.tableHeaderView = header
        didUpdateAllAsset()
    }
     
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)        
    }
    
    @objc func onNavigationLeft(){
        
    }
     
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : WalletDetailCell = tableView.dequeueReusableCell(withIdentifier: String(describing: WalletDetailCell.self)) as! WalletDetailCell
        let anytx = dataSource?[indexPath.row]
        if let tx = anytx as? STransaction{
            cell.updateTransferCell(txAny: tx , walletAny: swallet)
        }else if let tx = anytx as? Transaction{
            cell.updateTransferCell(txAny: tx , walletAny: swallet)
        }
        
        cell.updateCellStyle(count: dataSource?.count ?? 0, index: indexPath.row)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    } 
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tx = dataSource?[indexPath.row]
        if let tx = tx as? STransaction{
            let vc = self.router(stransaction: tx)
            navigationController?.pushViewController(vc, animated: true)
            
            //update unread red dot
            STransferPersistence.updateAsRead(tx: tx)
            self.tableView.reloadData()
            NotificationCenter.default.post(name: NSNotification.Name(WillUpdateUnreadDot_Notification), object: nil)
        }else if let tx = tx as? Transaction{
            let transferVC = TransactionDetailViewController()
                transferVC.transaction = tx
                transferVC.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(transferVC, animated: true)
        }
        
    }
    
    @objc func onSend() {
        let transferVC = SharedWalletTransferVC()
        transferVC.selectedWallet = swallet
        navigationController?.pushViewController(transferVC, animated: true)
    }
    
    @objc func onRecv(){
        let recvVC = QRDisplayViewController()
        recvVC.walletInstance = swallet
        recvVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(recvVC, animated: true)
    }
    
    // MARK: - Notification
    
    @objc func didUpdateAllAsset(){
        let balance = AssetService.sharedInstace.assets[(swallet?.contractAddress)!]
        guard balance != nil else {
            return
        }
        let balanceDes = balance?!.balance?.divide(by: ETHToWeiMultiplier, round: 12)
        let display = balanceDes!.balanceFixToDisplay(maxRound: 12)
        if display.length > 0{
            tableViewHeader?.balanceLabel.text = display.ATPSuffix()
        }else{
            NSLog("fattal error")
        }
    }
    
    @objc func didUpdateSharedWalletTransaction(){
        dataSource?.removeAll()
        let txs = STransferPersistence.getAllATPTransferByContractAddress((swallet?.contractAddress)!)
        if txs.count > 0{
            dataSource?.append(contentsOf: txs)
        }
        
        let recvJointWalletTxs = STransferPersistence.getAllATPTransferByReceiveAddress((swallet?.contractAddress)!)
        if recvJointWalletTxs.count > 0{
            dataSource?.append(contentsOf: recvJointWalletTxs)
        }
        
        let recvClassicTxs = TransferPersistence.getAllByAddress(from: (swallet?.contractAddress)!)
        if recvClassicTxs.count > 0{
            dataSource?.append(contentsOf: recvClassicTxs)
        }
        
        dataSource?.txSort()
        self.tableView.reloadData()
    }
    
}
