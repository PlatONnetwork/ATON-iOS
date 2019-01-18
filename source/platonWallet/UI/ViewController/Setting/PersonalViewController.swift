//
//  SettingViewController.swift
//  platonWallet
//
//  Created by matrixelement on 17/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class PersonalViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource {
  
    

    override func viewDidLoad() {
        super.viewDidLoad()
        initSubViews()
        initNavigationItems()
    }
    
    
    func initSubViews() {
        view.backgroundColor = UIViewController_backround
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIViewController_backround
        tableView.delegate = self as UITableViewDelegate
        tableView.dataSource = (self as UITableViewDataSource)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        tableView.registerCell(cellTypes: [SettingTableViewCell.self])
    }
    
    func initNavigationItems(){
        navigationItem.localizedText = "PersonalVC_nav_title"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingTableViewCell.self)) as! SettingTableViewCell
        cell.setCellWithIndexPath(indexPath: indexPath)
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 5 {
            return 60 + 50
        }
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var targetVC: UIViewController?
        
        switch indexPath.row {
        case 0:
            do {
                targetVC = WalletManagerViewController()
            }
        case 1:
            do {
                targetVC = TransactionListViewController()
            }
        case 2:
            do {
                targetVC = AddressBookViewController()
            }
        case 3:
            do {
                targetVC = SettingTableViewController()
            }
        case 4:
            do{
                targetVC = AboutViewController()
            }
        default:
            break
        }
        
        guard targetVC != nil else {
            return
        }
        targetVC!.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(targetVC!, animated: true)
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
