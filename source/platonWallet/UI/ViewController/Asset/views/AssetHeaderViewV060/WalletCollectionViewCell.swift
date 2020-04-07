//
//  WalletCollectionViewCell.swift
//  platonWallet
//
//  Created by Admin on 23/9/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit

class WalletCollectionViewCell: UICollectionViewCell, CellConfigurable {

    let iconImgV = UIImageView()
    let walletNameLabel = UILabel()
    var viewModel: AssetWalletViewModel?

    func setup(viewModel: RowViewModel) {
        guard let viewModel = viewModel as? AssetWalletViewModel else { return }
        self.viewModel = viewModel

        walletNameLabel.text = viewModel.wallet.name
        if viewModel.isWalletSelected {
            contentView.backgroundColor = viewModel.wallet.selectedBackgroundColor
            iconImgV.image = viewModel.wallet.selectedIcon
            walletNameLabel.textColor = .white
        } else {
            contentView.backgroundColor = viewModel.wallet.normalBackgroundColor
            iconImgV.image = viewModel.wallet.normalIcon
            walletNameLabel.textColor = viewModel.wallet.normalNameTextColor
        }

        contentView.layer.cornerRadius = 4.0
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        contentView.addSubview(iconImgV)
        iconImgV.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }

        walletNameLabel.font = UIFont.systemFont(ofSize: 12)
        contentView.addSubview(walletNameLabel)
        walletNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImgV.snp.trailing).offset(8)
            make.centerY.equalTo(iconImgV.snp.centerY)
            make.trailing.lessThanOrEqualToSuperview().offset(-5)
        }
    }

}
