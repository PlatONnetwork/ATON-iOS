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
import CryptoSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? {
        didSet {
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

    func initStatusBar() {
        if #available(iOS 13, *)
        {
            let statusBar = UIView(frame: (UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame)!)
            statusBar.backgroundColor = .clear
            UIApplication.shared.keyWindow?.addSubview(statusBar)
        } else {
           // ADD THE STATUS BAR AND SET A CUSTOM COLOR
           let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
           if statusBar.responds(to:#selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = .clear
           }
        }
//        (UIApplication.shared.value(forKey: "statusBar") as? UIView)?.backgroundColor = .clear
    }

    func initUI(initSuccess: Bool) {

        self.initStatusBar()

        UserDefaults.standard.register(defaults: [LocalKeys.isFirst: true, LocalKeys.isLocalAuthenticationOpen: false])
        gotoNextVC(initSuccess:initSuccess)

        checkIsOpenLocalAuth()

        TimerService.shared.startObserver { [weak self] (result) in
            guard result else { return }
            self?.checkIsOpenLocalAuth()
        }
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
        if !initSuccess {
            return
        }

        if UserDefaults.standard.bool(forKey: LocalKeys.isFirst) {
            gotoAgreementController()
        }else {
            gotoAtonController()
        }
    }

    func gotoAtonController() {
        NetworkStatusService.shared.startNetworkObserver()
        if WalletService.sharedInstance.wallets.count > 0 {
            gotoMainTab()
            getRemoteConfig()
        } else {
            gotoWalletCreateVC()
        }
        getRemoteVersion()
    }

    func gotoAgreementController() {
        let controller = ServiceAgreementViewController()
        controller.nextActionHandler = { [weak self] in
            UserDefaults.standard.set(false, forKey: LocalKeys.isFirst)
            UserDefaults.standard.synchronize()
            self?.gotoAtonController()
        }
        let navController = BaseNavigationController(rootViewController: controller)
        self.window?.rootViewController = navController
    }

    func gotoMainTab() {
        self.window?.rootViewController = MainTabBarViewController.newTabBar()
    }

    func gotoWalletCreateVC() {
        let nav = BaseNavigationController(rootViewController: WalletCreateOrImportViewController())
        self.window?.rootViewController = nav
    }

//    func gotoWalletCreateSuccessVC() {
//        self.window?.rootViewController = BaseNavigationController(rootViewController: CreateWalletSuccessViewController())
//    }

    func localAuthStateSwitch(_ open:Bool) {
        UserDefaults.standard.set(open, forKey: LocalKeys.isLocalAuthenticationOpen)
        UserDefaults.standard.synchronize()
    }

    func isOpenLocalAuthState() -> Bool {
        return UserDefaults.standard.bool(forKey: LocalKeys.isLocalAuthenticationOpen)
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
//        getRemoteVersion()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

extension AppDelegate {
    func getRemoteConfig() {
        RemoteServices.getConfig { (result, remoteConfig) in
            switch result {
            case .success:
                SettingService.shareInstance.remoteConfig = remoteConfig
            case .failure(let error):
                UIApplication.shared.keyWindow?.rootViewController?.showErrorMessage(text: error?.message ?? "server error")
            }
        }
    }

    func getRemoteVersion() {
        RemoteServices.getRemoteVersion {[weak self] (result, response) in
            guard let self = self else { return }
            switch result {
            case .success:
                SettingService.shareInstance.remoteVersion = response

                guard SettingService.shareInstance.remoteVersion?.isNeed == true else { return }
                let isForceUpdate = SettingService.shareInstance.remoteVersion?.isForce ?? false
                if isForceUpdate == true {
                    self.showShouldUpdateVersionAlert()
                } else {
                    if let localDate = UserDefaults.standard.object(forKey: "UpdateVersionAlertDate") as? Date {
                        // 不是同一天才能更新
                        if Calendar.current.isDate(localDate, inSameDayAs: Date()) == true {
                            return
                        }
                        self.showShouldUpdateVersionAlert()
                        UserDefaults.standard.set(Date(), forKey: "UpdateVersionAlertDate")
                    }
                    else {
                        /// 没有记录
                        self.showShouldUpdateVersionAlert()
                        UserDefaults.standard.set(Date(), forKey: "UpdateVersionAlertDate")
                    }
                }
                
                
                /*
                guard
                    let localDate = UserDefaults.standard.object(forKey: "UpdateVersionAlertDate") as? Date,
                    Calendar.current.isDate(localDate, inSameDayAs: Date()) else {
                        UserDefaults.standard.set(Date(), forKey: "UpdateVersionAlertDate")
                        self.showShouldUpdateVersionAlert()
                        return
                }

                guard SettingService.shareInstance.remoteVersion?.isForce == true else { return }
                self.showShouldUpdateVersionAlert()
                UserDefaults.standard.set(Date(), forKey: "UpdateVersionAlertDate")
 */
            case .failure(let error):
                UIApplication.shared.keyWindow?.rootViewController?.showErrorMessage(text: error?.message ?? "server error")
            }
        }
    }

    func showShouldUpdateVersionAlert() {
        /*
        let controller = UIAlertController(title: Localized("about_version_update_alert_title"), message: Localized("about_version_update_alert_message_1") + (SettingService.shareInstance.remoteVersion?.newVersion ?? "") + Localized("about_version_update_alert_message_2"), preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: Localized("about_version_update_alert_cancel"), style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: Localized("about_version_update_alert_ok"), style: .default) { (_) in
            UIApplication.shared.openURL(URL(string: SettingService.shareInstance.remoteVersion?.url ?? "https://developer.platon.network/mobile/index.html")!)
        }
        if SettingService.shareInstance.remoteVersion?.isForce == false {
            controller.addAction(cancelAction)
        }
        controller.addAction(okAction)
        window?.rootViewController?.present(controller, animated: true, completion: nil)
        */
        if let rootVC = window?.rootViewController {
            let newVersion = SettingService.shareInstance.remoteVersion?.newVersion ?? ""
            let isForceUpdate = SettingService.shareInstance.remoteVersion?.isForce ?? false
            let updateInfo = SettingService.shareInstance.remoteVersion?.desc ?? ""
            let vc = CheckUpdateVC(isForceUpdate: isForceUpdate, version: "V" + newVersion, updateInfo: updateInfo)
            vc.confirmCallback = {
                UIApplication.shared.openURL(URL(string: SettingService.shareInstance.remoteVersion?.url ?? "https://developer.platon.network/mobile/index.html")!)
            }
//            vc.cancelCallback = {
//
//            }
            vc.show(from: rootVC)
        }
        
    }
}
