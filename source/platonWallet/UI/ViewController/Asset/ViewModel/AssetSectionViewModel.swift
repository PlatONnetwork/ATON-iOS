//
//  AssetSectionViewModel.swift
//  platonWallet
//
//  Created by Admin on 27/3/2020.
//  Copyright © 2020 ju. All rights reserved.
//

import Foundation
import BigInt

class AssetSectionViewModel {
    let wallet = Observable<Wallet?>(value: nil)
    let assetIsHide = Observable<Bool>(value: false)
    let freeBalance = Observable<BigUInt>(value: BigUInt.zero)
    let lockBalance = Observable<BigUInt>(value: BigUInt.zero)

    var onSendPressed: (() -> Void)?
    var onReceivePressed: (() -> Void)?
    var onSignaturePressed: (() -> Void)?
    var onManagerPressed: (() -> Void)?
}
