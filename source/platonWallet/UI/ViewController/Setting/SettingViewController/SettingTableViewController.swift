//
//  SettingTableViewController.swift
//  platonWallet
//
//  Created by matrixelement on 2018/11/2.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift
import LocalAuthentication

class SettingTableViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    lazy var tableView: UITableView = {

        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = UIViewController_backround
        //tableView.separatorColor = UIColor(rgb: 0x32394E)
        tableView.separatorColor = UIColor(rgb: 0xE4E7F3)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.layoutMargins = .zero
        tableView.preservesSuperviewLayoutMargins = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        return tableView
    }()

    var isSupportLocalAuth: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        super.leftNavigationTitle = "SettingsVC_title"
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }

        var error: NSError?
        if LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            isSupportLocalAuth = true
        } else {

            if error!.code == kLAErrorBiometryNotAvailable {
                isSupportLocalAuth = false
            } else {
                isSupportLocalAuth = true
            }
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    @objc func switchLocalAuthSetting(_ sender: UISwitch) {

        let laCtx = LAContext()
        laCtx.localizedFallbackTitle = ""
        var error: NSError?
        if laCtx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {

            laCtx.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: Localized("touchid_auth_text")) { (success, _) in

                DispatchQueue.main.async {

                    if success {

                        (UIApplication.shared.delegate as! AppDelegate).localAuthStateSwitch(sender.isOn)

                    } else {
                        sender.isOn = !sender.isOn
                    }
                }

            }

        } else {

            showMessage(text: Localized("SettingsVC_faceId_openFailed_tips"))
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                sender.isOn = false
            }

        }

    }

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return isSupportLocalAuth ? 3 : 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.selectionStyle = .none
        var title: String = ""
        let rigthArrowImgV = UIImageView(image: UIImage(named: "icon_right_arrow"))

        func languagesSetCell() {
            title = "SettingsVC_languages_title"
            cell.contentView.addSubview(rigthArrowImgV)
            rigthArrowImgV.snp.makeConstraints { (maker) in
                maker.right.equalToSuperview().offset(-18)
                maker.centerY.equalToSuperview()
            }

            let lanL = UILabel(frame: .zero)

            if Localize.currentLanguage() == "en" {
                lanL.text = "English"
            } else {
                lanL.text = "简体中文"
            }
            lanL.textColor = UIColor(rgb: 0x000000)
            lanL.font = UIFont.systemFont(ofSize: 12)
            cell.contentView.addSubview(lanL)
            lanL.snp.makeConstraints { (maker) in
                maker.right.equalTo(rigthArrowImgV.snp.left).offset(-4)
                maker.centerY.equalToSuperview()
            }
        }

        switch indexPath.row {
        case 0:
            title = "SettingsVC_nodeSet_title"
            cell.contentView.addSubview(rigthArrowImgV)
            rigthArrowImgV.snp.makeConstraints { (maker) in
                maker.right.equalToSuperview().offset(-18)
                maker.centerY.equalToSuperview()
            }
        case 1:
            if isSupportLocalAuth {
                title = "SettingsVC_faceId_title"
                let `switch` = UISwitch(frame: .zero)
                `switch`.addTarget(self, action: #selector(switchLocalAuthSetting(_ :)), for: .valueChanged)
                `switch`.isOn = (UIApplication.shared.delegate as! AppDelegate).isOpenLocalAuthState()
                `switch`.onTintColor = UIColor(rgb: 0x4CD964)
                cell.contentView.addSubview(`switch`)
                `switch`.snp.makeConstraints { (maker) in
                    maker.right.equalToSuperview().offset(-18)
                    maker.centerY.equalToSuperview()
                }
            } else {
                languagesSetCell()
            }

        case 2:

            languagesSetCell()

        default:
            title = ""
        }

        let titleL = UILabel(frame: .zero)
        titleL.textColor = UIColor.black
        titleL.font = UIFont.systemFont(ofSize: 16)
        titleL.localizedText = title
        cell.contentView.addSubview(titleL)
        cell.contentView.backgroundColor = UIColor(rgb: 0xffffff)
        titleL.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview().offset(18)
            maker.centerY.equalToSuperview()
        }

        return cell
    }

    // MARK: - UITableView Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch indexPath.row {
        case 0:
            navigationController?.pushViewController(NodeSettingViewControllerV2(), animated: true)

        case 1:
            do {
                if !isSupportLocalAuth {
                    let vc = LanguageSettingVC()
                    navigationController?.pushViewController(vc, animated: true)
                } else {
                    break
                }
            }

        case 2 :
            do {
                let vc = LanguageSettingVC()
                navigationController?.pushViewController(vc, animated: true)
            }
        default:
            do {

            }
            break
        }

    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //bug fix for below ios10 tableView cannot response separatorInset
        if #available(iOS 10, *) {

        } else {
            cell.layoutMargins = .zero
        }
    }

}
