//
//  AssetController.swift
//  platonWallet
//
//  Created by Admin on 26/3/2020.
//  Copyright © 2020 ju. All rights reserved.
//

import Foundation

class AssetController {
    let viewModel: AssetViewModel

    let headerController: AssetWalletsHeaderController
    let sectionController: AssetWalletsSectionController

    init(viewModel: AssetViewModel = AssetViewModel()) {
        self.viewModel = viewModel

        let headerViewModel = AssetHeaderViewModel()
        self.headerController = AssetWalletsHeaderController(viewModel: headerViewModel)
        self.sectionController = AssetWalletsSectionController(viewModel: AssetSectionViewModel(), headerViewModel: headerViewModel)

        initialViewModel()
//        initialObserver()
    }

    func initialViewModel() {

    }
}
