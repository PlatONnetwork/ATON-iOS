//
//  NodeBaseInfoView.swift
//  platonWallet
//
//  Created by Admin on 29/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import Localize_Swift
import SnapKit

class NodeBaseInfoView: UIView {

    let nodeBackgroundView = UIImageView()
    public let nodeAvatarIV = UIImageView()
    public let nodeNameLabel = UILabel()
    public let nodeAddressLabel = UILabel()
    public let statusButton = UIButton()
    public let rateLabel = UILabel()
    public let nodeNameButton = UIButton()
    public let trendIV = UIImageView()

    public let rewardRatioLabel = UILabel()
    public let totalRewardLabel = UILabel()
    let rewardContentView = UIView()
    var bottomConstraint: Constraint?

    var nodeLinkHandler: (() -> Void)?
    var tipsShowHandler: (() -> Void)?
    var tipsShowYieldHandler: (() -> Void)?

    var isInitNode: Bool = false {
        didSet {
            if isInitNode {
                nodeBackgroundView.image = UIImage(named: "bj3")
                bottomConstraint?.update(priority: .required)
                rewardContentView.isHidden = true
            } else {
                nodeBackgroundView.image = UIImage(named: "bj2")
                bottomConstraint?.update(priority: .low)
                rewardContentView.isHidden = false
            }
        }
    }

