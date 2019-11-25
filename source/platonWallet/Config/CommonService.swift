//
//  CommonService.swift
//  platonWallet
//
//  Created by matrixelement on 2018/10/24.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import Localize_Swift
import BigInt

struct CommonService {

    static func isValidContractAddress(_ address: String?) -> (Bool,String?) {

        guard address != nil && address!.length > 0 else {
            return (false, Localized("transferVC_address_empty_tip"))
        }

        guard address != nil && (address?.is40ByteAddress())! else {
            return (false, Localized("transferVC_address_Incorrect_tip"))
        }

        return (true, nil)
    }

    static func isValidWalletName(_ name:String?,checkDuplicate: Bool = false) -> (Bool,String?) {

        guard name != nil && name!.length > 0 else {
            return (false, Localized("wallet_nameInput_empty_tips"))
        }
        let trimmingName = name!.trimmingCharacters(in: CharacterSet(charactersIn: " "))

        guard trimmingName.length > 0 else {
            return (false, Localized("wallet_nameInput_empty_tips"))
        }

        guard name!.length <= 12 else {
            return (false, Localized("wallet_nameInput_lengthIllegal_tips"))
        }
        if checkDuplicate {
            let wallets = WalletService.sharedInstance.wallets.filter {$0.name == name}
            if wallets.count > 0 {
                return (false, Localized("wallet_name_duplicate"))
            }
        }
        return (true, nil)
    }

    static func checkNewAddressName(_ name:String?) -> (Bool,String?) {

        guard name != nil && name!.length > 0 else {
            return (false, Localized("NewAddress_name_empty_tip"))
        }
        let trimmingName = name!.trimmingCharacters(in: CharacterSet(charactersIn: " "))

        guard trimmingName.length > 0 else {
            return (false, Localized("NewAddress_name_empty_tip"))
        }

        guard name!.length <= 12 else {
            return (false, Localized("NewAddress_name_Incorrect_tip"))
        }
        return (true, nil)
    }

    static func checkNewAddressString(_ address: String?)  -> (Bool,String?) {

        guard address != nil && address!.length > 0 else {
            return (false, Localized("NewAddress_address_empty_tip"))
        }
        let trimmingName = address!.trimmingCharacters(in: CharacterSet(charactersIn: " "))

        guard trimmingName.length > 0 else {
            return (false, Localized("NewAddress_address_empty_tip"))
        }

        guard (address?.is40ByteAddress())! else {
            return (false, Localized("NewAddress_address_Incorrect_tip"))
        }
        return (true, nil)
    }

    static func isValidWalletPassword(_ psw:String?, confirmPsw:String? = nil) -> (Bool,String?) {

        guard psw != nil && psw!.length > 0 else {
            return (false, Localized("wallet_pswInput_empty_tips"))
        }

        guard psw!.length >= 6 else {
            return (false, Localized("wallet_pswInput_lengthIllegal_tips"))
        }

        if (confirmPsw != nil) {
            guard confirmPsw!.length > 0 else {
                return (false, Localized("wallet_pswConfirmInput_empty_tips"))
            }

            guard confirmPsw! == psw! else {
                return (false, Localized("wallet_pswConfirmInput_mismatch_tips"))
            }
        }

        return (true, "")

    }

    static func checkTransferAddress(text: String) -> (Bool,String) {
        var valid = true
        var msg = ""
        if text.length == 0 {
            msg = Localized("transferVC_address_empty_tip")
            valid = false
        }

        if (!text.is40ByteAddress()) {
            msg = Localized("transferVC_address_Incorrect_tip")
            valid = false
        }
        return (valid,msg)
    }

    static func checkTransferAmoutInput(text: String, checkBalance: Bool = false, minLimit: BigUInt? = nil, maxLimit: BigUInt? = nil, fee: BigUInt? = BigUInt("0")!, type: SendInputTableViewCellType?) -> (Bool, String) {

        if text.count == 0 {
            return (true, "")
        }

        var valid = true
        var msg = ""
//        if text.length == 0 {
//            msg = Localized("transferVC_amout_empty_tip")
//            valid = false
//        }

        if (!(text.isValidInputAmoutWith8DecimalPlaceAndNonZero())) {
            msg = Localized("transferVC_amout_amout_input_error")
            valid = false
        }

        if let minLimitAmount = minLimit, let inputVON = BigUInt.mutiply(a: text, by: ETHToWeiMultiplier), inputVON < minLimitAmount {
            if let inputType = type, inputType == .withdraw {
                msg = Localized("staking_withdraw_input_amount_minlimit_error", arguments: minLimitAmount.description)
            } else {
                msg = Localized("staking_input_amount_minlimit_error", arguments: minLimitAmount.description)
            }

            valid = false
        }

        if let maxLimitAmount = maxLimit, let inputVON = BigUInt.mutiply(a: text, by: ETHToWeiMultiplier), inputVON > maxLimitAmount {
            if let inputType = type, inputType == .withdraw {
                msg = Localized("staking_withdraw_input_amount_maxlimit_error")
            } else {
                msg = Localized("staking_input_amount_maxlimit_error")
            }

            valid = false
        }

        if checkBalance {
            let balance = AssetService.sharedInstace.balances.first(where: { $0.addr.lowercased() == text.lowercased() })
            if balance == nil {
                //balance not exist return true
                return (true, "")
            }
        }

        return (valid, msg)

    }
}
