//
//  MainTabBarViewController.swift
//  platonWallet
//
//  Created by matrixelement on 17/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class MainTabBarViewController: UITabBarController {
    
    public static func newTabBar() -> MainTabBarViewController{
        let tabBarViewController = MainTabBarViewController()
        
        let assetNav = BaseNavigationController(rootViewController: AssetViewController())
        let personalNav = BaseNavigationController(rootViewController: PersonalViewController())
        
        assetNav.tabBarItem.image = UIImage(named: "tabbar_asset_unselected")
        assetNav.tabBarItem.selectedImage = UIImage(named: "tabbar_asset_selected")
        assetNav.tabBarItem.localizedText = "tabbar_asset_title"
     
        personalNav.tabBarItem.image = UIImage(named: "tabbar_personal_unselected")
        personalNav.tabBarItem.selectedImage = UIImage(named: "tabbar_personal_selected")
        personalNav.tabBarItem.localizedText  = "tabbar_personal_title"
        
        configureTabbarStyle()
        configureNavigationBarStyle()
        
        tabBarViewController.viewControllers = [assetNav,personalNav]
        return tabBarViewController
    }
    
    static func configureTabbarStyle(){
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(rgb: 0xCDCDCD)], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(rgb: 0xFFED54)], for: .selected)
        UITabBar.appearance().barTintColor = UIColor(rgb: 0x232D47)
        UITabBar.appearance().tintColor = UIColor(rgb: 0xFFED54)
    }
    
    static func configureNavigationBarStyle(){
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.isTranslucent = false
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
