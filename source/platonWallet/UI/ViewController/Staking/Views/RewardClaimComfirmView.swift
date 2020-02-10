//
//  RewardClaimComfirmView.swift
//  platonWallet
//
//  Created by Admin on 6/1/2020.
//  Copyright © 2020 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class RewardClaimComfirmView: UIView {

    let valueLabel = UILabel()
    let feeLabel = UILabel()
    let walletLabel = UILabel()
    let balanceLabel = UILabel()
    let comfirmBtn = PButton()

    var onCompletion: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        backgroundColor = .white

        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.text = Localized("claim_comfirm_title")
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }

        let lineV = UIView()
        lineV.backgroundColor = common_line_color
        addSubview(lineV)
        lineV.snp.makeConstraints { make in
            make.height.equalTo(1/UIScreen.main.scale)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
        }

        valueLabel.textAlignment = .center
        valueLabel.textColor = common_blue_color
        valueLabel.font = .systemFont(ofSize: 22, weight: .medium)
        addSubview(valueLabel)
        valueLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(lineV.snp.bottom).offset(16)
        }

        let descLabel = UILabel()
        descLabel.textAlignment = .center
        descLabel.text = Localized("claim_comfirm_desc")
        descLabel.font = .systemFont(ofSize: 12)
        descLabel.textColor = common_lightLightGray_color
        addSubview(descLabel)
        descLabel.snp.makeConstraints { make in
            make.top.equalTo(valueLabel.snp.bottom).offset(6)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }

        let feeTipLabel = UILabel()
        feeTipLabel.text = Localized("claim_comfirm_fee")
        feeTipLabel.font = .systemFont(ofSize: 14)
        feeTipLabel.textColor = common_darkGray_color
        feeTipLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        feeTipLabel.setContentHuggingPriority(.required, for: .horizontal)
        addSubview(feeTipLabel)
        feeTipLabel.snp.makeConstraints { make in
            make.top.equalTo(descLabel.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(16)
        }

        feeLabel.textAlignment = .right
        feeLabel.textColor = .black
        feeLabel.font = .systemFont(ofSize: 14)
        addSubview(feeLabel)
        feeLabel.snp.makeConstraints { make in
            make.leading.equalTo(feeTipLabel.snp.trailing).offset(5)
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(feeTipLabel.snp.centerY)
        }

        let walletTipLabel = UILabel()
        walletTipLabel.text = Localized("claim_comfirm_wallet")
        walletTipLabel.font = .systemFont(ofSize: 14)
        walletTipLabel.textColor = common_darkGray_color
        walletTipLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        walletTipLabel.setContentHuggingPriority(.required, for: .horizontal)
        addSubview(walletTipLabel)
        walletTipLabel.snp.makeConstraints { make in
            make.top.equalTo(feeTipLabel.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
        }

        walletLabel.textAlignment = .right
        walletLabel.textColor = .black
        walletLabel.font = .systemFont(ofSize: 14, weight: .medium)
        addSubview(walletLabel)
        walletLabel.snp.makeConstraints { make in
            make.leading.equalTo(walletTipLabel.snp.trailing).offset(5)
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(walletTipLabel.snp.centerY)
        }

        balanceLabel.textAlignment = .center
        balanceLabel.textColor = .black
        balanceLabel.font = .systemFont(ofSize: 13)
        addSubview(balanceLabel)
        balanceLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(walletTipLabel.snp.bottom).offset(32)
        }

        comfirmBtn.localizedNormalTitle = "claim_comfirm_comfirm"
        comfirmBtn.addTarget(self, action: #selector(submitAction), for: .touchUpInside)
        addSubview(comfirmBtn)
        comfirmBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(44)
            make.top.equalTo(balanceLabel.snp.bottom).offset(10)
            make.bottom.equalToSuperview().offset(-20)
        }
        comfirmBtn.style = .blue
    }

    @objc func submitAction() {
        onCompletion?()
    }

}
