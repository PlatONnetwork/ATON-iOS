//
//  AssetHeaderViewModel.swift
//  platonWallet
//
//  Created by Admin on 26/3/2020.
//  Copyright © 2020 ju. All rights reserved.
//

import Foundation
import BigInt

class AssetHeaderViewModel {
    let walletViewModels = Observable<[RowViewModel]>(value: [])
    let totalBalance = Observable<BigUInt>(value: BigUInt.zero)
    let assetIsHide = Observable<Bool>(value: false)

    var scanBtnPressed: (() -> Void)?
    var menuBtnPressed: (() -> Void)?
    var visibleBtnPressed: (() -> Void)?
}
