//
//  NodeAboutDelegateTableViewCell.swift
//  platonWallet
//
//  Created by Admin on 24/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import Localize_Swift
import SnapKit

class NodeAboutDelegateTableViewCell: UITableViewCell {

    public let nodeAvatarIV = UIImageView()
    public let nodeNameLabel = UILabel()
    public let nodeAddressLabel = UILabel()
    public let nodeStatusLabel = UILabel()
    public let nodeNameButton = UIButton()

    public let lockedDelegateLabel = UILabel()
    public let unlockedDelegateLabel = UILabel()
    let unclaimedLabel = UILabel()

    public let delegateButton = UIButton()
    public let withDrawButton = UIButton()

    var topConstraint: Constraint?

    var didLinkHanlder: ((NodeAboutDelegateTableViewCell) -> Void)?
    var didDelegateHandler: ((NodeAboutDelegateTableViewCell) -> Void)?
    var didWithdrawHandler: ((NodeAboutDelegateTableViewCell) -> Void)?

    var delegateDetail: DelegateDetail? {
        didSet {
            nodeAvatarIV.kf.setImage(with: URL(string: delegateDetail?.url ?? ""), placeholder: UIImage(named: "3.icon_default"))
            nodeNameLabel.text = delegateDetail?.nodeName ?? "--"
            nodeAddressLabel.text = delegateDetail?.nodeId.nodeIdForDisplay() ?? "--"
            nodeStatusLabel.text = delegateDetail?.status.0
            nodeStatusLabel.textColor = delegateDetail?.status.1
            lockedDelegateLabel.text = delegateDetail?.delegatedString ?? "--"
            unlockedDelegateLabel.text = delegateDetail?.releasedString ?? "--"
            nodeNameButton.isHidden = delegateDetail?.website?.count == 0
            unclaimedLabel.text = delegateDetail?.withdrawRewardValue

            if delegateDetail?.isConsensus == false {
                topConstraint?.update(priority: .high)
            } else {
                topConstraint?.update(priority: .low)
            }
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
        containerView.backgroundColor = .white
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(16)
//            make.height.equalTo(172)
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
        walletBackgroundView.isUserInteractionEnabled = true
        walletBackgroundView.image = UIImage(named: "bg_staking_wallet_img")?.resizableImage(withCapInsets: UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3), resizingMode: .stretch)
        containerView.addSubview(walletBackgroundView)
        walletBackgroundView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(60)
        }

