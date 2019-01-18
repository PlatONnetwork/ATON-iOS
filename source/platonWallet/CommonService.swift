//
//  CommonService.swift
//  platonWallet
//
//  Created by matrixelement on 2018/10/24.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import Localize_Swift

struct CommonService {
    
    static func isValidContractAddress(_ address: String?) -> (Bool,String?){
        
        guard address != nil && address!.length > 0 else {
            return (false, Localized("transferVC_address_empty_tip"))
        }
        
        guard address != nil && (address?.is40ByteAddress())! else {
            return (false, Localized("transferVC_address_Incorrect_tip"))
        }
        
        return (true, nil)
    }
    
    static func isValidWalletName(_ name:String?) -> (Bool,String?) {
        
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

        return (true, nil)
        
    }
    
}
