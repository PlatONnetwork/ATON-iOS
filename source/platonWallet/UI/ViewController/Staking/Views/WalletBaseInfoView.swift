//
//  WalletBaseInfoView.swift
//  platonWallet
//
//  Created by Admin on 12/8/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit

class WalletBaseInfoView: UIView {

    public let avatarIV = UIImageView()
    public let nameLabel = UILabel()
    public let addressLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white

        avatarIV.addMaskView(corners: .allCorners, cornerRadiiV: 21)
        avatarIV.image = UIImage(named: "walletAvatar_1")
        addSubview(avatarIV)
        avatarIV.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(13)
            make.width.height.equalTo(42)
        }

        nameLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)
        nameLabel.textColor = .black
        nameLabel.text = "--"
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarIV.snp.top)
            make.leading.equalTo(avatarIV.snp.trailing).offset(5)
            make.trailing.equalToSuperview().offset(-16)
        }

        addressLabel.font = UIFont.systemFont(ofSize: 13)
        addressLabel.textColor = common_darkGray_color
        addressLabel.text = "--"
        addSubview(addressLabel)
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.leading.equalTo(nameLabel.snp.leading)
            make.trailing.equalTo(nameLabel.snp.trailing)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
