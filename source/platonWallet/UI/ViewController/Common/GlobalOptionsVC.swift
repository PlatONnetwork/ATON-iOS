//
//  GlobalOptionsVC.swift
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


class GlobalOptionsVC: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    typealias OptionId = String
    typealias OptionName = String

    private var selectedIndex: Int = 0
    private var options: [(OptionId,OptionName)]!

    private var didConfirmedSelectionCallback: ((OptionId,OptionName) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }

    convenience init(options: [(OptionId,OptionName)], defaultSelectedIndex: Int, didConfirmedSelectionCallback: ((OptionId,OptionName) -> Void)?) {
        self.init()
        self.options = options
        self.selectedIndex = defaultSelectedIndex
        self.didConfirmedSelectionCallback = didConfirmedSelectionCallback
    }

    func configUI() {
        super.leftNavigationTitle = "createWalletVC_choose_walletType"
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
        rightMenuButton.localizedNormalTitle = "common_setting_confirm"
        rightMenuButton.setTitleColor(UIColor(rgb: 0x105CFE), for: .normal)
        rightMenuButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        rightMenuButton.addTarget(self, action: #selector(onNavRight), for: .touchUpInside)
        let rightBarButtonItem = UIBarButtonItem(customView: rightMenuButton)
        navigationItem.rightBarButtonItem = rightBarButtonItem

    }

    @objc func onNavRight() {
        guard let callback = self.didConfirmedSelectionCallback else {
            return
        }
        callback(options[selectedIndex].0, options[selectedIndex].1)
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: UITableViewDataSource & UITableViewDelegate

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: LanguageSettingTableViewCell.self)) as! LanguageSettingTableViewCell
        cell.selectedIcon.alpha = selectedIndex == indexPath.row ? 1 : 0
        cell.detailLabel?.text = options[indexPath.row].1
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
        self.selectedIndex = indexPath.row
        tableView.reloadData()
    }
}
