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
    let exchangeButton = UIButton()

    func setup(viewModel: RowViewModel) {
        guard let viewModel = viewModel as? AssetWalletViewModel else { return }
        self.viewModel = viewModel
        if viewModel.wallet.subWallets.count > 0 {
            let selectedWallet = WalletHelper.fetchFinalSelectedWallet(from: viewModel.wallet)
            walletNameLabel.text = selectedWallet.name
            exchangeButton.isHidden = false
        } else {
            walletNameLabel.text = viewModel.wallet.name
            exchangeButton.isHidden = true
        }
        if viewModel.isWalletSelected {
            contentView.backgroundColor = viewModel.wallet.selectedBackgroundColor
            iconImgV.image = viewModel.wallet.selectedIcon
            walletNameLabel.textColor = .white
            exchangeButton.isEnabled = true
        } else {
            contentView.backgroundColor = viewModel.wallet.normalBackgroundColor
            iconImgV.image = viewModel.wallet.normalIcon
            walletNameLabel.textColor = viewModel.wallet.normalNameTextColor
            exchangeButton.isEnabled = false
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
        
        contentView.addSubview(exchangeButton)
        exchangeButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.centerY.equalTo(iconImgV)
            make.trailing.equalTo(-8)
        }
        exchangeButton.setImage(UIImage(named: "homepage_wallet_change_w"), for: .normal)
        exchangeButton.setImage(UIImage(named: "homepage_wallet_change_b"), for: .disabled)
        
        exchangeButton.addTarget(self, action: #selector(exchangeButtonClick(sender:)), for: .touchUpInside)
    }
    
    @objc func exchangeButtonClick(sender: UIButton) {
        print("exchangeButtonClick")
        self.viewModel?.onExchangeWalletToDisplay?()
    }

}
