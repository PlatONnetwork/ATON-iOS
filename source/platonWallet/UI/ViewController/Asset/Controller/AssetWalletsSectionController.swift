//
//  AssetWalletsSectionController.swift
//  platonWallet
//
//  Created by Admin on 27/3/2020.
//  Copyright © 2020 ju. All rights reserved.
//

import Foundation

class AssetWalletsSectionController {
    let viewModel: AssetSectionViewModel
    weak var headerViewModel: AssetHeaderViewModel?

    init(viewModel: AssetSectionViewModel = AssetSectionViewModel(), headerViewModel: AssetHeaderViewModel) {
        self.viewModel = viewModel
        self.headerViewModel = headerViewModel

        initialViewModel()
    }

    func initialViewModel() {
        viewModel.wallet.value = (AssetVCSharedData.sharedData.selectedWallet as? Wallet)
        headerViewModel?.assetIsHide.addObserver({ [weak self] isHide in
            
        })
    }
}
