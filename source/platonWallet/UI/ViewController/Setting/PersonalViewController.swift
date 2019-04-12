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
  
    let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        initSubViews()
        initNavigationItems()
    }
    
    
    func initSubViews() {
        self.statusBarNeedTruncate = true
        view.backgroundColor = UIViewController_backround
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
    
    func tableviewHeader() -> UIView {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: kUIScreenWidth, height: 18))
        let label = UILabel(frame: .zero)
        label.textColor = .black
        label.localizedText = "PersonalVC_nav_title"
        label.font = UIFont.systemFont(ofSize: 18)
        container.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.bottom.top.equalToSuperview()
        }
        
        return container
    }
    
    override func viewDidLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let header = tableviewHeader()
        
        var height = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        var newFrame = header.frame
        if height == 0.0{
            height = 18
        }
        newFrame.size.height = height;
        header.frame = newFrame
        tableView.tableHeaderView = header
    }
    
    func initNavigationItems(){
        //super.leftNavigationTitle = "PersonalVC_nav_title"
        //self.navigationController?.isNavigationBarHidden = true
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
        return 68
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var targetVC: UIViewController?
        
        switch indexPath.row {
        case 0:
            do {
                targetVC = WalletListViewController()
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
