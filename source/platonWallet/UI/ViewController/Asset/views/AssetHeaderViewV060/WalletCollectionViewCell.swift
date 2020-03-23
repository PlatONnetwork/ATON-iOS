//
//  WalletCollectionViewCell.swift
//  platonWallet
//
//  Created by Admin on 23/9/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit

class WalletCollectionViewCell: UICollectionViewCell {

    let bgImgV = UIImageView()
    let iconImgV = UIImageView()
    let walletNameLabel = UILabel()

    var wallet: Wallet? {
        didSet {
            walletNameLabel.text = wallet?.name
            guard
                let selectedWallet = AssetVCSharedData.sharedData.selectedWallet as? Wallet,
                selectedWallet.address.lowercased() == wallet?.address.lowercased() else {
                    iconImgV.image = wallet?.normalIcon
                    bgImgV.image = wallet?.normalImg
                    walletNameLabel.textColor = wallet?.walletNameTextColor
                    layer.shadowOpacity = 0
                    return
            }
            iconImgV.image = wallet?.selectedIcon
            bgImgV.image = wallet?.selectedImg
            walletNameLabel.textColor = .white

            layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 4).cgPath
            layer.shadowOpacity = 0.8
            layer.shadowOffset = CGSize(width: 0, height: 2)
            layer.shadowRadius = 3
            layer.shadowColor = wallet?.walletNameTextColor.cgColor
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        contentView.addSubview(bgImgV)
        bgImgV.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.addSubview(iconImgV)
        iconImgV.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(9)
            make.top.equalToSuperview().offset(19)
            make.width.height.equalTo(24)
        }
        
        walletNameLabel.font = UIFont.systemFont(ofSize: 12)
        contentView.addSubview(walletNameLabel)
        walletNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImgV.snp.trailing).offset(6)
            make.centerY.equalTo(iconImgV.snp.centerY)
            make.trailing.equalToSuperview()
        }
    }

}
