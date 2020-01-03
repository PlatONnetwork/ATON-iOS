//
//  MyDelegateViewCell.swift
//  platonWallet
//
//  Created by Admin on 24/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class MyDelegateViewCell: UITableViewCell {

    let walletAvatarIV = UIImageView()
    let walletNameLabel = UILabel()
    let walletAddressLabel = UILabel()

    let delegatedLabel = UILabel()
    let totalRewardLabel = UILabel()
    let unclaimedRewardLabel = UILabel()
    let claimButton = UIButton()

    var cellDidHandle: ((_ cell: MyDelegateViewCell) -> Void)?

    var delegate: Delegate? {
        didSet {
            walletAvatarIV.image = delegate?.walletAvatar ?? UIImage(named: "walletAvatar_1")
            walletNameLabel.text = delegate?.walletName
            walletAddressLabel.text = delegate?.walletAddress.addressForDisplay()

            delegatedLabel.text = delegate?.delegateValue
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = normal_background_color

        let shadowView = UIView()
        shadowView.backgroundColor = .white
        contentView.addSubview(shadowView)

        let containerView = UIButton()
        containerView.addTarget(self, action: #selector(containerTapAction), for: .touchUpInside)
        containerView.backgroundColor = .white
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(16)
            make.height.equalTo(184)
            make.bottom.equalToSuperview()
        }

        shadowView.snp.makeConstraints { make in
            make.edges.equalTo(containerView)
        }
        shadowView.layer.shadowColor = UIColor(rgb: 0x9ca7c2).cgColor
        shadowView.layer.shadowRadius = 4.0
        shadowView.layer.shadowOffset = CGSize(width: 2, height: 2)
        shadowView.layer.shadowOpacity = 0.2

        let walletBackgroundView = UIImageView()
        walletBackgroundView.image = UIImage(named: "bg_staking_wallet_img")?.resizableImage(withCapInsets: UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3), resizingMode: .stretch)
        containerView.addSubview(walletBackgroundView)
        walletBackgroundView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(60)
        }

        walletAvatarIV.addMaskView(corners: .allCorners, cornerRadiiV: 21)
        walletAvatarIV.image = UIImage(named: "walletAvatar_1")
        walletBackgroundView.addSubview(walletAvatarIV)
        walletAvatarIV.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(5)
            make.width.height.equalTo(42)
        }

        walletNameLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)
        walletNameLabel.textColor = .black
        walletNameLabel.localizedText = "staking_main_wallet_name"
        walletBackgroundView.addSubview(walletNameLabel)
        walletNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalTo(walletAvatarIV.snp.trailing).offset(5)
            make.height.equalTo(18)
        }

        walletAddressLabel.font = UIFont.systemFont(ofSize: 13)
        walletAddressLabel.textColor = common_darkGray_color
        walletAddressLabel.text = "--"
        walletBackgroundView.addSubview(walletAddressLabel)
        walletAddressLabel.snp.makeConstraints { make in
            make.top.equalTo(walletNameLabel.snp.bottom).offset(3)
            make.leading.equalTo(walletNameLabel.snp.leading)
        }

        let detailButton = UIButton()
        detailButton.localizedNormalTitle = "staking_main_delegate_detail"
        detailButton.setTitleColor(common_blue_color, for: .normal)
        detailButton.setImage(UIImage(named: "3.icon_right"), for: .normal)
        detailButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        detailButton.semanticContentAttribute = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
        walletBackgroundView.addSubview(detailButton)
        detailButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-10)
        }

        let delegateBackgroundView = UIView()
        delegateBackgroundView.isUserInteractionEnabled = false
        delegateBackgroundView.backgroundColor = .white
        containerView.addSubview(delegateBackgroundView)
        delegateBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(walletBackgroundView.snp.bottom)
            make.leading.trailing.equalTo(walletBackgroundView)
            make.bottom.equalToSuperview()
        }

        let delegateTipLabel = UILabel()
        delegateTipLabel.localizedText = "staking_main_undelegating_text"
        delegateTipLabel.textColor = common_lightLightGray_color
        delegateTipLabel.font = UIFont.systemFont(ofSize: 12)
        delegateBackgroundView.addSubview(delegateTipLabel)
        delegateTipLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(14)
            make.height.equalTo(14)
            make.width.equalToSuperview().offset(-34).dividedBy(2)
        }

        delegatedLabel.textColor = .black
        delegatedLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        delegatedLabel.text = "--"
        delegatedLabel.adjustsFontSizeToFitWidth = true
        delegateBackgroundView.addSubview(delegatedLabel)
        delegatedLabel.snp.makeConstraints { make in
            make.leading.equalTo(delegateTipLabel)
            make.top.equalTo(delegateTipLabel.snp.bottom).offset(9)
            make.height.equalTo(14)
            make.width.equalTo(delegateTipLabel)
        }

        let totalRewardTipLabel = UILabel()
        totalRewardTipLabel.localizedText = "mydelegates_total_reward"
        totalRewardTipLabel.textColor = common_lightLightGray_color
        totalRewardTipLabel.font = UIFont.systemFont(ofSize: 12)
        delegateBackgroundView.addSubview(totalRewardTipLabel)
        totalRewardTipLabel.snp.makeConstraints { make in
            make.leading.equalTo(delegateTipLabel.snp.trailing).offset(5)
            make.top.equalTo(delegateTipLabel.snp.top)
            make.width.equalTo(delegateTipLabel)
        }

        totalRewardLabel.textColor = .black
        totalRewardLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        totalRewardLabel.text = "--"
        totalRewardLabel.adjustsFontSizeToFitWidth = true
        delegateBackgroundView.addSubview(totalRewardLabel)
        totalRewardLabel.snp.makeConstraints { make in
            make.leading.equalTo(totalRewardTipLabel)
            make.top.equalTo(totalRewardTipLabel.snp.bottom).offset(9)
            make.height.equalTo(14)
        }

        let unclaimedRewardTipLabel = UILabel()
        unclaimedRewardTipLabel.localizedText = "mydelegates_unclaimed_reward"
        unclaimedRewardTipLabel.textColor = common_lightLightGray_color
        unclaimedRewardTipLabel.font = UIFont.systemFont(ofSize: 12)
        delegateBackgroundView.addSubview(unclaimedRewardTipLabel)
        unclaimedRewardTipLabel.snp.makeConstraints { make in
            make.leading.equalTo(delegateTipLabel.snp.leading)
            make.trailing.equalTo(delegateTipLabel.snp.trailing)
            make.top.equalTo(delegatedLabel.snp.bottom).offset(12)
        }

        unclaimedRewardLabel.textColor = .black
        unclaimedRewardLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        unclaimedRewardLabel.text = "--"
        unclaimedRewardLabel.adjustsFontSizeToFitWidth = true
        delegateBackgroundView.addSubview(unclaimedRewardLabel)
        unclaimedRewardLabel.snp.makeConstraints { make in
            make.leading.equalTo(unclaimedRewardTipLabel)
            make.trailing.equalToSuperview().offset(-120)
            make.top.equalTo(unclaimedRewardTipLabel.snp.bottom).offset(7)
            make.width.equalTo(unclaimedRewardTipLabel)
        }

        claimButton.localizedNormalTitle = "mydelegates_claim"
        claimButton.titleLabel?.font = .systemFont(ofSize: 13)
        claimButton.layer.cornerRadius = 14.0
        claimButton.layer.borderColor = common_blue_color.cgColor
        claimButton.layer.borderWidth = 1
        claimButton.setTitleColor(common_blue_color, for: .normal)
        delegateBackgroundView.addSubview(claimButton)
        claimButton.snp.makeConstraints { make in
            make.height.equalTo(28)
            make.width.equalTo(67)
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalTo(unclaimedRewardLabel.snp.centerY)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func containerTapAction() {
        cellDidHandle?(self)
    }
}