    var ratePATrend: RateTrend? {
        didSet {
            switch ratePATrend! {
            case .none:
                trendIV.image = nil
            case .up:
                trendIV.image = UIImage(named: "3.icon_Rose")
            case .down:
                trendIV.image = UIImage(named: "3.icon_Fell")
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white

        nodeBackgroundView.isUserInteractionEnabled = true
        nodeBackgroundView.image = UIImage(named: "bj2")
//        nodeBackgroundView.contentMode =
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
            bottomConstraint = make.bottom.equalToSuperview().offset(-20).priorityLow().constraint
        }

        nodeNameLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)
        nodeNameLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        nodeNameLabel.textColor = .white
        nodeNameLabel.text = Localized("staking_main_wallet_name")
        nodeBackgroundView.addSubview(nodeNameLabel)
        nodeNameLabel.snp.makeConstraints { make in
            make.top.equalTo(nodeAvatarIV.snp.top)
            make.leading.equalTo(nodeAvatarIV.snp.trailing).offset(5)
        }

        nodeNameButton.addTarget(self, action: #selector(link), for: .touchUpInside)
        nodeNameButton.setImage(UIImage(named: "3.icon_link2"), for: .normal)
        nodeBackgroundView.addSubview(nodeNameButton)
        nodeNameButton.snp.makeConstraints { make in
            make.leading.equalTo(nodeNameLabel.snp.trailing).offset(4)
            make.centerY.equalTo(nodeNameLabel)
        }

        statusButton.setTitle("--", for: .normal)
        statusButton.setTitleColor(.white, for: .normal)
        statusButton.layer.cornerRadius = 3.0
        statusButton.layer.borderWidth = 1 / UIScreen.main.scale
        statusButton.titleLabel?.font = UIFont.systemFont(ofSize: 11)
        statusButton.layer.borderColor = UIColor.white.cgColor
        statusButton.contentEdgeInsets = UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)
        statusButton.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
        nodeBackgroundView.addSubview(statusButton)
        statusButton.snp.makeConstraints { make in
            make.leading.equalTo(nodeNameButton.snp.trailing).offset(6)
            make.height.equalTo(16)
            make.centerY.equalTo(nodeNameLabel)
        }

        nodeAddressLabel.font = UIFont.systemFont(ofSize: 13)
        nodeAddressLabel.textColor = .white
        nodeAddressLabel.text = "--"
        nodeBackgroundView.addSubview(nodeAddressLabel)
        nodeAddressLabel.snp.makeConstraints { make in
            make.top.equalTo(nodeNameLabel.snp.bottom).offset(6)
            make.leading.equalTo(nodeNameLabel.snp.leading)
        }

        rewardContentView.backgroundColor = .clear
        nodeBackgroundView.addSubview(rewardContentView)
        rewardContentView.snp.makeConstraints { make in
            make.top.equalTo(nodeAvatarIV.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().priorityMedium()
        }

        let rateContainer = UIButton()
        rateContainer.addTarget(self, action: #selector(tipsShowYield), for: .touchUpInside)
        rewardContentView.addSubview(rateContainer)
        rateContainer.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(14)
            make.trailing.lessThanOrEqualTo(rewardContentView.snp.centerX).offset(-5)
        }

        let rateTitleLabel = UILabel()
        rateTitleLabel.text = Localized("staking_validator_detail_delegate_rate_about")
        rateTitleLabel.textColor = .white
        rateTitleLabel.font = UIFont.systemFont(ofSize: 13)
        rateContainer.addSubview(rateTitleLabel)
        rateTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(14)
        }

        let rateTitleIV = UIImageView()
        rateTitleIV.image = UIImage(named: "3.icon_doubt2")
        rateContainer.addSubview(rateTitleIV)
        rateTitleIV.snp.makeConstraints { make in
            make.width.height.equalTo(12)
            make.centerY.equalTo(rateTitleLabel)
            make.leading.equalTo(rateTitleLabel.snp.trailing).offset(3)
        }

        rateLabel.adjustsFontSizeToFitWidth = true
        rateLabel.textColor = .white
        rateLabel.font = UIFont.systemFont(ofSize: 14)
        rateLabel.text = "0.00%"
        rateContainer.addSubview(rateLabel)
        rateLabel.snp.makeConstraints { make in
            make.leading.equalTo(rateTitleLabel)
            make.top.equalTo(rateTitleLabel.snp.bottom).offset(9)
            make.trailing.equalToSuperview()
            make.height.equalTo(14)
        }

        trendIV.image = nil
        rateContainer.addSubview(trendIV)
        trendIV.snp.makeConstraints { make in
            make.leading.equalTo(rateLabel.snp.trailing).offset(2)
            make.centerY.equalTo(rateLabel.snp.centerY)
            make.height.width.equalTo(13)
        }

        let rewardRatioContainer = UIButton()
        rewardRatioContainer.addTarget(self, action: #selector(tipsShow), for: .touchUpInside)
        rewardContentView.addSubview(rewardRatioContainer)
        rewardRatioContainer.snp.makeConstraints { make in
            make.leading.equalTo(rewardContentView.snp.centerX).offset(5)
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalTo(rateContainer.snp.top)
        }

        let rewardRatioTipLabel = UILabel()
        rewardRatioTipLabel.text = Localized("reward_ratio")
        rewardRatioTipLabel.textColor = .white
        rewardRatioTipLabel.font = UIFont.systemFont(ofSize: 13)
        rewardRatioContainer.addSubview(rewardRatioTipLabel)
        rewardRatioTipLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(14)
        }

        let rewardRatioIV = UIImageView()
        rewardRatioIV.image = UIImage(named: "3.icon_doubt2")
        rewardRatioContainer.addSubview(rewardRatioIV)
        rewardRatioIV.snp.makeConstraints { make in
            make.width.height.equalTo(12)
            make.centerY.equalTo(rewardRatioTipLabel)
            make.leading.equalTo(rewardRatioTipLabel.snp.trailing).offset(3)
        }

        rewardRatioLabel.adjustsFontSizeToFitWidth = true
        rewardRatioLabel.textColor = .white
        rewardRatioLabel.font = UIFont.systemFont(ofSize: 14)
        rewardRatioLabel.text = "0.00"
        rewardRatioContainer.addSubview(rewardRatioLabel)
        rewardRatioLabel.snp.makeConstraints { make in
            make.leading.equalTo(rewardRatioTipLabel)
            make.top.equalTo(rewardRatioTipLabel.snp.bottom).offset(9)
            make.trailing.equalToSuperview()
            make.height.equalTo(14)
        }

        let lineV = UIView()
        lineV.backgroundColor = .white
        nodeBackgroundView.addSubview(lineV)
        lineV.snp.makeConstraints { make in
            make.height.equalTo(1/UIScreen.main.scale)
            make.top.equalTo(rateContainer.snp.bottom).offset(20)
            make.leading.equalTo(rateContainer.snp.leading)
            make.trailing.equalTo(rewardRatioContainer.snp.trailing)
        }

        let totalRewardTipLabel = UILabel()
        totalRewardTipLabel.text = Localized("reward_total")
        totalRewardTipLabel.textColor = .white
        totalRewardTipLabel.font = UIFont.systemFont(ofSize: 13)
        totalRewardTipLabel.setContentHuggingPriority(.required, for: .horizontal)
        totalRewardTipLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        rewardContentView.addSubview(totalRewardTipLabel)
        totalRewardTipLabel.snp.makeConstraints { make in
            make.leading.equalTo(lineV.snp.leading)
            make.top.equalTo(lineV.snp.bottom).offset(14)
            make.bottom.equalToSuperview().offset(-14)
        }

        totalRewardLabel.adjustsFontSizeToFitWidth = true
        totalRewardLabel.textColor = .white
        totalRewardLabel.font = .systemFont(ofSize: 14, weight: .medium)
        totalRewardLabel.text = "0.00"
        rewardContentView.addSubview(totalRewardLabel)
        totalRewardLabel.snp.makeConstraints { make in
            make.leading.equalTo(totalRewardTipLabel.snp.trailing).offset(5)
            make.centerY.equalTo(totalRewardTipLabel.snp.centerY)
            make.trailing.equalTo(lineV.snp.trailing)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func link() {
        nodeLinkHandler?()
    }

    @objc func tipsShow() {
        tipsShowHandler?()
    }

    @objc func tipsShowYield() {
        tipsShowYieldHandler?()
    }
}
