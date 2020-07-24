//
//  WalletListMangementInnerVC.swift
//  platonWallet
//
//  Created by juzix on 2020/7/21.
//  Copyright © 2020 ju. All rights reserved.
//

import UIKit

class WalletListMangementInnerVC: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    let tableView = UITableView()

    var wallet: Wallet!
    var wallets: [Wallet] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configSubViews()
    }

    func configSubViews() {
        super.leftNavigationTitle = wallet.name

        tableView.backgroundColor = UIViewController_backround
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "WalletManagerTableViewCell", bundle: nil), forCellReuseIdentifier: "WalletManagerTableViewCell")
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(0)
            make.right.equalToSuperview().offset(0)
        }
        tableView.tableFooterView = UIView()
        self.setRightNaviButton(title: Localized("WalletManagerDetailVC_Rename")) {[weak self] (_) in
            guard let self = self else { return }
            self.showCommonRenameInput(completion: { [weak self] text in
                guard let self = self else { return }
                self.updateWalletName(text!)
            }, checkDuplicate: true)
        }
    }

    func updateWalletName(_ name:String) {
        WalletService.sharedInstance.updateWalletName(wallet, name: name)
//        walletName.text = name
        if let titleLabel = super.titleLabel {
            titleLabel.text = name
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            WalletService.sharedInstance.refreshDB()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            AssetViewControllerV060.getInstance()?.controller.fetchWallets()
        }
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wallets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WalletManagerTableViewCell", for: indexPath) as! WalletManagerTableViewCell
        cell.backupButton.tag = indexPath.row
        let wallet = wallets[indexPath.row]
        cell.feedData(wallet)
        return cell

    }

    //    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //        return 70
    //    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let wallet = wallets[indexPath.row]
        let detailVC = WalletManagerDetailViewController()
        detailVC.wallet = wallet
        detailVC.updatedWalletNameCallback = {[weak self] (wallet,name) in
            guard let self = self else { return }
            self.wallets[indexPath.row].name = name
            self.tableView.reloadData()
        }
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
