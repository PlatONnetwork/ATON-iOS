//
//  WalletManagerViewController.swift
//  platonWallet
//
//  Created by matrixelement on 2018/10/29.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit

class WalletManagerViewController: BaseViewController {
    
    var tableView: UITableView!
    
    var atpWallets:[Wallet]! {
        return WalletService.sharedInstance.wallets
    }
    
    var sharedWallets:[SWallet]! {
        return SWalletService.sharedInstance.wallets
    }
    
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

        setupUI()
        initSubView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    func updateUI() {
        
        if currentType == .ATPWallet {
            
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
        
        tableView.reloadData()
        
        
    }
    
    func setupUI() {
        
        let titleView = UIView.viewFromXib(theClass: AssetNavigationBarView.self) as! AssetNavigationBarView
        titleView.leftButton.addTarget(self, action: #selector(onNavigationLeft), for: .touchUpInside)
        titleView.rightButton.addTarget(self, action: #selector(onNavigationRight), for: .touchUpInside)
        navigationItem.titleView = titleView
    }
    
    func initSubView() {
        tableView = UITableView()
        tableView.backgroundColor = UIViewController_backround
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        tableView.register(UINib(nibName: "WalletManagerTableViewCell", bundle: nil), forCellReuseIdentifier: "WalletManagerTableViewCell")
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
        }
        tableView.tableFooterView = UIView()
    }
    
    @objc func onNavigationLeft() {
        currentType = .ATPWallet
        updateUI()
    }
    
    @objc func onNavigationRight() {
        currentType = .sWallet
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

extension WalletManagerViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return currentType == .ATPWallet ? atpWallets.count : sharedWallets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "WalletManagerTableViewCell", for: indexPath) as! WalletManagerTableViewCell
        if currentType == .ATPWallet {
            cell.feedData(atpWallets[indexPath.row])
        }else {
            cell.feedData(sharedWallets[indexPath.row])
        }
       
        return cell

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if currentType == .ATPWallet {
            let detailVC = WalletManagerDetailViewController()
            detailVC.wallet = atpWallets[indexPath.row]
            navigationController?.pushViewController(detailVC, animated: true)
        }else {
            
            let detailVC = SWalletManagerViewController()
            detailVC.swallet = sharedWallets[indexPath.row]
            navigationController?.pushViewController(detailVC, animated: true)
        }
        
        
        
    }
    
}
