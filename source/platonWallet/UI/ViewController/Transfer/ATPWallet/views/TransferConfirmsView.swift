//
//  TransferConfirmsView.swift
//  platonWallet
//
//  Created by Admin on 1/4/2020.
//  Copyright © 2020 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class TransferConfirmsView: UIView {

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()

    lazy var submitBtn: PButton = {
        let button = PButton()
        button.style = .blue
        return button
    }()

    lazy var totalLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 40, weight: .medium)
        label.textColor = common_blue_color
        label.textAlignment = .center
        return label
    }()

    lazy var transactionTypeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .black
        return label
    }()

    lazy var toAddressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()

    lazy var feeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .black
        return label
    }()

    lazy var walletName: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()

    lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "1.icon_shut down"), for: .normal)
        return button
    }()

    var onCompletion: (() -> Void)?
    var dismissCompletion: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        initialUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initialUI() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }

        addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalTo(titleLabel)
            make.height.width.equalTo(32)
        }

        let hLineIV = UIImageView()
        hLineIV.backgroundColor = UIColor(rgb: 0xE4E7F3)
        addSubview(hLineIV)
        hLineIV.snp.makeConstraints { make in
            make.height.equalTo(1/UIScreen.main.scale)
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        addSubview(totalLabel)
        totalLabel.snp.makeConstraints { make in
            make.top.equalTo(hLineIV.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        let typeLabel = TransferConfirmsView.factoryTitleTipUILabel(Localized("transferVC_confirm_PayInfo"))
        addSubview(typeLabel)
        typeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(totalLabel.snp.bottom).offset(30)
        }

        addSubview(transactionTypeLabel)
        transactionTypeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(120)
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalTo(typeLabel.snp.top)
        }

        let senderLabel = TransferConfirmsView.factoryTitleTipUILabel(Localized("transferVC_confirm_From"))
        addSubview(senderLabel)
        senderLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(typeLabel.snp.bottom).offset(20)
        }

        addSubview(walletName)
        walletName.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(120)
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalTo(senderLabel.snp.top)
        }

        let recipientLabel = TransferConfirmsView.factoryTitleTipUILabel(Localized("transferVC_confirm_To"))
        addSubview(recipientLabel)
        recipientLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(walletName.snp.bottom).offset(20)
        }

        addSubview(toAddressLabel)
        toAddressLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(120)
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalTo(recipientLabel.snp.top)
        }

        let feeTipLabel = TransferConfirmsView.factoryTitleTipUILabel(Localized("transferVC_confirm_Fee"))
        addSubview(feeTipLabel)
        feeTipLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(toAddressLabel.snp.bottom).offset(20)
        }

        addSubview(feeLabel)
        feeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(120)
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalTo(feeTipLabel.snp.top)
        }

        addSubview(submitBtn)
        submitBtn.snp.makeConstraints { make in
            make.top.equalTo(feeLabel.snp.bottom).offset(52)
            make.bottom.equalToSuperview().offset(-20)
            make.leading.equalToSuperview().offset(49)
            make.trailing.equalToSuperview().offset(-49)
            make.height.equalTo(44)
        }

        backgroundColor = .white
        submitBtn.style = .blue
        submitBtn.localizedNormalTitle = "transferVC_confirm_Submit"
        submitBtn.addTarget(self, action: #selector(submitAction), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
    }

    @objc func submitAction() {
        onCompletion?()
    }

    @objc func closeAction() {
        dismissCompletion?()
    }

    static func factoryTitleTipUILabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.textColor = common_darkGray_color
        label.font = .systemFont(ofSize: 15)
        label.text = text
        return label
    }

}
