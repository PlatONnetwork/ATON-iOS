//
//  Transaction+Extension.swift
//  platonWallet
//
//  Created by Admin on 13/8/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import UIKit
import Localize_Swift

extension Transaction {
    func getTransactionDirection(_ currentAddress: String? = nil) -> TransactionDirection {
        guard let type = txType else { return .unknown }
        switch type {
        case .delegateWithdraw,
             .stakingWithdraw,
             .claimReward:
            return .Receive
        case .unknown:
            return .unknown
        case .transfer:
            guard let address = currentAddress else {
                let addresses = (AssetVCSharedData.sharedData.walletList as! [Wallet]).map { return $0.address.add0xBech32().lowercased() }
                if let fromAddress = to?.add0xBech32().lowercased(), addresses.contains(fromAddress) {
                    return .Receive
                }
                return .Sent
            }
            if address.add0xBech32().lowercased() == from?.add0xBech32().lowercased() {
                return .Sent
            } else if address.add0xBech32().lowercased() == to?.add0xBech32().lowercased() {
                return .Receive
            } else {
                return .unknown
            }
        default:
            return .Sent
        }
    }

    var toAvatarImage: UIImage? {
        switch txType! {
        case .transfer,
             .unknown:
            let localWallet = (AssetVCSharedData.sharedData.walletList as! [Wallet]).filter { $0.address.lowercased() == to?.lowercased() }.first
            guard let wallet = localWallet else {
                return UIImage(named: "walletAvatar_1")
            }
            return UIImage(named: wallet.avatar)
        case .claimReward:
            return UIImage(named: "2.icon_Shared")
        default:
            if toType == .contract {
                return UIImage(named: "2.icon_node")
            } else {
                return UIImage(named: "2.icon_Shared")
            }
        }
    }

    var fromAvatarImage: UIImage? {
        let localWallet = (AssetVCSharedData.sharedData.walletList as! [Wallet]).filter { $0.address.lowercased() == from?.lowercased() }.first
        guard let wallet = localWallet else {
            return UIImage(named: "walletAvatar_1")
        }
        return wallet.image()
    }

    var toNameString: String? {
        switch txType! {
        case .transfer,
             .unknown:
            let localWallet = (AssetVCSharedData.sharedData.walletList as! [Wallet]).filter { $0.address.lowercased() == to?.lowercased() }.first
            guard let wallet = localWallet else {
                if let addressBookWallet = AddressBookService.service.getAll().first(where: { $0.walletAddress?.lowercased() == to?.lowercased() }) {
                    return addressBookWallet.walletName
                } else {
                    return to?.addressForDisplayShortBech32()
                }
            }
            return wallet.name
        default:
            if let nName = nodeName, nName.count > 0 {
                return nName
            }
            return to?.addressForDisplayShortBech32()
        }
    }

    var fromNameString: String? {
        let localWallet = (AssetVCSharedData.sharedData.walletList as! [Wallet]).filter { $0.address.lowercased() == from?.lowercased() }.first
        guard let wallet = localWallet else {
            return from?.addressForDisplayShortBech32()
        }
        return wallet.name
    }

    var valueString: (String?, UIColor?) {
        if txReceiptStatus == -1 || txReceiptStatus == 0 || txReceiptStatus == -2 {
            return (nil, nil)
        }

        if let valueStr = value, Int(valueStr) == 0 {
            return (topValueDescription, UIColor(rgb: 0xb6bbd0))
        }

        if let type = txType, type == .claimReward {
            guard let string = topValueDescription else {
                return (nil, nil)
            }
            return ("+" + string, UIColor(rgb: 0x19a20e))
        }

        switch direction {
        case .Sent:
            guard let string = topValueDescription else {
                return (nil, nil)
            }
            return ("-" + string, UIColor(rgb: 0xff3b3b))
        case .Receive:
            guard let string = topValueDescription else {
                return (nil, nil)
            }
            return ("+" + string, UIColor(rgb: 0x19a20e))
        default:
            return (nil, nil)
        }
    }

    var toIconImage: UIImage? {
        switch toType {
        case .contract:
            return UIImage(named: "2.icon_node")
        default:
            return UIImage(named: "2.icon_Shared2")
        }
    }

    var toAddressIconImage: UIImage? {
        switch toType {
        case .contract:
            return UIImage(named: "2.icon_Shared2")
        default:
            return nil
        }
    }

    var amountTextString: String {
        if let valueStr = value, Int(valueStr) == 0 {
            return topValueDescription!
        }

        if txReceiptStatus == TransactionReceiptStatus.businessCodeError.rawValue
            || txReceiptStatus == TransactionReceiptStatus.timeout.rawValue {
            return topValueDescription!
        }

        if let type = txType, type == .claimReward {
            return "+" + topValueDescription!
        }

        switch direction {
        case .Sent:
            return "-" + topValueDescription!
        case .Receive:
            return "+" + topValueDescription!
        default:
            return "-" + topValueDescription!
        }
    }

    var typeTextColor: UIColor {
        if txReceiptStatus == TransactionReceiptStatus.businessCodeError.rawValue
            || txReceiptStatus == TransactionReceiptStatus.timeout.rawValue {
            return UIColor(white: 0.0, alpha: 0.5)
        }
        return UIColor.black
    }

