//
//  WalletListMangementInnerVC.swift
//  platonWallet
//
//  Created by juzix on 2020/7/21.
//  Copyright © 2020 ju. All rights reserved.
//

import UIKit

class WalletListMangementInnerVC: BaseViewController, UITableViewDelegate, UITableViewDataSource, PopupMenuTableDelegate {

    let tableView = UITableView()

    var wallet: Wallet!
//    var wallets: [Wallet] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configSubViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
            self.updateWalletList()
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
//        self.setRightNaviButton(title: Localized("WalletManagerDetailVC_Rename")) {[weak self] (_) in
//            guard let self = self else { return }
//            self.showCommonRenameInput(completion: { [weak self] text in
//                guard let self = self else { return }
//                self.updateWalletName(text!)
//            }, checkDuplicate: true)
//        }
        
        let addButton = UIButton(type: .custom)
        addButton.setImage(UIImage(named: "1.icon_more"), for: .normal)
        addButton.addTarget(self, action: #selector(onNavRight), for: .touchUpInside)
        addButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        let rightBarButtonItem = UIBarButtonItem(customView: addButton)
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    @objc func onNavRight() {
        var menuArray: [MenuItem] = []
        let menu1 = MenuItem(icon: nil, title: Localized("WalletManagerDetailVC_bubble_Rename")) // 修改名称
        let menu2 = MenuItem(icon: nil, title: Localized("WalletManagerDetailVC_bubble_Mnemonics_Backup")) // 备份助记词
        let menu3 = MenuItem(icon: nil, title: Localized("WalletManagerDetailVC_bubble_Mnemonics_DeleteHDWallet")) // 删除HD钱包
        menuArray = wallet.isBackup ? [menu1, menu2, menu3] : [menu1, menu2]
        let menu = PopupMenuTable(menuArray: menuArray, arrowPoint: CGPoint(x: UIScreen.main.bounds.width - 30, y: 64 + UIDevice.notchHeight))
        menu.popUp()
        menu.delegate = self
    }
    
    // MARK: - PopupMenuTableDelegate

    func popupMenu(_ popupMenu: PopupMenuTable, didSelectAt index: Int) {
        switch index {
        case 0:
            renameWallet()
        case 1:
            showWalletBackup(wallet: self.wallet)
        case 2:
            deleteWallet()
        default:
            do {}
        }
    }
    
    func deleteWallet() {
        showPasswordInputPswAlert(for: self.wallet, isForDelete: true) { [weak self] (pri, password, error) in
            guard let self = self else { return }
            if let errMessage = error?.localizedDescription {
                self.showErrorMessage(text: errMessage, delay: 2.0)
                return
            }
            // 有错或者取消（回调数据全空即为取消）
            if error != nil || (pri == nil && password == nil && error == nil) {
                return
            }
            self.confirmToDeleteWallet()
        }
    }
    
    func renameWallet() {
        self.showCommonRenameInput(completion: { [weak self] text in
            guard let self = self else { return }
            self.updateWalletName(text!)
            }, checkDuplicate: true)
    }
    
    func showWalletBackup() {
        guard let wallet = self.wallet, wallet.canBackupMnemonic == true else { return }
        let alertVC = AlertStylePopViewController.initFromNib()
        let style = PAlertStyle.passwordInput(walletName: wallet.name)

        alertVC.onAction(confirm: {[weak self] (text, _) -> (Bool)  in
            let valid = CommonService.isValidWalletPassword(text ?? "")
            if !valid.0 {
                alertVC.showInputErrorTip(string: valid.1)
                return false
            }

            alertVC.showLoadingHUD()
            WalletService.sharedInstance.exportMnemonic(wallet: wallet, password: text!, completion: { (res, error) in
                alertVC.hideLoadingHUD()
                if (error == nil && (res!.length) > 0) {
                    let vc = BackupMnemonicViewController()
                    vc.mnemonic = res
                    vc.walletAddress = wallet.address
                    vc.view.backgroundColor = .white
                    vc.hidesBottomBarWhenPushed = true
                    self?.rt_navigationController!.pushViewController(vc, animated: true)
                    alertVC.dismissWithCompletion()
                } else {
                    //alertVC.showInputErrorTip(string: error?.errorDescription)
                    alertVC.showErrorMessage(text: Localized(error?.errorDescription ?? ""), delay: 2.0)
                }
            })
            return false

        }) { (_, _) -> (Bool) in
            return true
        }
        alertVC.style = style
        alertVC.showInViewController(viewController: self)
    }
    
    /// 删除HD钱包
    func confirmToDeleteWallet() {
        guard let wal = self.wallet else { return }
        WalletService.sharedInstance.deleteWallet(wal, shouldDeleteSubWallet: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                // 跳出页面
                self.navigationController?.popViewController(animated: true)
            }
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
        return wallet.subWallets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WalletManagerTableViewCell", for: indexPath) as! WalletManagerTableViewCell
        cell.backupButton.tag = indexPath.row
        let wallet = self.wallet.subWallets[indexPath.row]
        cell.feedData(wallet)
        return cell

    }

    //    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //        return 70
    //    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let wallet = self.wallet.subWallets[indexPath.row]
        let detailVC = WalletManagerDetailViewController()
        detailVC.wallet = wallet
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    @objc func updateWalletList() {
        WalletService.sharedInstance.refreshDB()
        if let wallet = WalletService.sharedInstance.getWallet(byUUID: self.wallet.uuid) {
            self.wallet = wallet
            self.tableView.reloadData()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
}
