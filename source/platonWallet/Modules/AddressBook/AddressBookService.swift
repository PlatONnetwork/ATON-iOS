//
//  AddressBookService.swift
//  platonWallet
//
//  Created by matrixelement on 29/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation

class AddressBookService {
    static let service = AddressBookService()

    func add(addressInfo : AddressInfo) {
        AddressInfoPersistence.add(addrInfo: addressInfo)
    }

    func replaceInto(addrInfo: AddressInfo, completion: (() -> Void)? = nil) {
        AddressInfoPersistence.replaceInto(addrInfo: addrInfo, completion: completion)
    }

    func getAll() -> [AddressInfo] {
        return AddressInfoPersistence.getAll()
    }

    func delete(addressInfo: AddressInfo) {
        AddressInfoPersistence.delete(addrInfo: addressInfo)
    }

    func deleteAll() {
        AddressInfoPersistence.deleteAll()
    }
}
