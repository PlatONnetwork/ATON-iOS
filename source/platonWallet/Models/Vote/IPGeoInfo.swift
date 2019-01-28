//
//  CountryArea.swift
//  platonWallet
//
//  Created by Ned on 25/12/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import RealmSwift
import Localize_Swift

class IPGeoInfo : Object {
    
    @objc dynamic var ipAddr: String! = ""
    @objc dynamic var countryCode : String! = ""
    @objc dynamic var updateTime : Int = 0
    
    lazy var countryCodeDic: [String : [String : String]] = {
        
        let url = Bundle.main.url(forResource: "PlatonAssets/CountryCode_ISO3166-2", withExtension: "json")
        let dic = try! JSONDecoder().decode(([String:[String:String]]).self, from: Data(contentsOf: url!))
        return dic
        
    }()
    
    var localizeCountryName: String? {
        get {
            guard let country = countryCodeDic[countryCode] else {
                return nil
            }
            if Localize.currentLanguage() == "en" {
                return country["EN"]
            }else {
                return country["CN"]
            }
        }
    }
    
    override public static func primaryKey() -> String? {
        return "ipAddr"
    }
    
    override public static func ignoredProperties() ->[String] {
        return ["countryCodeDic"]
    }
}

