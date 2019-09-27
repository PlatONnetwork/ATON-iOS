//
//  AppDelegate.swift
//  platonWallet
//
//  Created by matrixelement on 15/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import RTRootNavigationController
import RealmSwift   
import BigInt
import LocalAuthentication
import platonWeb3
import Localize_Swift

private let userDefault_key_isLocalAuthenticationOpen = "isLocalAuthenticationOpen"
private let userDefault_key_isFirst = "isFirst"


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, LicenseVCDelegate {

    var window: UIWindow?
    {
        didSet{
            //must set to white,or Dark shadow on navigation bar during segue transition
            window?.backgroundColor = .white
        }
    }

    var laContext = LAContext()
    
    var verifyWindow: UIWindow?
 
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupMonkeyTest()
        
        let status = AppFramework.sharedInstance.initialize()
        
        let storyboard = UIStoryboard(name: "LaunchScreen", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LaunchViewController")
        self.window?.rootViewController = controller
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.initUI(initSuccess:status)
        }
        
        return true
    }
    
    func initStatusBar(){
        (UIApplication.shared.value(forKey: "statusBar") as? UIView)?.backgroundColor = .clear
    }
    
    func initUI(initSuccess: Bool) {
        
        self.initStatusBar()
        
        UserDefaults.standard.register(defaults: [userDefault_key_isFirst:true, userDefault_key_isLocalAuthenticationOpen:false])
        
        gotoNextVC(initSuccess:initSuccess)
        
        checkIsOpenLocalAuth()
    }
    
    private func checkIsOpenLocalAuth() {
        
        guard isOpenLocalAuthState() else {
            return
        }
        
        var closeAuthWhileUnlock = false
        var error: NSError?
        laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        if error != nil && error!.code == kLAErrorBiometryNotEnrolled {
            closeAuthWhileUnlock = true
        }
            
        let localAuthVC: BiometricsAuthViewController
        
        if #available(iOS 11.0, *), laContext.biometryType == .faceID {
            
            localAuthVC = BiometricsAuthViewController(biometricsType: .face, completion: {
                completion()
            })
            
        } else {
            localAuthVC = BiometricsAuthViewController(biometricsType: .touch, completion: {
                completion()
            })
        }
        
        func completion() {
            self.verifyWindow?.isHidden = true
            self.verifyWindow?.removeFromSuperview()
            if closeAuthWhileUnlock {
                self.localAuthStateSwitch(false)
            }
        }
        verifyWindow = UIWindow(frame: CGRect(x: 0, y: 0, width: kUIScreenWidth, height: kUIScreenHeight))
        verifyWindow!.windowLevel = window!.windowLevel + 1
        verifyWindow!.rootViewController = BaseNavigationController(rootViewController:localAuthVC)
        verifyWindow!.isHidden = false
    }
    
    private func gotoNextVC(initSuccess: Bool = true) {
        if !initSuccess{
            return
        }
        
//        if UserDefaults.standard.bool(forKey: userDefault_key_isFirst) {
//            gotoAgreementController()
//        }else {
            gotoAtonController()
//        }
    }
    
    func gotoAtonController() {
        if WalletService.sharedInstance.wallets.count > 0 {
            gotoMainTab()
            getRemoteVersion()
        }else {
            gotoWalletCreateVC()
        }
    }
    
    func gotoAgreementController() {
        let controller = ServiceAgreementViewController()
        controller.nextActionHandler = { [weak self] in
            UserDefaults.standard.set(false, forKey: userDefault_key_isFirst)
            UserDefaults.standard.synchronize()
            self?.gotoAtonController()
        }
        let navController = BaseNavigationController(rootViewController: controller)
        self.window?.rootViewController = navController
    }
    
    func gotoMainTab() {
        let navController = UINavigationController(rootViewController: MainTabBarViewController.newTabBar())
        navController.setNavigationBarHidden(true, animated: false)
        self.window?.rootViewController = navController
    }
    
    func gotoWalletCreateVC() {
        let nav = BaseNavigationController(rootViewController: WalletCreateOrImportViewController())
        self.window?.rootViewController = nav
    }
    
    func gotoWalletCreateSuccessVC(){
        self.window?.rootViewController = BaseNavigationController(rootViewController: CreateWalletSuccessViewController())
    }
    
    
    func localAuthStateSwitch(_ open:Bool) {
        UserDefaults.standard.set(open, forKey: userDefault_key_isLocalAuthenticationOpen)
        UserDefaults.standard.synchronize()
    }
    
    func isOpenLocalAuthState() -> Bool {
        return UserDefaults.standard.bool(forKey: userDefault_key_isLocalAuthenticationOpen)
    }
    
    ///LicenseVCDelegate
    func didClickNextStep() {
        
        UserDefaults.standard.set(false, forKey: userDefault_key_isFirst)
        UserDefaults.standard.synchronize()
        gotoNextVC()
        
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        getRemoteVersion()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


extension AppDelegate {
    func getRemoteVersion() {
        guard let _ = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarViewController else { return }
        SettingService.shareInstance.getRemoteVersion { [weak self] (result, data) in
            switch result {
            case .success:
                let appBuild = Bundle.main.infoDictionary!["CFBundleVersion"] as? String ?? ""
                let remoteBuild = SettingService.shareInstance.currentVersion?.build ?? ""
                if Int(appBuild) ?? 0 < Int(remoteBuild) ?? 0 {
                    guard
                        let localDate = UserDefaults.standard.object(forKey: "UpdateVersionAlertDate") as? Date,
                        Calendar.current.isDate(localDate, inSameDayAs: Date()) else {
                            UserDefaults.standard.set(Date(), forKey: "UpdateVersionAlertDate")
                            self?.showShouldUpdateVersionAlert()
                            return
                    }
                    
                    if SettingService.shareInstance.currentVersion?.isForce == true {
                        self?.showShouldUpdateVersionAlert()
                    }
                    UserDefaults.standard.set(Date(), forKey: "UpdateVersionAlertDate")
                }
            case .fail(_, _):
                break
            }
        }
    }
    
    func showShouldUpdateVersionAlert() {
        let controller = UIAlertController(title: Localized("about_version_update_alert_title"), message: Localized("about_version_update_alert_message_1") + (SettingService.shareInstance.currentVersion?.version ?? "") + Localized("about_version_update_alert_message_2"), preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: Localized("about_version_update_alert_cancel"), style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: Localized("about_version_update_alert_ok"), style: .default) { (_) in
            UIApplication.shared.openURL(URL(string: SettingService.shareInstance.currentVersion?.appStoreId ?? "https://developer.platon.network/mobile/index.html")!)
        }
        if SettingService.shareInstance.currentVersion?.isForce == false {
            controller.addAction(cancelAction)
        }
        controller.addAction(okAction)
        UIApplication.shared.keyWindow?.rootViewController?.present(controller, animated: true, completion: nil)
    }
}
