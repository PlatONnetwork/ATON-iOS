//
//  WalletManagerViewController.swift
//  platonWallet
//
//  Created by matrixelement on 2018/10/29.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import SwiftReorder

class WalletListViewController: BaseViewController,TableViewReorderDelegate {
    

    var tableView: UITableView!
    
    var dataSource: [AnyObject] = []
     
    lazy var atpWalletEmptyView : WalletEmptyView! = {
        
        let view = WalletEmptyView(walletType: .ClassicWallet, createBtnClickHandler: { [weak self] in 
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
    
    var currentType: WalletType = .ClassicWallet


    override func viewDidLoad() {
        super.viewDidLoad()
        // tableview滚动会显示导行栏透明的情况，可修改基类处理，暂定在该页面处理
        navigationController?.navigationBar.isTranslucent = false
        setupUI()
        initSubView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initData()
        updateUI()   
    }
    
    func initData(){
        dataSource.removeAll()
        dataSource.append(contentsOf: AssetVCSharedData.sharedData.walletList as [AnyObject])
    }
    
    func updateUI() {
        super.leftNavigationTitle = "WalletManagerDetailVC_title"
        if dataSource.count > 0 {
            atpWalletEmptyView.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }else {
            atpWalletEmptyView.isHidden = false
            tableView.isHidden = true
        }
        tableView.reloadData()
    }
    
    func setupUI() {
        /*
        let titleView = UIView.viewFromXib(theClass: AssetNavigationBarView.self) as! AssetNavigationBarView
        titleView.leftButton.addTarget(self, action: #selector(onNavigationLeft), for: .touchUpInside)
        titleView.rightButton.addTarget(self, action: #selector(onNavigationRight), for: .touchUpInside)
        navigationItem.titleView = titleView
        */
    }

    
    func initSubView() {
        tableView = UITableView()
        tableView.backgroundColor = UIViewController_backround
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.reorder.delegate = self
        tableView.register(UINib(nibName: "WalletManagerTableViewCell", bundle: nil), forCellReuseIdentifier: "WalletManagerTableViewCell")
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(0)
            make.right.equalToSuperview().offset(0)
        }
        tableView.tableFooterView = UIView()
    }
    
    @objc func onNavigationLeft() {
        currentType = .ClassicWallet
        updateUI()
    }
    
    @objc func onNavigationRight() {
        currentType = .JointWallet
        updateUI()
    }
    
    func createIndividualWallet() {
        
        dismiss(animated: false, completion: nil)
        let createWalletVC = CreateIndividualWalletViewController()
        
        navigationController?.pushViewController(createWalletVC, animated: true)
    }
    
    func createSharedWallet() {
        let vc = CreateSharedWalletStep1ViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func importIndividualWallet() {
        dismiss(animated: false, completion: nil)
        let importWallet = MainImportWalletViewController()
        
        navigationController?.pushViewController(importWallet, animated: true)
    }
    
    func addSharedWallet() {
        let addSharedWallet = AddSharedWalletVC()
        navigationController?.pushViewController(addSharedWallet, animated: true)
    }
    
    
}

extension WalletListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
     
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let spacer = tableView.reorder.spacerCell(for: indexPath) {
            return spacer
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "WalletManagerTableViewCell", for: indexPath) as! WalletManagerTableViewCell
        cell.backupButton.tag = indexPath.row
        cell.backupButton.addTarget(self, action: #selector(onBackUp), for: .touchUpInside)
        cell.feedData(dataSource[indexPath.row])
        
        return cell

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let wallet = dataSource[indexPath.row]
        if let wallet = wallet as? Wallet{
            let detailVC = WalletManagerDetailViewController()
            detailVC.wallet = wallet
            navigationController?.pushViewController(detailVC, animated: true)
        }else if let wallet = wallet as? SWallet{
            let detailVC = SWalletManagerViewController()
            detailVC.swallet = wallet
            navigationController?.pushViewController(detailVC, animated: true)
        }
    } 
    
    @objc func onBackUp(sender: UIButton){
        guard sender.tag < dataSource.count ,let walletTobackup = dataSource[sender.tag] as? Wallet, walletTobackup.canBackupMnemonic else {
            return
        }
        showWalletBackup(wallet: walletTobackup)
    }
    
    //MARK: - TableViewReorderDelegate
    func tableView(_ tableView: UITableView, reorderRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        //print("sourceIndexPath:\(sourceIndexPath.row)")
        //print("destinationIndexPath:\(destinationIndexPath.row)")
    }
    
    func tableViewDidFinishReordering(_ tableView: UITableView, from initialSourceIndexPath: IndexPath, to finalDestinationIndexPath: IndexPath){
        print("initialSourceIndexPath:\(initialSourceIndexPath.row)")
        print("finalDestinationIndexPath:\(finalDestinationIndexPath.row)")
        guard initialSourceIndexPath.row != finalDestinationIndexPath.row else {
            return
        }
        var array = Array(self.dataSource)
        let initItem = array[initialSourceIndexPath.row]
        array.remove(at: initialSourceIndexPath.row)
        array.insert(initItem, at: finalDestinationIndexPath.row)
        RealmInstance?.beginWrite()
        for (i,element) in array.enumerated(){
            if let classicWallet = element as? Wallet{
                classicWallet.userArrangementIndex = i
            }else if let jointWallet = element as? SWallet{
                jointWallet.userArrangementIndex = i
            }
        }
        try? RealmInstance?.commitWrite()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { 
            self.dataSource.removeAll()
            self.dataSource.append(contentsOf: array)
            self.tableView.reloadData()
        }
    }
}
