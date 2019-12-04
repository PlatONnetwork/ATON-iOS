//
//  AppFramework.swift
//  platonWallet
//
//  Created by matrixelement on 19/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import Localize_Swift
import RealmSwift
import BigInt
import platonWeb3

class AppFramework {

    static let sharedInstance = AppFramework()

    func initialize() -> Bool {
        initUMeng()
        initNetworkObserver()

        initUShare()
        doSwizzle()
        if !RealmConfiguration() {
            return false
        }
        modulesConfigure()

        UIButton.methodExchange()
        UIFont.methodExchange()
        return true
    }

    func initweb3() {
        Debugger.enableDebug(true)
    }

    func initNetworkObserver() {
        NetworkManager.shared.startNetworkReachabilityObserver()
    }

    func initUShare() {
        UMSocialManager.default()?.setPlaform(.facebook, appKey: "2374479646134721", appSecret: "ba15cb39bbed20f42af9861c411d4c64", redirectURL: "www.platon.network")
//        UMSocialManager.default()?.setPlaform(.twitter, appKey: "", appSecret: "", redirectURL: "")
        UMSocialManager.default()?.setPlaform(.sina, appKey: "3563537424", appSecret: "a0369254eaa7c9a95b403efbe5eecf9f", redirectURL: "www.platon.network")
    }

    func initUMeng() {
        UMConfigure.initWithAppkey(AppConfig.Keys.Production_Umeng_key, channel: "App Store")
        MobClick.setAutoPageEnabled(true)
        UMConfigure.setLogEnabled(true)
    }

    func modulesConfigure() {
        _ = AssetService.sharedInstace
        _ = TransactionService.service
    }

    func RealmConfiguration() -> Bool {
        do {
            _ = try Realm(configuration: RealmHelper.getConfig())
            // 删除缓存在本地且已经被链上确认删除的交易
            TransferPersistence.deleteConfirmedTransaction()
            return true
        } catch let e as Realm.Error where e.code == .addressSpaceExhausted {
            print("realm缓存文件太大了")
            // 处理
            return false
        } catch {
            return false
        }
    }

    func doSwizzle() {

        //RTRootNavigationController.doBadSwizzleStuff()
        UIViewController.doBadSwizzleStuff()
    }
}
