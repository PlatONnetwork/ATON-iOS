//
//  Utilities.swift
//  platonWallet
//
//  Created by matrixelement on 13/11/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation


func GetCurrentSystemSettingLanguage() -> String {
    let preferredLang = Bundle.main.preferredLocalizations.first! as NSString
    switch String(describing: preferredLang) {
    case "en-US", "en-CN":
        return "en"
    case "zh-Hans-US","zh-Hans-CN","zh-Hant-CN","zh-TW","zh-HK","zh-Hans":
        return "cn"
    default:
        return "en"
    }
}

