//
//  TwoHourTransaction.swift
//  platonWallet
//
//  Created by Admin on 4/12/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import RealmSwift

class TwoHourTransaction: Object {
    @objc dynamic var chainId: String = ""
    @objc dynamic var from : String? = ""
    @objc dynamic var to : String?  = ""
    @objc dynamic var value : String? = ""
    @objc dynamic var createTime = 0
}
