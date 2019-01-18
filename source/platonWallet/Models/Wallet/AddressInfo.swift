//
//  AddressInfo.swift
//  platonWallet
//
//  Created by matrixelement on 29/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import RealmSwift


let AddressType_AddressBook = 0
let AddressType_SharedWallet = 1

class AddressInfo : Object{
    
    @objc dynamic var addressType = 0

    @objc dynamic var uuid: String = NSUUID().uuidString
    @objc dynamic var  walletName : String?
    @objc dynamic var  walletAddress : String?
    @objc dynamic var createTime = Date().millisecondsSince1970
    @objc dynamic var updateTime = Date().millisecondsSince1970
    
    override public static func primaryKey() -> String? {
        return "uuid"
    }
}
