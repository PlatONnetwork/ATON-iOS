//
//  RemoteVersion.swift
//  platonWallet
//
//  Created by Admin on 3/9/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation

struct RemoteVersionResponse: Decodable {
    var data: RemoteVersioIOSResponse
}

struct RemoteVersioIOSResponse: Decodable {
    var ios: RemoteVersion
}

struct RemoteVersion: Decodable {
    var version: String?
    var build: String?
    var downloadUrl: String?
    var appStoreId: String?
    var isForce: Bool = false
}
