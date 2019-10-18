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

        let view = WalletEmptyView(walletType: .classic, createBtnClickHandler: { [weak self] in
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

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(shouldUpdateWalletStatus), name: Notification.Name.ATON.DidNetworkStatusChange, object: nil)

        initSubView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initData()
        updateUI()
    }

    func initData() {
        dataSource.removeAll()
        dataSource.append(contentsOf: AssetVCSharedData.sharedData.walletList as [AnyObject])
    }

    func updateUI() {
        super.leftNavigationTitle = "WalletManagerDetailVC_title"
        if dataSource.count > 0 {
            atpWalletEmptyView.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        } else {
            atpWalletEmptyView.isHidden = false
            tableView.isHidden = true
        }
        tableView.reloadData()
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

    func createIndividualWallet() {

        dismiss(animated: false, completion: nil)
        let createWalletVC = CreateIndividualWalletViewController()

        navigationController?.pushViewController(createWalletVC, animated: true)
    }

    func importIndividualWallet() {
        dismiss(animated: false, completion: nil)
        let importWallet = MainImportWalletViewController()

        navigationController?.pushViewController(importWallet, animated: true)
    }

    @objc func shouldUpdateWalletStatus() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
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
        if let wallet = wallet as? Wallet {
            let detailVC = WalletManagerDetailViewController()
            detailVC.wallet = wallet
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }

    @objc func onBackUp(sender: UIButton) {
        guard sender.tag < dataSource.count ,let walletTobackup = dataSource[sender.tag] as? Wallet, walletTobackup.canBackupMnemonic else {
            return
        }
        showWalletBackup(wallet: walletTobackup)
    }

    // MARK: - TableViewReorderDelegate
    func tableView(_ tableView: UITableView, reorderRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        //print("sourceIndexPath:\(sourceIndexPath.row)")
        //print("destinationIndexPath:\(destinationIndexPath.row)")
    }

    func tableViewDidFinishReordering(_ tableView: UITableView, from initialSourceIndexPath: IndexPath, to finalDestinationIndexPath: IndexPath) {
        guard initialSourceIndexPath.row != finalDestinationIndexPath.row else {
            return
        }
        var array = Array(self.dataSource)
        let initItem = array[initialSourceIndexPath.row]
        array.remove(at: initialSourceIndexPath.row)
        array.insert(initItem, at: finalDestinationIndexPath.row)

        for (i,element) in array.enumerated() {
            if let classicWallet = element as? Wallet {
                WallletPersistence().updateWalletUserArrangementIndex(wallet: classicWallet, userArrangementIndex: i)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.dataSource.removeAll()
            self.dataSource.append(contentsOf: array)
            self.tableView.reloadData()
            //排序过后，强制刷新一下内存数据
            WalletService.sharedInstance.refreshDB()
        }
    }

}
