//
//  HomePageViewController.swift
//  platonWallet
//
//  Created by matrixelement on 17/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import BigInt
import Localize_Swift

class AssetViewController: BaseViewController{
    
    let titleView = UIView.viewFromXib(theClass: AssetNavigationBarView.self) as! AssetNavigationBarView
    
    var tableView: UITableView!

    var atpWallets:[Wallet]! {
        return WalletService.sharedInstance.wallets
    }
    
    var sharedWallets:[SWallet]!{
        var jointWallets : [SWallet] = []
        if SWalletService.sharedInstance.wallets.count > 0{
            jointWallets.append(contentsOf: SWalletService.sharedInstance.wallets)
        }
        
        if SWalletService.sharedInstance.creatingWallets.count > 0{
            jointWallets.append(contentsOf: SWalletService.sharedInstance.creatingWallets)
        }
        return jointWallets
    }
    
    let header = AssetTableHeader()
    
    lazy var atpWalletEmptyView : WalletEmptyView! = {
        
        let view = WalletEmptyView(walletType: .ATPWallet, createBtnClickHandler: { [weak self] in 
            self?.createIndividualWallet()
            
        }) { [weak self] in 
            self?.importIndividualWallet()
        }
        view.isHidden = true
        self.view.addSubview(view)
        view.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        return view
    }()
    
    lazy var sharedWalletEmptyView : WalletEmptyView! = {
        
        let view = WalletEmptyView(walletType: .sWallet, createBtnClickHandler: { [weak self] in 
            self?.createSharedWallet()
            
        }) { [weak self] in 
            self?.addSharedWallet()
        }
        view.isHidden = true
        self.view.addSubview(view)
        view.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        return view
    }()
    
    var currentType: WalletType = .ATPWallet

