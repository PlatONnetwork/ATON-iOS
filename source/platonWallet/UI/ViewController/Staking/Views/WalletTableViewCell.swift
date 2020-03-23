//
//  WalletTableViewCell.swift
//  platonWallet
//
//  Created by Admin on 29/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class WalletTableViewCell: UITableViewCell {

    public let walletAvatarIV = UIImageView()
    public let walletBackgroundView = UIImageView()
    public let walletNameLabel = UILabel()
    public let walletAddressLabel = UILabel()
    public let bottomlineV = UIView()
    public let rightImageView = UIImageView()
    public let containerView = UIButton()

    var cellDidHandle: ((_ cell: WalletTableViewCell) -> Void)?

    func setupCellData(for wallet: Wallet?, isWithdraw: Bool = false) {
        guard let wal = wallet else {
            walletNameLabel.text = "--"
            walletAvatarIV.image = nil
            walletAddressLabel.text = "--"
            return
        }

        walletNameLabel.text = wal.name
        walletAvatarIV.image = UIImage(named: wal.avatar)
        if isWithdraw {
            walletAddressLabel.text = Localized("withdraw_detail_balance") + wal.balanceDescription()
        } else {
            walletAddressLabel.text = wal.address.addressForDisplay()
        }
    }

    var isTopCell: Bool = false {
        didSet {
            containerView.snp.updateConstraints { make in
                make.height.equalTo(isTopCell ? 60 : 72)
                make.top.equalToSuperview().offset(isTopCell ? 16 : 0)
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = normal_background_color

        containerView.addTarget(self, action: #selector(containerTapAction), for: .touchUpInside)
        containerView.backgroundColor = .white
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(16)
            make.height.equalTo(60)
            make.bottom.equalToSuperview()
        }

        walletBackgroundView.layer.shadowColor = UIColor(rgb: 0x9ca7c2).cgColor
        walletBackgroundView.layer.shadowRadius = 2.0
        walletBackgroundView.layer.shadowOffset = CGSize(width: 1, height: 1)
        walletBackgroundView.layer.shadowOpacity = 0.2
        walletBackgroundView.image = UIImage(named: "bg_staking_wallet_img")?.resizableImage(withCapInsets: UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3), resizingMode: .stretch)
        containerView.addSubview(walletBackgroundView)
        walletBackgroundView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(60)
        }

        walletAvatarIV.addMaskView(corners: .allCorners, cornerRadiiV: 21)
        walletAvatarIV.image = UIImage(named: "walletAvatar_1")
        containerView.addSubview(walletAvatarIV)
        walletAvatarIV.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(5)
            make.width.height.equalTo(42)
        }

        walletNameLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)
        walletNameLabel.textColor = .black
        walletNameLabel.text = Localized("staking_main_wallet_name")
        containerView.addSubview(walletNameLabel)
        walletNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalTo(walletAvatarIV.snp.trailing).offset(5)
            make.height.equalTo(18)
            make.trailing.equalToSuperview().offset(-44)
        }

        walletAddressLabel.font = UIFont.systemFont(ofSize: 13)
        walletAddressLabel.textColor = common_darkGray_color
        walletAddressLabel.text = "--"
        containerView.addSubview(walletAddressLabel)
        walletAddressLabel.snp.makeConstraints { make in
            make.top.equalTo(walletNameLabel.snp.bottom).offset(3)
            make.leading.equalTo(walletNameLabel.snp.leading)
            make.trailing.equalTo(walletNameLabel.snp.trailing)
        }

        bottomlineV.backgroundColor = UIColor(rgb: 0xE4E7F3)
        containerView.addSubview(bottomlineV)
        bottomlineV.snp.makeConstraints { make in
            make.height.equalTo(1/UIScreen.main.scale)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview()
        }

        containerView.addSubview(rightImageView)
        rightImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func containerTapAction() {
        cellDidHandle?(self)
    }
}
