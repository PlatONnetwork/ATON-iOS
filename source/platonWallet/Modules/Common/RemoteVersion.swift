//
//  RemoteVersion.swift
//  platonWallet
//
//  Created by Admin on 3/9/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation

struct RemoteVersion: Decodable {
    var isNeed: Bool?
    var isForce: Bool?
    var newVersion: String?
    var url: String?
    var desc: String?
}
