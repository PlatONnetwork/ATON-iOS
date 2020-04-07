//
//  AssetViewModel.swift
//  platonWallet
//
//  Created by Admin on 24/3/2020.
//  Copyright © 2020 ju. All rights reserved.
//

import Foundation
import BigInt

class AssetViewModel {
    let headerViewModel = Observable<AssetHeaderViewModel>(value: AssetHeaderViewModel())
    let transactionsData = Observable<[String: [Transaction]]>(value: [:])
    let isShowFooterMore = Observable<Bool>(value: false)
    let isFetching = Observable<Bool>(value: false)

}
