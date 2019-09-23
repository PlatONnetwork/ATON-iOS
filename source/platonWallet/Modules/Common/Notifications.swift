//
//  Notifications.swift
//  platonWallet
//
//  Created by matrixelement on 1/11/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation

extension Notification.Name {
    public struct ATON {
        public static let DidTabBarDoubleClick = Notification.Name("ATONDidTabBarDoubleClickNotification")
        public static let DidUpdateTransactionByHash = Notification.Name("DidUpdateTransactionByHashNotification")
        public static let WillUpdateUnreadDot = Notification.Name("WillUpdateUnreadDot_Notification")
        public static let DidUpdateAllAsset = Notification.Name("DidUpdateAllAssetNotification")
        public static let DidNodeGasPriceUpdate = Notification.Name("DidNodeGasPriceUpdateNotification")
        public static let WillDeleateWallet = Notification.Name("WillDeleateWallet_Notification")
        public static let updateWalletList = Notification.Name("updateWalletList_Notification")
        public static let BackupMnemonicFinish = Notification.Name("BackupMnemonicFinishNotification")
        public static let UpdateTransactionList = Notification.Name("UpdateTransactionList_Notification")
    }
}

