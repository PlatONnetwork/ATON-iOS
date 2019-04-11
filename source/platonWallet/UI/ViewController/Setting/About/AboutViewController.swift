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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        super.leftNavigationTitle = "AboutVC_nav_title"
        
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        versionLabel.text = "V" + appVersion!
    }

    @IBAction func aboutUs(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "https://www.platon.network")!)
    }
    
    @IBAction func softwareUpdate(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "https://developer.platon.network/mobile/index.html")!)
        //UIApplication.shared.openURL(URL(string: "https://github.com/PlatONnetwork")!)
    }
}