    var amountTextColor: UIColor {
        if let valueStr = value, Int(valueStr) == 0 {
            return UIColor(rgb: 0xb6bbd0)
        }

        if (txReceiptStatus == TransactionReceiptStatus.businessCodeError.rawValue
            || txReceiptStatus == TransactionReceiptStatus.timeout.rawValue) {
            return UIColor(rgb: 0xb6bbd0)
        }

//        if let type = txType, type == .claimReward {
//            return UIColor(rgb: 0x19a20e)
//        }
        switch direction {
        case .Receive:
            return UIColor(rgb: 0x19a20e)
        case .Sent:
            return UIColor(rgb: 0xff3b3b)
        default:
            return UIColor(rgb: 0xb6bbd0)
        }
    }

    static func getTxTypeIconByDirection(direction: TransactionDirection, txType: TxType?) -> UIImage? {
        let tx = Transaction()
        tx.direction = direction
        tx.txType = txType
        return tx.txTypeIcon
    }

    var txTypeIcon: UIImage? {
        switch txType! {
        case .delegateCreate:
            return UIImage(named: "1.icon_Delegate")
        case .delegateWithdraw:
            return UIImage(named: "1.icon_Undelegate")
        case .contractCreate:
            return UIImage(named: "1.icon_Create a contract")
        case .contractExecute:
            return UIImage(named: "1.icon_Executing a contract")
        default:
            if direction == .Receive {
                return UIImage(named: "txRecvSign")
            } else {
                return UIImage(named: "txSendSign")
            }
        }
    }

    var pipString: String {
        guard let pip = piDID else { return "--" }
        return "PIP-" + pip
    }

    var versionDisplayString: String {
        guard let ver = version, let versionUInt32 = UInt32(ver) else { return "--" }
        let versionUInt32Bytes = versionUInt32.makeBytes()
        guard versionUInt32Bytes.count == 4 else { return "--" }
        let versionString = String(format: "V%d.%d.%d", versionUInt32Bytes[1],versionUInt32Bytes[2],versionUInt32Bytes[3])
        return versionString
    }
}

extension Transaction {
    var recordIconIV: UIImage? {
        switch txType! {
        case .delegateCreate:
            return UIImage(named: "1.icon_Delegate")
        case .delegateWithdraw:
            return UIImage(named: "1.icon_Undelegate")
        default:
            return UIImage(named: "1.icon_Delegate")
        }
    }

    var recordAmount: String? {
        switch txType! {
        case .delegateCreate:
            return value
        case .delegateWithdraw:
            return unDelegation
        default:
            return value
        }
    }

    var recordAmountForDisplay: String {
        return (recordAmount?.vonToLATString ?? "0").balanceFixToDisplay(maxRound: 8).ATPSuffix()
    }

    var recordStatus: (String, UIColor) {

        guard let type = txType else {
            if txReceiptStatus == 1 {
                return (Localized("TransactionStatus_succeed_desc"), status_green_color)
            } else if txReceiptStatus == 0 {
                return (Localized("TransactionStatus_failed_desc"), status_red_color)
            } else {
                return (Localized("TransactionStatus_pending_desc"), status_blue_color)
            }
        }

        switch type {
        case .delegateCreate:
            if txReceiptStatus == 1 {
                return (Localized("TransactionStatus_succeed_delegate"), status_green_color)
            } else if txReceiptStatus == 0 {
                return (Localized("TransactionStatus_failed_delegate"), status_red_color)
            } else {
                return (Localized("TransactionStatus_pending_desc"), status_blue_color)
            }
        case .delegateWithdraw:
            if txReceiptStatus == 1 {
                return (Localized("TransactionStatus_succeed_undelegate"), status_green_color)
            } else if txReceiptStatus == 0 {
                return (Localized("TransactionStatus_failed_undelegate"), status_red_color)
            } else {
                return (Localized("TransactionStatus_pending_desc"), status_blue_color)
            }
        default:
            if txReceiptStatus == 1 {
                return (Localized("TransactionStatus_succeed_desc"), status_green_color)
            } else if txReceiptStatus == 0 {
                return (Localized("TransactionStatus_failed_desc"), status_red_color)
            } else {
                return (Localized("TransactionStatus_pending_desc"), status_blue_color)
            }
        }
    }

    var recordTime: String? {
        let format = DateFormatter()
        let date = Date(timeIntervalSince1970: TimeInterval(confirmTimes/1000))
        let localZone = NSTimeZone.local
        format.timeZone = localZone
        format.locale = NSLocale.current
        format.dateFormat = "#yyyy/MMdd HH:mm:ss"
        let strDate = format.string(from: date)
        return strDate
    }

    var recordWalletName: String? {
        let localWallet = (AssetVCSharedData.sharedData.walletList as! [Wallet]).filter { $0.address.lowercased() == from?.lowercased() }.first
        return (localWallet?.name ?? "--")
    }

    var recordWalletAddress: String? {
        return from != nil ? "(" + (from?.addressForDisplayShortBech32() ?? "--") + ")" : ""
    }
}
