//
//  WalletBaseInfoView.swift
//  platonWallet
//
//  Created by Admin on 12/8/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class WalletBaseInfoView: UIView {

    public let nodeAvatarIV = UIImageView()
    public let nodeNameLabel = UILabel()
    public let nodeAddressLabel = UILabel()

    public let rewardRatioLabel = UILabel()
    public let totalRewardLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        let nodeBackgroundView = UIImageView()
        nodeBackgroundView.image = UIImage(named: "bj2")
        addSubview(nodeBackgroundView)
        nodeBackgroundView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-16)
        }

        nodeAvatarIV.addMaskView(corners: .allCorners, cornerRadiiV: 21)
        nodeAvatarIV.image = UIImage(named: "walletAvatar_1")
        nodeBackgroundView.addSubview(nodeAvatarIV)
        nodeAvatarIV.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(10)
            make.width.height.equalTo(42)
        }

        nodeNameLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)
        nodeNameLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        nodeNameLabel.textColor = .white
        nodeBackgroundView.addSubview(nodeNameLabel)
        nodeNameLabel.snp.makeConstraints { make in
            make.top.equalTo(nodeAvatarIV.snp.top)
            make.leading.equalTo(nodeAvatarIV.snp.trailing).offset(5)
        }

        nodeAddressLabel.font = UIFont.systemFont(ofSize: 13)
        nodeAddressLabel.textColor = .white
        nodeAddressLabel.text = "--"
        nodeBackgroundView.addSubview(nodeAddressLabel)
        nodeAddressLabel.snp.makeConstraints { make in
            make.top.equalTo(nodeNameLabel.snp.bottom).offset(6)
            make.leading.equalTo(nodeNameLabel.snp.leading)
        }

        let delegateContentView = UIView()
        delegateContentView.backgroundColor = .clear
        nodeBackgroundView.addSubview(delegateContentView)
        delegateContentView.snp.makeConstraints { make in
            make.top.equalTo(nodeAvatarIV.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().priorityMedium()
        }

        let rewardRatioTipLabel = UILabel()
        rewardRatioTipLabel.text = Localized("delegate_detail_balance")
        rewardRatioTipLabel.textColor = .white
        rewardRatioTipLabel.font = UIFont.systemFont(ofSize: 13)
        delegateContentView.addSubview(rewardRatioTipLabel)
        rewardRatioTipLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(14)
            make.height.equalTo(14)
            make.trailing.equalTo(delegateContentView.snp.centerX).offset(-5)
        }

        rewardRatioLabel.adjustsFontSizeToFitWidth = true
        rewardRatioLabel.textColor = .white
        rewardRatioLabel.font = UIFont.systemFont(ofSize: 14)
        rewardRatioLabel.text = "--"
        delegateContentView.addSubview(rewardRatioLabel)
        rewardRatioLabel.snp.makeConstraints { make in
            make.leading.equalTo(rewardRatioTipLabel)
            make.top.equalTo(rewardRatioTipLabel.snp.bottom).offset(9)
            make.width.equalTo(rewardRatioTipLabel.snp.width)
            make.height.equalTo(14)
        }

        let totalRewardTipLabel = UILabel()
        totalRewardTipLabel.text = Localized("delegate_detail_delegated")
        totalRewardTipLabel.textColor = .white
        totalRewardTipLabel.font = UIFont.systemFont(ofSize: 13)
        delegateContentView.addSubview(totalRewardTipLabel)
        totalRewardTipLabel.snp.makeConstraints { make in
            make.leading.equalTo(delegateContentView.snp.centerX).offset(5)
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalTo(rewardRatioTipLabel.snp.top)
        }

        totalRewardLabel.adjustsFontSizeToFitWidth = true
        totalRewardLabel.textColor = .white
        totalRewardLabel.font = UIFont.systemFont(ofSize: 14)
        totalRewardLabel.text = "--"
        delegateContentView.addSubview(totalRewardLabel)
        totalRewardLabel.snp.makeConstraints { make in
            make.leading.equalTo(totalRewardTipLabel)
            make.top.equalTo(totalRewardTipLabel.snp.bottom).offset(9)
            make.width.equalTo(totalRewardTipLabel.snp.width)
            make.height.equalTo(14)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
