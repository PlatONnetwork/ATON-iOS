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
import platonWeb3

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

        guard name!.length <= 20 else {
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

    static func checkAmountLimit(
        balance: BigUInt, // 可用余额
        amount: BigUInt, // 交易金额
        minLimit: BigUInt?, // 最小可交易金额
        maxLimit: BigUInt?, // 最大可交易金额
        fee: BigUInt?, // 手续费
        type: SendInputTableViewCellType,
        isLockAmount: Bool? = false) -> (Bool, String?) {

        var valid = true
        var message: String?

        let feeBInt: BigUInt = fee ?? BigUInt.zero

        if
            let minLimitBInt = minLimit,
            amount < minLimitBInt {
            valid = false
            if type == .withdraw {
                message = Localized("staking_withdraw_input_amount_minlimit_error", arguments: (minLimitBInt/PlatonConfig.VON.LAT).description)
            } else if type == .delegate {
                message = Localized("staking_input_amount_minlimit_error", arguments: (minLimitBInt/PlatonConfig.VON.LAT).description)
            }
            return (valid, message)
        }

        if
            let maxLimitBInt = maxLimit,
            amount > maxLimitBInt {
            valid = false
            if type == .withdraw {
                message = Localized("staking_withdraw_input_amount_maxlimit_error")
            } else if type == .delegate {
                message = Localized("staking_input_amount_maxlimit_error")
            } else {
                message = Localized("transferVC_Insufficient_balance")
            }
            return (valid, message)
        }

        if type == .withdraw {
            if balance < feeBInt {
                valid = false
                message = Localized("staking_withdraw_balance_Insufficient_error")
            }
        } else if type == .delegate {
            if isLockAmount == true {
                if balance < feeBInt {
                    valid = false
                    message = Localized("staking_delegate_balance_Insufficient_error")
                }
            } else {
                if balance < feeBInt + amount {
                    valid = false
                    message = Localized("staking_delegate_balance_Insufficient_error")
                }
            }
        } else {
            if balance < feeBInt {
                valid = false
                message = Localized("transferVC_Insufficient_balance_for_gas")
            }
        }

        return (valid, message)
    }

    static func checkStakingAmoutInput(inputVON: BigUInt?, balance: BigUInt, minLimit: BigUInt? = nil, maxLimit: BigUInt? = nil, fee: BigUInt? = BigUInt("0")!, type: SendInputTableViewCellType?, isLockAmount: Bool? = false) -> (Bool, String) {

        // if input empty, not regular
        guard let amountVON = inputVON else {
            return (true, "")
        }

        guard amountVON > BigUInt.zero else {
            return (false, Localized("transferVC_amout_amout_input_error"))
        }

        let (valid, message) = checkAmountLimit(balance: balance, amount: amountVON, minLimit: minLimit ?? .zero, maxLimit: maxLimit, fee: fee, type: type ?? .transfer, isLockAmount: isLockAmount)
        guard valid == true else {
            return (valid, message ?? "")
        }

        return (true, "")
    }

    static func checkStakingAmoutInput(text: String, balance: BigUInt, minLimit: BigUInt? = nil, maxLimit: BigUInt? = nil, fee: BigUInt? = BigUInt("0")!, type: SendInputTableViewCellType?, isLockAmount: Bool? = false) -> (Bool, String) {

        // if input empty, not regular
        guard text.count > 0 else {
            return (true, "")
        }

        guard text.isValidInputAmoutWith8DecimalPlaceAndNonZero() else {
            return (false, Localized("transferVC_amout_amout_input_error"))
        }

        guard let inputVON = BigUInt.mutiply(a: text, by: PlatonConfig.VON.LAT.description) else {
            return (false, Localized("transferVC_amout_amout_input_error"))
        }

        let (valid, message) = checkAmountLimit(balance: balance, amount: inputVON, minLimit: minLimit ?? .zero, maxLimit: maxLimit, fee: fee, type: type ?? .transfer)
        guard valid == true else {
            return (valid, message ?? "")
        }

        return (true, "")
    }
}
