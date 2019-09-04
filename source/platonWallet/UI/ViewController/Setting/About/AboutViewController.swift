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
        versionLabel.text = Localized("about_current_version") + "V" + appVersion!
        versionIcon.backgroundColor = .red
        versionIcon.layer.cornerRadius = 5.0
        
        let appBuild = Bundle.main.infoDictionary!["CFBundleVersion"] as? String ?? ""
        let remoteVersion = SettingService.shareInstance.currentVersion?.version ?? ""
        if appBuild.compare(remoteVersion) == ComparisonResult.orderedAscending {
            versionIcon.isHidden = false
        } else {
            versionIcon.isHidden = true
        }
    }

    @IBAction func aboutUs(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "https://www.platon.network")!)
    }
    
    @IBAction func softwareUpdate(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "https://developer.platon.network/mobile/index.html")!)
        //UIApplication.shared.openURL(URL(string: "https://github.com/PlatONnetwork")!)
    }
}
