//
//  WalletDetailViewController.swift
//  platonWallet
//
//  Created by matrixelement on 18/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class WalletDetailViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource {
    
    let tableView = UITableView()
    var tableViewHeader : WalletDetailHeader?
    var dataSource : [AnyObject]? = []
    var wallet : Wallet?
    var timer : Timer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = wallet?.name
        
        customeNavigationStyle()
        initSubViews()
        initTxQueryTimer()
        initData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateAllAsset), name: NSNotification.Name(DidUpdateAllAssetNotification), object: nil)
    }
    
    func initTxQueryTimer(){
        if timer == nil{
            timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(timerFirer), userInfo: nil, repeats: true)
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
            tableViewHeader?.voteBtn.addTarget(self, action: #selector(onVote), for: .touchUpInside)
            tableViewHeader?.addressLabel.text = wallet?.key?.address
            tableViewHeader?.enableVoteBtn(true)
        }
        return tableViewHeader
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        initTxQueryTimer()
        initData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if (timer != nil){
            timer?.invalidate()
            timer = nil
        }
    }
    
    func initData() {
        dataSource?.removeAll()
        let data = TransferPersistence.getAllByAddress(from: (wallet?.key?.address)!)
        
        dataSource?.append(contentsOf: data)
        dataSource?.append(contentsOf: STransferPersistence.getAllByWalletOwner(address: (wallet?.key?.address)!))
        
        if dataSource!.count == 0{
            tableView.showEmptyView(description: Localized("walletDetailVC_no_transactions_text"))
        }else{
            tableView.removeEmptyView()
        }
        dataSource?.txSort()
        tableView.reloadData()
        didUpdateAllAsset()
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
        let tx = dataSource?[indexPath.row]
        cell.updateTransferCell(txAny: tx , walletAny: wallet)
        cell.unreadDot.isHidden = true
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
        let transferVC = TransactionDetailViewController()
        let data = dataSource![indexPath.row]
        if let data = data as? Transaction{
            transferVC.transaction = data
            transferVC.wallet = wallet
            transferVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(transferVC, animated: true)
        }else if let data = data as? STransaction{
            let vc = router(stransaction: data,specifiedWallet: self.wallet)
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }

    @objc func onSend() {
        let transferVC = ATPTransferViewController()
        transferVC.defalutWallet = wallet
        navigationController?.pushViewController(transferVC, animated: true)
    }
    
    @objc func onRecv(){
        let recvVC = QRDisplayViewController()
        recvVC.walletInstance = wallet
        recvVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(recvVC, animated: true)
    }
    
    @objc func onVote() {
        let voteVC = CandidatesListViewController()
        navigationController?.pushViewController(voteVC, animated: true)
    }
     
    // MARK: - Notification
    
    @objc func didUpdateAllAsset(){
        let balance = AssetService.sharedInstace.assets[(wallet?.key?.address)!]
        guard balance != nil else {
            tableViewHeader?.balanceLabel.text = "0.00".ATPSuffix()
            return
        }
        var balanceDes = balance?!.balance?.divide(by: ETHToWeiMultiplier, round: 12)
        balanceDes = balanceDes!.balanceFixToDisplay(maxRound: 12)
        if let balanceDes = balanceDes{
            tableViewHeader?.balanceLabel.text = balanceDes.ATPSuffix()
        }else{
            tableViewHeader?.balanceLabel.text = "0.00".ATPSuffix()
        }
    }
}
