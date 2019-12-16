//
//  AboutViewController.swift
//  platonWallet
//
//  Created by Ned on 13/12/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class AboutViewController: BaseViewController {

    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var versionIcon: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        super.leftNavigationTitle = "AboutVC_nav_title"

        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String

        versionIcon.backgroundColor = .red
        versionIcon.layer.cornerRadius = 5.0

        versionLabel.text = ((SettingService.shareInstance.remoteVersion?.isNeed == true) ? Localized("about_latest_version") : Localized("about_current_version")) + "V" + appVersion!
        versionIcon.isHidden = !(SettingService.shareInstance.remoteVersion?.isNeed == true)
    }

    @IBAction func aboutUs(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "https://www.platon.network")!)
    }

    @IBAction func softwareUpdate(_ sender: Any) {
        guard SettingService.shareInstance.remoteVersion?.isNeed == true else {
            showMessage(text: Localized("about_version_update_latest"), delay: 2.0)
            return
        }

        UIApplication.shared.openURL(URL(string: SettingService.shareInstance.remoteVersion?.url ?? "https://itunes.apple.com/cn/app/id1473112418?mt=8")!)
    }

    @IBAction func privacyPolicy(_ sender: Any) {
        let controller = WebCommonViewController()
//        controller.navigationTitle = Localized("delegate_faq_title")
        controller.requestUrl = AppConfig.H5URL.PrivacyPolicyURL.policyurl
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
//        UIApplication.shared.openURL(URL(string: "https://www.platon.network")!)
    }
}
