//
//  LanguageSettingVC.swift
//  platonWallet
//
//  Created by matrixelement on 5/11/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift

enum KLanguage {
    case zh_Hans
    case en

    var desription: String {
        switch self {
        case .zh_Hans:
            return "zh-Hans"
        case .en:
            return "en"
        }
    }
}

class LanguageSettingVC: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    var seleceted = Localize.currentLanguage()

    override func viewDidLoad() {
        super.viewDidLoad()
        initSubViews()
        initNavigationItems()
        initData()
    }

    func initData() {

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

    func initNavigationItems() {
        super.leftNavigationTitle = "LanguageSetting_VC_Title"
    }

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

    @objc func onNavRight() {
        Localize.setCurrentLanguage(seleceted)
        self.navigationController?.popToRootViewController(animated: true)

    }

}