        nodeAvatarIV.addMaskView(corners: .allCorners, cornerRadiiV: 21)
        nodeAvatarIV.image = UIImage(named: "3.icon_default")
        walletBackgroundView.addSubview(nodeAvatarIV)
        nodeAvatarIV.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(5)
            make.width.height.equalTo(42)
        }

        nodeNameLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)
        nodeNameLabel.textColor = .black
        nodeNameLabel.text = Localized("staking_main_wallet_name")
        nodeNameLabel.setContentHuggingPriority(.required, for: .horizontal)
        walletBackgroundView.addSubview(nodeNameLabel)
        nodeNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalTo(nodeAvatarIV.snp.trailing).offset(5)
            make.height.equalTo(18)
        }

        nodeNameButton.addTarget(self, action: #selector(linkTapAction), for: .touchUpInside)
        nodeNameButton.setImage(UIImage(named: "3.icon_link"), for: .normal)
        walletBackgroundView.addSubview(nodeNameButton)
        nodeNameButton.snp.makeConstraints { make in
            make.leading.equalTo(nodeNameLabel.snp.trailing).offset(4)
            make.centerY.equalTo(nodeNameLabel)
            make.width.height.equalTo(13)
        }

        nodeAddressLabel.font = UIFont.systemFont(ofSize: 13)
        nodeAddressLabel.textColor = common_darkGray_color
        nodeAddressLabel.text = "--"
        walletBackgroundView.addSubview(nodeAddressLabel)
        nodeAddressLabel.snp.makeConstraints { make in
            make.top.equalTo(nodeNameLabel.snp.bottom).offset(3)
            make.leading.equalTo(nodeNameLabel.snp.leading)
            make.trailing.equalToSuperview().offset(-16)
        }

        nodeStatusLabel.font = UIFont.systemFont(ofSize: 13)
        nodeStatusLabel.textColor = .black
        nodeStatusLabel.text = "--"
        nodeStatusLabel.textAlignment = .right
        walletBackgroundView.addSubview(nodeStatusLabel)
        nodeStatusLabel.snp.makeConstraints { make in
            make.top.equalTo(nodeNameLabel)
            make.trailing.equalToSuperview().offset(-10)
            make.leading.equalTo(nodeNameButton.snp.trailing).offset(5).priorityHigh()
        }

        let delegateBackgroundView = UIView()
        delegateBackgroundView.backgroundColor = .white
        containerView.addSubview(delegateBackgroundView)
        delegateBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(walletBackgroundView.snp.bottom)
            make.leading.trailing.equalTo(walletBackgroundView)
            make.bottom.equalToSuperview()
        }

        let lockDelegateTipLabel = UILabel()
        lockDelegateTipLabel.text = Localized("staking_delegate_locked")
        lockDelegateTipLabel.textColor = common_lightLightGray_color
        lockDelegateTipLabel.font = UIFont.systemFont(ofSize: 12)
        delegateBackgroundView.addSubview(lockDelegateTipLabel)
        lockDelegateTipLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(14)
            make.height.equalTo(14)
            make.width.equalToSuperview().offset(-10).dividedBy(2)
        }

        lockedDelegateLabel.textColor = .black
        lockedDelegateLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        lockedDelegateLabel.text = "--"
        delegateBackgroundView.addSubview(lockedDelegateLabel)
        lockedDelegateLabel.snp.makeConstraints { make in
            make.leading.equalTo(lockDelegateTipLabel)
            make.top.equalTo(lockDelegateTipLabel.snp.bottom).offset(9)
            make.height.equalTo(14)
        }

        let unlockedDelegatingTipLabel = UILabel()
        unlockedDelegatingTipLabel.text = Localized("staking_delegate_release")
        unlockedDelegatingTipLabel.textColor = common_lightLightGray_color
        unlockedDelegatingTipLabel.font = UIFont.systemFont(ofSize: 12)
        delegateBackgroundView.addSubview(unlockedDelegatingTipLabel)
        unlockedDelegatingTipLabel.snp.makeConstraints { make in
            make.leading.equalTo(lockDelegateTipLabel.snp.trailing)
            make.top.equalTo(lockDelegateTipLabel.snp.top)
            make.width.equalTo(lockDelegateTipLabel)
        }

        unlockedDelegateLabel.textColor = .black
        unlockedDelegateLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        unlockedDelegateLabel.text = "--"
        delegateBackgroundView.addSubview(unlockedDelegateLabel)
        unlockedDelegateLabel.snp.makeConstraints { make in
            make.leading.equalTo(unlockedDelegatingTipLabel)
            make.top.equalTo(unlockedDelegatingTipLabel.snp.bottom).offset(9)
            make.height.equalTo(14)
        }

        let rewardContentView = UIView()
        rewardContentView.backgroundColor = UIColor(rgb: 0xECF2FF)
        delegateBackgroundView.addSubview(rewardContentView)
        rewardContentView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.top.equalTo(lockedDelegateLabel.snp.bottom).offset(15)
            make.height.equalTo(40)
        }

        let rewardIV = UIImageView()
        rewardIV.image = UIImage(named: "3.icon_Claim Rec")
        rewardContentView.addSubview(rewardIV)
        rewardIV.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
        }

        let unclaimedTipLabel = UILabel()
        unclaimedTipLabel.textColor = common_lightLightGray_color
        unclaimedTipLabel.font = .systemFont(ofSize: 12)
        unclaimedTipLabel.text = Localized("delegate_detail_unclaimed_reward")
        rewardContentView.addSubview(unclaimedTipLabel)
        unclaimedTipLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(rewardIV.snp.trailing).offset(6)
        }

        unclaimedLabel.textColor = .black
        unclaimedLabel.font = .systemFont(ofSize: 14)
        rewardContentView.addSubview(unclaimedLabel)
        unclaimedLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(unclaimedTipLabel.snp.trailing).offset(2)
        }

        delegateButton.addTarget(self, action: #selector(delegateTapAction), for: .touchUpInside)
        delegateButton.setCellBottomStyle(UIImage(named: "3.icon_Delegate3"), UIImage(named: "3.icon_Delegate4"), "staking_delegate")
        delegateBackgroundView.addSubview(delegateButton)
        delegateButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2)
            make.leading.equalToSuperview()
            make.height.equalTo(40)
            topConstraint = make.top.equalTo(lockedDelegateLabel.snp.bottom).offset(15).priorityHigh().constraint
            make.top.equalTo(rewardContentView.snp.bottom).offset(15).priorityMedium()
        }

        withDrawButton.addTarget(self, action: #selector(withdrawTapAction), for: .touchUpInside)
        withDrawButton.setCellBottomStyle(UIImage(named: "3.icon_Undelegate 3"), UIImage(named: "3.icon_Undelegate4"), "staking_withdraw")
        delegateBackgroundView.addSubview(withDrawButton)
        withDrawButton.snp.makeConstraints { make in
            make.top.equalTo(delegateButton.snp.top)
            make.width.equalToSuperview().dividedBy(2)
            make.trailing.equalToSuperview()
            make.height.equalTo(40)
        }

        let horizontalLineView = UIView()
        horizontalLineView.backgroundColor = common_line_color
        delegateBackgroundView.addSubview(horizontalLineView)
        horizontalLineView.snp.makeConstraints { make in
            make.height.equalTo(1/UIScreen.main.scale)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-40)
        }

        let verticalLineView = UIView()
        verticalLineView.backgroundColor = common_line_color
        delegateBackgroundView.addSubview(verticalLineView)
        verticalLineView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(1/UIScreen.main.scale)
            make.height.equalTo(12)
            make.bottom.equalToSuperview().offset(-14)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func linkTapAction() {
        didLinkHanlder?(self)
    }

    @objc private func delegateTapAction() {
        didDelegateHandler?(self)
    }

    @objc private func withdrawTapAction() {
        didWithdrawHandler?(self)
    }

}
