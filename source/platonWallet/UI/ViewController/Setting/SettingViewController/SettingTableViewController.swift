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
import BigInt
import platonWeb3

class SettingTableViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = UIViewController_backround
        tableView.separatorColor = UIColor(rgb: 0xE4E7F3)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.layoutMargins = .zero
        tableView.preservesSuperviewLayoutMargins = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        return tableView
    }()

    var isSupportLocalAuth: Bool {
        var error: NSError?
        if LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            return true
        } else {
            if error!.code == kLAErrorBiometryNotAvailable {
                return false
            } else {
                return true
            }
        }
    }

    var datasource: [SettingItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        super.leftNavigationTitle = "SettingsVC_title"
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initData()
    }

    @objc func switchResendRemainder(_ sender: UISwitch) {
        SettingService.shareInstance.isResendReminder = sender.isOn
        initData()
    }

    @objc func switchLocalAuthSetting(_ sender: UISwitch) {

        let laCtx = LAContext()
        laCtx.localizedFallbackTitle = ""
        var error: NSError?

        var biometrics: String = "TouchID"
        if #available(iOS 11.0, *) {
            if laCtx.biometryType == .faceID {
                biometrics = "FaceID"
            }
        }

        if laCtx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            laCtx.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: Localized("touchid_auth_text", arguments: biometrics)) { (success, _) in

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

    func initData() {
        let nodeSetItem = SettingItem(title: "SettingsVC_nodeSet_title", content: .none)
        let thresholdItem = SettingItem(title: "SettingsVC_threshold_title", content: .threshold(value: SettingService.shareInstance.thresholdValue))
        let resendItem = SettingItem(title: "SettingsVC_Resend_title", content: .resend(value: SettingService.shareInstance.isResendReminder))
        let authItem = SettingItem(title: "SettingsVC_faceId_title", content: .auth(value: (UIApplication.shared.delegate as! AppDelegate).isOpenLocalAuthState()))
        let languageItem = SettingItem(title: "SettingsVC_languages_title", content: .language(value: Localize.currentLanguage()))

        if isSupportLocalAuth {
            datasource = [nodeSetItem, thresholdItem, resendItem, authItem, languageItem]
        } else {
            datasource = [nodeSetItem, thresholdItem, resendItem, languageItem]
        }
        tableView.reloadData()
    }

    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.selectionStyle = .none
        var title: String = ""
        let rigthArrowImgV = UIImageView(image: UIImage(named: "icon_right_arrow"))

        let item = datasource[indexPath.row]
        title = item.title
        switch item.content {
        case .none:
            cell.contentView.addSubview(rigthArrowImgV)
            rigthArrowImgV.snp.makeConstraints { (maker) in
                maker.right.equalToSuperview().offset(-18)
                maker.centerY.equalToSuperview()
            }
        case .threshold(let value):
            cell.contentView.addSubview(rigthArrowImgV)
            rigthArrowImgV.snp.makeConstraints { (maker) in
                maker.right.equalToSuperview().offset(-18)
                maker.centerY.equalToSuperview()
            }

            let lanL = UILabel(frame: .zero)
            lanL.text = (value/PlatonConfig.VON.LAT).description.displayForMicrometerLevel(maxRound: 8).ATPSuffix()
            lanL.textColor = UIColor(rgb: 0x000000)
            lanL.font = UIFont.systemFont(ofSize: 15)
            cell.contentView.addSubview(lanL)
            lanL.snp.makeConstraints { (maker) in
                maker.right.equalTo(rigthArrowImgV.snp.left).offset(-4)
                maker.centerY.equalToSuperview()
            }
        case .resend(let value):
            let `switch` = UISwitch(frame: .zero)
            `switch`.addTarget(self, action: #selector(switchResendRemainder(_ :)), for: .valueChanged)
            `switch`.isOn = value
            `switch`.onTintColor = UIColor(rgb: 0x4CD964)
            cell.contentView.addSubview(`switch`)
            `switch`.snp.makeConstraints { (maker) in
                maker.right.equalToSuperview().offset(-18)
                maker.centerY.equalToSuperview()
            }
        case .auth(let value):
            let `switch` = UISwitch(frame: .zero)
            `switch`.addTarget(self, action: #selector(switchLocalAuthSetting(_ :)), for: .valueChanged)
            `switch`.isOn = value
            `switch`.onTintColor = UIColor(rgb: 0x4CD964)
            cell.contentView.addSubview(`switch`)
            `switch`.snp.makeConstraints { (maker) in
                maker.right.equalToSuperview().offset(-18)
                maker.centerY.equalToSuperview()
            }
        case .language(let value):
            cell.contentView.addSubview(rigthArrowImgV)
            rigthArrowImgV.snp.makeConstraints { (maker) in
                maker.right.equalToSuperview().offset(-18)
                maker.centerY.equalToSuperview()
            }

            let lanL = UILabel(frame: .zero)
            if value == "en" {
                lanL.text = "English"
            } else {
                lanL.text = "简体中文"
            }
            lanL.textColor = UIColor(rgb: 0x000000)
            lanL.font = UIFont.systemFont(ofSize: 15)
            cell.contentView.addSubview(lanL)
            lanL.snp.makeConstraints { (maker) in
                maker.right.equalTo(rigthArrowImgV.snp.left).offset(-4)
                maker.centerY.equalToSuperview()
            }
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

    func showThresholdListView(value: BigUInt) {
        let listData = [
            BigUInt(100)*PlatonConfig.VON.LAT,
            BigUInt(1000)*PlatonConfig.VON.LAT,
            BigUInt(10000)*PlatonConfig.VON.LAT,
            BigUInt(100000)*PlatonConfig.VON.LAT,
            BigUInt(1000000)*PlatonConfig.VON.LAT]

        let type = PopSelectedViewType.threshold(datasource: listData, selected: value)
        let contentView = ThresholdValueSelectView(type: type)
        contentView.show(viewController: self)
        contentView.valueChangedHandler = { [weak self] value in
            switch value {
            case .threshold(_, let selected):
                SettingService.shareInstance.thresholdValue = selected
                self?.initData()
            default:
                break
            }
        }
    }

    // MARK: - UITableView Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = datasource[indexPath.row]
        switch item.content {
        case .none:
            navigationController?.pushViewController(NodeSettingViewControllerV2(), animated: true)
        case .threshold(let value):
            showThresholdListView(value: value)
        case .language(_):
            let vc = LanguageSettingVC()
            navigationController?.pushViewController(vc, animated: true)
        default:
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

enum SettingType {
    case none
    case threshold(value: BigUInt)
    case language(value: String)
    case auth(value: Bool)
    case resend(value: Bool)
}

struct SettingItem {
    var title: String
    var content: SettingType
}
