//
//  Notifications.swift
//  platonWallet
//
//  Created by matrixelement on 1/11/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation

let DidUpdateTransactionByHashNotification = "DidUpdateTransactionByHashNotification"

let DidUpdateSharedWalletTransactionList_Notification = "DidUpdateSharedWalletTransactionList_Notification"

let WillUpdateUnreadDot_Notification = "WillUpdateUnreadDot_Notification"

let DidUpdateAllAssetNotification = "DidUpdateAllAssetNotification"

let DidNodeGasPriceUpdateNotification = "DidNodeGasPriceUpdateNotification"

let DidJointWalletUpdateProgress_Notification = "DidJointWalletUpdateProgress_Notification"

let WillDeleateWallet_Notification = "WillDeleateWallet_Notification"

let updateWalletList_Notification = "updateWalletList_Notification"

let BackupMnemonicFinishNotification = "BackupMnemonicFinishNotification"

let ChangeCandidatesTableViewCellbackground = "ChangeCandidatesTableViewCellbackground"

extension Notification.Name {
    public struct ATON {
        public static let DidTabBarDoubleClick = Notification.Name("ATONDidTabBarDoubleClickNotification")
    }
}

