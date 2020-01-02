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

    var recordButtonHandler: (() -> Void)?

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
            make.top.equalTo(totalDelegateLabel.snp.bottom).offset(6)
            make.leading.equalTo(totalDelegateTipLabel.snp.leading)
            make.trailing.equalToSuperview().offset(-20)
        }

        let unclaimedRewardTipLabel = UILabel()
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
        bgIV.addSubview(unclaimedRewardLabel)
        unclaimedRewardLabel.snp.makeConstraints { make in
            make.leading.equalTo(unclaimedRewardTipLabel.snp.leading)
            make.trailing.equalTo(unclaimedRewardTipLabel.snp.trailing)
            make.top.equalTo(unclaimedRewardTipLabel.snp.bottom).offset(5)
        }

        let totalRewardTipLabel = UILabel()
        totalRewardTipLabel.font = .systemFont(ofSize: 13)
        totalRewardTipLabel.textColor = .white
        totalRewardTipLabel.localizedText = ""
        bgIV.addSubview(totalRewardTipLabel)
        totalRewardTipLabel.snp.makeConstraints { make in
            make.leading.equalTo(bgIV.snp.centerX).offset(5)
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalTo(unclaimedRewardTipLabel.snp.top)
        }

        totalRewardLabel.font = .systemFont(ofSize: 14)
        totalRewardLabel.textColor = .white
        bgIV.addSubview(totalRewardLabel)
        totalRewardLabel.snp.makeConstraints { make in
            make.leading.equalTo(unclaimedRewardTipLabel.snp.leading)
            make.trailing.equalTo(unclaimedRewardTipLabel.snp.trailing)
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
        bgIV.addSubview(rewardButton)
        rewardButton.snp.makeConstraints { make in
            make.leading.equalTo(bgIV.snp.centerX)
            make.trailing.equalToSuperview()
            make.top.equalTo(lineHIV.snp.bottom)
            make.bottom.equalToSuperview()
            make.height.equalTo(delegateButton.snp.height)
        }


//        let recordButton = UIButton()
//        recordButton.addTarget(self, action: #selector(recordTapAction), for: .touchUpInside)
//        recordButton.localizedNormalTitle = "staking_main_delegate_record"
//        recordButton.setTitleColor(common_blue_color, for: .normal)
//        recordButton.setImage(UIImage(named: "3.icon_Record"), for: .normal)
//        recordButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
//        recordButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
//        addSubview(recordButton)
//        recordButton.snp.makeConstraints { make in
//            make.top.equalTo(delegateAvatarIV)
//            make.leading.greaterThanOrEqualTo(delegateNameTipLabel.snp.trailing).offset(5)
//            make.trailing.equalToSuperview().offset(-16)
//        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func recordTapAction() {
        recordButtonHandler?()
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
