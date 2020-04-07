//
//  AssetWalletsSectionController.swift
//  platonWallet
//
//  Created by Admin on 27/3/2020.
//  Copyright © 2020 ju. All rights reserved.
//

import Foundation
import BigInt

class AssetWalletsSectionController {
    let viewModel: AssetSectionViewModel

    var onSendPressed: (() -> Void)?
    var onReceivePressed: (() -> Void)?
    var onSignaturePressed: (() -> Void)?
    var onManagerPressed: (() -> Void)?

    init(viewModel: AssetSectionViewModel = AssetSectionViewModel()) {
        self.viewModel = viewModel

        initialViewModel()
    }

    func initialViewModel() {
        viewModel.wallet.value = (AssetVCSharedData.sharedData.selectedWallet as? Wallet)
        viewModel.assetIsHide.value = AssetCoreService.shared.assetVisible

        viewModel.onReceivePressed = { [weak self] in
            self?.onReceivePressed?()
        }

        viewModel.onSendPressed = { [weak self] in
            self?.onSendPressed?()
        }

        viewModel.onSignaturePressed = { [weak self] in
            self?.onSignaturePressed?()
        }

        viewModel.onManagerPressed = { [weak self] in
            self?.onManagerPressed?()
        }
    }
}
