//
//  MyDelegateHeaderView.swift
//  platonWallet
//
//  Created by Admin on 24/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class MyDelegateHeaderView: UIView {

    var delegateRecordHandler: (() -> Void)?
    var rewardRecordHandler: (() -> Void)?

    let totalDelegateLabel = UILabel()
    let unclaimedRewardLabel = UILabel()
    let totalRewardLabel = UILabel()
    let delegateButton = UIButton()
    let rewardButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white

        let bgIV = UIImageView()
        bgIV.isUserInteractionEnabled = true
        bgIV.contentMode = .scaleAspectFill
        bgIV.image = UIImage(named: "bj1")
        addSubview(bgIV)
        bgIV.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-15)
            make.top.equalToSuperview().offset(10)
        }

        let totalDelegateTipLabel = UILabel()
        totalDelegateTipLabel.font = UIFont.systemFont(ofSize: 13)
        totalDelegateTipLabel.textColor = .white
        totalDelegateTipLabel.localizedText = "staking_main_delegate_total"
        bgIV.addSubview(totalDelegateTipLabel)
        totalDelegateTipLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
        }

        totalDelegateLabel.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        totalDelegateLabel.textColor = .white
        totalDelegateLabel.text = "--"
        bgIV.addSubview(totalDelegateLabel)
        totalDelegateLabel.snp.makeConstraints { make in
            make.top.equalTo(totalDelegateTipLabel.snp.bottom).offset(6)
            make.leading.equalTo(totalDelegateTipLabel.snp.leading)
            make.trailing.equalToSuperview().offset(-20)
        }

        let unclaimedRewardTipLabel = UILabel()
        unclaimedRewardTipLabel.localizedText = "mydelegates_unclaimed_reward"
        unclaimedRewardTipLabel.font = .systemFont(ofSize: 13)
        unclaimedRewardTipLabel.textColor = .white
        bgIV.addSubview(unclaimedRewardTipLabel)
        unclaimedRewardTipLabel.snp.makeConstraints { make in
            make.leading.equalTo(totalDelegateTipLabel.snp.leading)
            make.trailing.equalTo(bgIV.snp.centerX).offset(-5)
            make.top.equalTo(totalDelegateLabel.snp.bottom).offset(20)
        }

        unclaimedRewardLabel.font = .systemFont(ofSize: 14)
        unclaimedRewardLabel.textColor = .white
        unclaimedRewardLabel.text = "--"
        bgIV.addSubview(unclaimedRewardLabel)
        unclaimedRewardLabel.snp.makeConstraints { make in
            make.leading.equalTo(unclaimedRewardTipLabel.snp.leading)
            make.trailing.equalTo(unclaimedRewardTipLabel.snp.trailing)
            make.top.equalTo(unclaimedRewardTipLabel.snp.bottom).offset(5)
        }

        let totalRewardTipLabel = UILabel()
        totalRewardTipLabel.font = .systemFont(ofSize: 13)
        totalRewardTipLabel.textColor = .white
        totalRewardTipLabel.localizedText = "mydelegates_total_reward"
        bgIV.addSubview(totalRewardTipLabel)
        totalRewardTipLabel.snp.makeConstraints { make in
            make.leading.equalTo(bgIV.snp.centerX).offset(5)
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalTo(unclaimedRewardTipLabel.snp.top)
        }

        totalRewardLabel.font = .systemFont(ofSize: 14)
        totalRewardLabel.textColor = .white
        totalRewardLabel.text = "--"
        bgIV.addSubview(totalRewardLabel)
        totalRewardLabel.snp.makeConstraints { make in
            make.leading.equalTo(totalRewardTipLabel.snp.leading)
            make.trailing.equalTo(totalRewardTipLabel.snp.trailing)
            make.top.equalTo(totalRewardTipLabel.snp.bottom).offset(5)
        }

        let lineHIV = UIImageView()
        lineHIV.backgroundColor = line_white_color
        bgIV.addSubview(lineHIV)
        lineHIV.snp.makeConstraints { make in
            make.height.equalTo(1/UIScreen.main.scale)
            make.leading.equalToSuperview().offset(6)
            make.trailing.equalToSuperview().offset(-6)
            make.top.equalTo(unclaimedRewardLabel.snp.bottom).offset(20)
        }

        delegateButton.localizedNormalTitle = "mydelegates_delegate_record"
        delegateButton.titleLabel?.font = .systemFont(ofSize: 13)
        delegateButton.setTitleColor(.white, for: .normal)
        delegateButton.setImage(UIImage(named: "3.icon_Delegate3-w"), for: .normal)
        delegateButton.addTarget(self, action: #selector(delegateRecordTapAction), for: .touchUpInside)
        bgIV.addSubview(delegateButton)
        delegateButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalTo(bgIV.snp.centerX)
            make.top.equalTo(lineHIV.snp.bottom)
            make.bottom.equalToSuperview()
            make.height.equalTo(45)
        }

        rewardButton.localizedNormalTitle = "mydelegates_claim_record"
        rewardButton.titleLabel?.font = .systemFont(ofSize: 13)
        rewardButton.setTitleColor(.white, for: .normal)
        rewardButton.setImage(UIImage(named: "3.icon_Claim Rec2"), for: .normal)
        rewardButton.addTarget(self, action: #selector(rewardRecordTapAction), for: .touchUpInside)
        bgIV.addSubview(rewardButton)
        rewardButton.snp.makeConstraints { make in
            make.leading.equalTo(bgIV.snp.centerX)
            make.trailing.equalToSuperview()
            make.top.equalTo(lineHIV.snp.bottom)
            make.bottom.equalToSuperview()
            make.height.equalTo(delegateButton.snp.height)
        }

        let lineVIV = UIImageView()
        lineVIV.backgroundColor = line_white_color
        bgIV.addSubview(lineVIV)
        lineVIV.snp.makeConstraints { make in
            make.width.equalTo(1/UIScreen.main.scale)
            make.height.equalTo(12)
            make.centerX.equalToSuperview()
            make.centerY.equalTo(delegateButton.snp.centerY)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func delegateRecordTapAction() {
        delegateRecordHandler?()
    }

    @objc private func rewardRecordTapAction() {
        rewardRecordHandler?()
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
