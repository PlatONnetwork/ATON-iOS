//
//  MainTabBarViewController.swift
//  platonWallet
//
//  Created by matrixelement on 17/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift


extension UITabBarController {
    
    private struct AssociatedKeys {
        // Declare a global var to produce a unique address as the assoc object handle
        static var orgFrameView:     UInt8 = 0
        static var movedFrameView:   UInt8 = 1
    }
    
    var orgFrameView:CGRect? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.orgFrameView) as? CGRect }
        set { objc_setAssociatedObject(self, &AssociatedKeys.orgFrameView, newValue, .OBJC_ASSOCIATION_COPY) }
    }
    
    var movedFrameView:CGRect? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.movedFrameView) as? CGRect }
        set { objc_setAssociatedObject(self, &AssociatedKeys.movedFrameView, newValue, .OBJC_ASSOCIATION_COPY) }
    }
    
    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let movedFrameView = movedFrameView {
            view.frame = movedFrameView
        }
        
        //self.tabBar.shadowImage = UIImage(named: "imgFacebook")

    }
    
    func setTabBarVisible(visible:Bool, animated:Bool) {
        //since iOS11 we have to set the background colour to the bar color it seams the navbar seams to get smaller during animation; this visually hides the top empty space...
        view.backgroundColor =  self.tabBar.barTintColor
        // bail if the current state matches the desired state
        if (tabBarIsVisible() == visible) { return }
        
        //we should show it
        if visible {
            tabBar.isHidden = false
            UIView.animate(withDuration: animated ? 0.3 : 0.0) {
                //restore form or frames
                self.view.frame = self.orgFrameView!
                //errase the stored locations so that...
                self.orgFrameView = nil
                self.movedFrameView = nil
                //...the layoutIfNeeded() does not move them again!
                self.view.layoutIfNeeded()
            }
        }
            //we should hide it
        else {
            //safe org positions
            orgFrameView   = view.frame
            // get a frame calculation ready
            let offsetY = self.tabBar.frame.size.height
            movedFrameView = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height + offsetY)
            //animate
            UIView.animate(withDuration: animated ? 0.3 : 0.0, animations: {
                self.view.frame = self.movedFrameView!
                self.view.layoutIfNeeded()
            }) {
                (_) in
                self.tabBar.isHidden = true
            }
        }
    }
    
    func tabBarIsVisible() ->Bool {
        return orgFrameView == nil
    }
}

//extension UITabBarController {
//    func setTabBarHidden(_ isHidden: Bool, animated: Bool, completion: (() -> Void)? = nil ) {
//        if (tabBar.isHidden == isHidden) {
//            completion?()
//        }
//
//        if !isHidden {
//            tabBar.isHidden = false
//        }
//
//        let height = tabBar.frame.size.height
//        let offsetY = view.frame.height - (isHidden ? 0 : height)
//        let duration = (animated ? 0.25 : 0.0)
//
//        let frame = CGRect(origin: CGPoint(x: tabBar.frame.minX, y: offsetY), size: tabBar.frame.size)
//        UIView.animate(withDuration: duration, animations: {
//            self.tabBar.frame = frame
//        }) { _ in
//            self.tabBar.isHidden = isHidden
//            completion?()
//        }
//    }
//}

class MainTabBarViewController: UITabBarController {
    
    public static func newTabBar() -> UIViewController{
        
        let tabBarViewController = MainTabBarViewController()
        
        let assetVC = AssetViewControllerV060()
        let assetNav =  BaseNavigationController(rootViewController: assetVC)

        let candidateVC = CandidatesListViewController()
        let candidateListNav =  BaseNavigationController(rootViewController: candidateVC)
        
        let personalVC = PersonalViewController()
        let personalNav = BaseNavigationController(rootViewController: personalVC)
        
        assetNav.tabBarItem.image = UIImage(named: "tabbar_asset_unselected")
        assetNav.tabBarItem.selectedImage = UIImage(named: "tabbar_asset_selected")
        assetNav.tabBarItem.localizedText = "tabbar_asset_title"
        
        candidateListNav.tabBarItem.image = UIImage(named: "tabbar_candidate_unselected")
        candidateListNav.tabBarItem.selectedImage = UIImage(named: "tabbar_candidate_selected")
        candidateListNav.tabBarItem.localizedText  = "tabbar_candidate_title"
     
        personalNav.tabBarItem.image = UIImage(named: "tabbar_personal_unselected")
        personalNav.tabBarItem.selectedImage = UIImage(named: "tabbar_personal_selected")
        personalNav.tabBarItem.localizedText  = "tabbar_personal_title"
        
        configureTabbarStyle()
        configureNavigationBarStyle()
        
        tabBarViewController.viewControllers = [assetNav,candidateListNav,personalNav]
        
        tabBarViewController.tabBar.layer.borderWidth = 1
        tabBarViewController.tabBar.layer.borderColor = UIColor.white.cgColor
        tabBarViewController.tabBar.clipsToBounds = true
        
        return tabBarViewController
    }
    
    static func configureTabbarStyle(){
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(rgb: 0xBBBBBB)], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(rgb: 0x000000)], for: .selected)
        UITabBar.appearance().barTintColor = UIColor(rgb: 0xffffff)
        //UITabBar.appearance().tintColor = UIColor(rgb: 0x105CFE)
    }
    
    static func configureNavigationBarStyle(){
        
    }
    
    
    let sepline = UIView(frame: .zero)
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if sepline.superview == nil{
            self.tabBar.addSubview(sepline)
            sepline.backgroundColor = UIColor(rgb: 0xF2F5FA)
            sepline.snp.makeConstraints { (make) in
                make.leading.trailing.top.equalToSuperview()
                make.height.equalTo(2)
            }
        }
        //self.tabBar.bringSubviewToFront(sepline)
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.isTranslucent = false
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    

    static func setTabbarHide(hide: Bool){
        return
        if let tabbarViewController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarViewController{
            tabbarViewController.setTabBarVisible(visible: !hide, animated: true)
        }
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
