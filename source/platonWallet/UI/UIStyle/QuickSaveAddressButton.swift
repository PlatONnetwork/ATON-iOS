//
//  QuickSaveAddressButton.swift
//  platonWallet
//
//  Created by Ned on 14/3/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import UIKit
import Localize_Swift

enum QuickSaveStatus {
    case QuickSaveEnable, QuickSaveDisable
}

class QuickSaveAddressButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func initViews() {
        self.status = .QuickSaveDisable
    }

    var status: QuickSaveStatus = .QuickSaveDisable {
        didSet {
            if status == .QuickSaveEnable {
                self.setTitleColor(UIColor(rgb: 0x105CFE), for: .normal)
            } else {
                self.setTitleColor(UIColor(rgb: 0xB6BBD0), for: .normal)
            }
        }
    }

    func checkAndUpdateStatus(address: String?, name: String?) {
        DispatchQueue.main.async {
            //exe in queue
            guard address != nil, address!.is40ByteAddress(), name != nil, CommonService.isValidWalletName(name!).0 else {
                self.status = .QuickSaveDisable
                return
            }
            if AddressBookService.service.getAll().contains(where: {($0.walletAddress?.ishexStringEqual(other: address!))!}) {
                self.status = .QuickSaveDisable
            } else {
                self.status = .QuickSaveEnable
            }
        }
    }

    func quickSave(address: String?, name: String?) {
        guard address != nil, name != nil, CommonService.checkNewAddressName(name).0, address!.is40ByteAddress(), !AddressBookService.service.getAll().contains(where: {($0.walletAddress?.ishexStringEqual(other: address!))!}) else {
            return
        }
        let addressInfo = AddressInfo()
        addressInfo.addressType = AddressType_AddressBook
        addressInfo.walletName = name
        addressInfo.walletAddress = address
        AddressBookService.service.add(addressInfo: addressInfo)
        UIApplication.rootViewController().showMessage(text: Localized("SettingsVC_savesuccessfully"))
    }

}