    override func viewDidLoad() {
        super.viewDidLoad()
        customeNavigationStyle()
        initSubViews()
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateAllAsset), name: Notification.Name(DidUpdateAllAssetNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateUnreadDot), name: Notification.Name(WillUpdateUnreadDot_Notification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didDeleteSharedWallet), name: Notification.Name(updateWalletList_Notification), object: nil)
        
        
        SWalletService.sharedInstance.getAllSharedWalletTransactionList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    func updateUI() {
        
        if currentType == .ATPWallet {
            didUpdateAllAsset()
            if atpWallets.count > 0 {
                sharedWalletEmptyView.isHidden = true
                atpWalletEmptyView.isHidden = true
                tableView.isHidden = false
                tableView.reloadData()
            }else {
                atpWalletEmptyView.isHidden = false
                sharedWalletEmptyView.isHidden = true
                tableView.isHidden = true
            }
            
        }else {
            didUpdateAllAsset()
            if sharedWallets.count > 0 {
                sharedWalletEmptyView.isHidden = true
                atpWalletEmptyView.isHidden = true
                tableView.isHidden = false
                tableView.reloadData()
            }else {
                sharedWalletEmptyView.isHidden = false
                atpWalletEmptyView.isHidden = true
                tableView.isHidden = true
            }
            
        }
        
        
    }
    
    
    func customeNavigationStyle() {
        let backgrouImage = UIImage(color: nav_bar_backgroud)
        self.navigationController?.navigationBar.setBackgroundImage(backgrouImage, for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        titleView.leftButton.addTarget(self, action: #selector(onNavigationLeft), for: .touchUpInside)
        titleView.rightButton.addTarget(self, action: #selector(onNavigationRight), for: .touchUpInside)
        navigationItem.titleView = titleView
        
        let scanButton = UIButton(type: .custom)
        scanButton.setImage(UIImage(named: "navScanWhite"), for: .normal)
        scanButton.addTarget(self, action: #selector(onNavLeft), for: .touchUpInside)
        scanButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        let leftBarButtonItem = UIBarButtonItem(customView: scanButton)
        navigationItem.leftBarButtonItem = leftBarButtonItem
        
        let rightMenuButton = UIButton(type: .custom)
        rightMenuButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        rightMenuButton.setImage(UIImage(named: "navAdd"), for: .normal)
        rightMenuButton.addTarget(self, action: #selector(onNavRight), for: .touchUpInside)
        let rightBarButtonItem = UIBarButtonItem(customView: rightMenuButton)
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        scanButton.hitTestEdgeInsets = UIEdgeInsets(top: -40, left: -40, bottom: -40, right: -40)
        rightMenuButton.hitTestEdgeInsets = UIEdgeInsets(top: -40, left: -40, bottom: -40, right: -40)
    }
    
    func initSubViews() {
        view.backgroundColor = UIViewController_backround
        
        tableView = UITableView()
        tableView.backgroundColor = UIViewController_backround
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        tableView.register(UINib(nibName: "WalletListCell", bundle: nil), forCellReuseIdentifier: "WalletListCell")
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
        }
        tableView.tableFooterView = UIView()
        
        header.frame = CGRect(x: 0, y: 0, width: kUIScreenWidth, height: 100)
        tableView.tableHeaderView = header
        header.updateAssetValue(value: "--")
        
        
       
        
        /*
         if #available(iOS 11.0, *) {
         tableView.contentInsetAdjustmentBehavior = .never
         } else {
         automaticallyAdjustsScrollViewInsets = false
         }
         */
        
    }
    
    @objc func onNavigationLeft() {
        currentType = .ATPWallet
        updateUI()
    }
    
    @objc func onNavigationRight() {
        currentType = .sWallet
        updateUI()
    }
    
    @objc func onNavLeft() {
        
        let scanner = QRScannerViewController { [weak self](res) in
            self?.navigationController?.popViewController(animated: true)
            self?.handleScanResp(res)
        }
        scanner.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(scanner, animated: true)
    }
    
    @objc func onNavRight(){
        
        let menuVC = AddWalletMenuViewController()
        menuVC.delegate = self
        menuVC.modalPresentationStyle = .overFullScreen
        
        present(menuVC, animated: false, completion: nil)
        
    }
    
    func handleScanResp(_ res: String) {
        
        var targetVC: UIViewController?
        
        if res.isValidAddress() {
            
            for wallet in atpWallets {
                if let balance = AssetService.sharedInstace.assets[wallet.key!.address] {
                    if balance!.balance ?? 0 > 0 {
                        let transferVC = ATPTransferViewController()
                        transferVC.defalutWallet = wallet
                        transferVC.toAddress = res
                        targetVC = transferVC
                        break
                    }
                }
            }
            
            if targetVC == nil {
                
                let newAddrInfo = NewAddressInfoViewController()
                newAddrInfo.defaultAddress = res
                targetVC = newAddrInfo
            }
            
        }else if res.isValidPrivateKey() {
            
            targetVC = MainImportWalletViewController(type: .privateKey, text: res)
            
        }else if res.isValidKeystore() {
            
            targetVC = MainImportWalletViewController(type: .keystore, text: res)
            
        }else {
            
            showMessage(text: Localized("QRScan_failed_tips"))
            
        }
        
        if targetVC != nil {
            targetVC!.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(targetVC!, animated: true)
        }

    }

}

extension AssetViewController:UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "WalletListCell", for: indexPath) as! WalletListCell
        if currentType == .ATPWallet {
            cell.feedData(atpWallets[indexPath.section], count: "")
        }else {
            cell.feedData(sharedWallets![indexPath.section], count: "")
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
//        return 2
        return currentType == .ATPWallet ? atpWallets.count : sharedWallets.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if currentType == .ATPWallet {
            let detailVC = WalletDetailViewController()
            detailVC.wallet = atpWallets[indexPath.section]
            detailVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(detailVC, animated: true)
        }else {
            let swallet = sharedWallets[indexPath.section]
            if swallet.privateKey != nil && (swallet.privateKey?.length)! > 0{
                return
            }
            let sWalletVC = SharedWalletDetailVC()
            sWalletVC.swallet = swallet
            sWalletVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(sWalletVC, animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
}


extension AssetViewController: AddWalletMenuDelegate {
    
    func createIndividualWallet() {
        
        dismiss(animated: false, completion: nil)
        let createWalletVC = CreateIndividualWalletViewController()
        createWalletVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(createWalletVC, animated: true)
    }
    
    func createSharedWallet() {
        
        dismiss(animated: false, completion: nil)
        let vc = CreateSharedWalletStep1ViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func importIndividualWallet() {
        dismiss(animated: false, completion: nil)
        let importWallet = MainImportWalletViewController()
        importWallet.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(importWallet, animated: true)
    }
    
    func addSharedWallet() {
        
        dismiss(animated: false, completion: nil)
        let addSharedWallet = AddSharedWalletVC()
        addSharedWallet.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(addSharedWallet, animated: true)
    }
    
    
    // MARK: - Notification
    
    @objc func didUpdateAllAsset(){
        
        if currentType == .ATPWallet && WalletService.sharedInstance.wallets.count == 0{
            header.updateAssetValue(value: "0.00")
            return
        }
        
        if currentType == .sWallet && SWalletService.sharedInstance.wallets.count == 0{
            header.updateAssetValue(value: "0.00")
            return
        }
        
        var total = BigUInt("0")
        
        for item in AssetService.sharedInstace.assets{
            if item.value?.walletType == currentType{
                total?.multiplyAndAdd(item.value!.balance ?? BigUInt(0), 1)
            }
        }
        

        if total == nil || String(total!) == "0"{
            header.updateAssetValue(value: "0.00")
            return
        }
        
        var totalDes = total?.divide(by: ETHToWeiMultiplier, round: 8)
        totalDes = totalDes?.balanceFixToDisplay(maxRound: 8)
        if let totalDes = totalDes{
            header.updateAssetValue(value: totalDes)
        }
        

    }
    
    @objc func updateUnreadDot(){
        let unreadMsgExisted = STransferPersistence.unreadMessageExisted()
        titleView.unreadDot.isHidden = !unreadMsgExisted
        self.tabBarController?.tabBar.isRedDotHidden(!unreadMsgExisted)
    }
    
    @objc func didDeleteSharedWallet(){
        self.tableView.reloadData()
    }
}
