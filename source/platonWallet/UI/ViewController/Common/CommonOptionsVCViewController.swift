//
//  CommonOptionsVCViewController.swift
//  platonWallet
//
//  Created by juzix on 2020/7/18.
//  Copyright © 2020 ju. All rights reserved.
//

import UIKit
import Localize_Swift


//class CommonOptionsTCell: UITableViewCell {
//
//    var titleLabel = UILabel()
//    var selectionImageView = UIImageView()
//
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        contentView.addSubview(titleLabel)
//        contentView.addSubview(selectionImageView)
//
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//}

class CommonOptionsVC: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    var seleceted = Localize.currentLanguage()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
    
    func configUI() {
        super.leftNavigationTitle = "LanguageSetting_VC_Title"
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

        tableView.registerCell(cellTypes: [LanguageSettingTableViewCell.self])

        let rightMenuButton = UIButton(type: .custom)
        rightMenuButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        rightMenuButton.localizedNormalTitle = "SettingsVC_nodeSet_saveBtn_title"
        rightMenuButton.setTitleColor(UIColor(rgb: 0x105CFE), for: .normal)
        rightMenuButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        rightMenuButton.addTarget(self, action: #selector(onNavRight), for: .touchUpInside)
        let rightBarButtonItem = UIBarButtonItem(customView: rightMenuButton)
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
    }
    
    @objc func onNavRight() {
        print("rightNac Clicked")
        
    }
    
    // MARK: UITableViewDataSource & UITableViewDelegate
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: LanguageSettingTableViewCell.self)) as! LanguageSettingTableViewCell
        if indexPath.row == 0 {
            if seleceted == "zh-Hans"{
                cell.selectedIcon.alpha = 1
            } else {
                cell.selectedIcon.alpha = 0
            }
            cell.detailLabel?.text = "简体中文"
        } else {
            if seleceted == "en"{
                cell.selectedIcon.alpha = 1
            } else {
                cell.selectedIcon.alpha = 0
            }
            cell.detailLabel?.text = "English"
        }

        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch indexPath.row {
        case 0:
            do {
                seleceted = "zh-Hans"
                tableView.reloadData()
            }
        case 1:
            do {
                seleceted = "en"
                tableView.reloadData()
            }
        default:
            break
        }
    }
}
