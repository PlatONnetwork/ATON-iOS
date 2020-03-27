//
//  AssetWalletsSectionView.swift
//  platonWallet
//
//  Created by Admin on 27/3/2020.
//  Copyright © 2020 ju. All rights reserved.
//

import UIKit

class AssetWalletsSectionView: UIView {

    lazy var walletNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .white
        return label
    }()

    lazy var balanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30, weight: .medium)
        label.textColor = .white
        return label
    }()

    lazy var restrictedLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()

    lazy var walletTypeBtn: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(rgb: 0xC0D5FF)
        return button
    }()

    lazy var walletIV: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    lazy var managerBtn: UIButton = {
        let button = UIButton()
        return button
    }()

    lazy var sendBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.layer.cornerRadius = 17.0
        button.setTitleColor(common_blue_color, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 7, left: 15, bottom: 7, right: 15)
        button.localizedNormalTitle = "asset_section_send"
        return button
    }()

    let typeShapeMask = CAShapeLayer()
    let balanceTipLabel = UILabel()

    var viewModel: AssetSectionViewModel {
        return controller.viewModel
    }

    let controller: AssetWalletsSectionController

    required init(controller: AssetWalletsSectionController) {
        self.controller = controller
        super.init(frame: .zero)

        initView()
        initBinding()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initBinding() {
        viewModel.wallet.addObserver { [weak self] (wallet) in
            self?.walletNameLabel.text = wallet?.name
            self?.balanceLabel.text = wallet?.balanceString

            if let restrictString = wallet?.restrictBalanceString {
                self?.restrictedLabel.localizedText = "staking_balance_locked_position" + ":" + restrictString
            } else {
                self?.restrictedLabel.text = nil
            }
            self?.walletIV.image = UIImage(named: wallet?.avatar ?? "")
            self?.managerBtn.setImage(wallet?.selectedIcon, for: .normal)

            guard let wallet = wallet else { return }

            if wallet.type == .cold {
                self?.sendBtn.localizedNormalTitle = "asset_section_signature"
                self?.sendBtn.backgroundColor = UIColor(rgb: 0xF59A23)
            } else {
                self?.sendBtn.localizedNormalTitle = "asset_section_send"
                self?.sendBtn.backgroundColor = .white
            }

            if wallet.type == .classic {
                self?.walletTypeBtn.isHidden = true
            } else {
                self?.walletTypeBtn.isHidden = false
                self?.walletTypeBtn.localizedNormalTitle = wallet.type.localizeText
            }
        }

        controller.headerViewModel?.assetIsHide.addObserver({ [weak self] (isHide) in
            if isHide {
                self?.balanceLabel.text = "***"
                self?.balanceTipLabel.text = nil
            } else {
                self?.balanceLabel.text = self?.viewModel.wallet.value?.balanceString
                self?.balanceTipLabel.text = "LAT"
            }
        })
    }

    func initView() {
        backgroundColor = UIColor(rgb: 0xf9fbff)

        let bgImageView = UIImageView()
        bgImageView.image = UIImage(named: "asset_bj2")
        addSubview(bgImageView)
        bgImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        addSubview(walletNameLabel)
        walletNameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(72)
            make.top.equalToSuperview().offset(16)
        }

        addSubview(balanceLabel)
        balanceLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(walletNameLabel.snp.bottom).offset(10)

        }

        balanceTipLabel.font = UIFont.systemFont(ofSize: 14)
        balanceTipLabel.textColor = .white
        balanceTipLabel.text = "LAT"
        addSubview(balanceTipLabel)
        balanceTipLabel.snp.makeConstraints { make in
            make.leading.equalTo(balanceLabel.snp.trailing).offset(6)
            make.bottom.equalTo(balanceLabel.snp.bottom)
            make.trailing.lessThanOrEqualToSuperview().offset(-16)
        }

        walletIV.layer.cornerRadius = 20
        addSubview(walletIV)
        walletIV.snp.makeConstraints { make in
            make.height.width.equalTo(40)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(10)
        }

        addSubview(restrictedLabel)
        restrictedLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(balanceLabel.snp.bottom).offset(7)
            make.height.equalTo(40)
        }

        walletTypeBtn.setContentCompressionResistancePriority(.required, for: .horizontal)
        walletTypeBtn.setContentHuggingPriority(.required, for: .horizontal)
        addSubview(walletTypeBtn)
        walletTypeBtn.snp.makeConstraints { make in
            make.height.equalTo(24)
            make.trailing.equalToSuperview()
            make.top.equalTo(balanceLabel.snp.bottom).offset(4)
        }
        walletTypeBtn.layer.mask = typeShapeMask

        let receiveBtn = UIButton()
        receiveBtn.layer.cornerRadius = 17.0
        receiveBtn.setTitleColor(common_blue_color, for: .normal)
        receiveBtn.backgroundColor = .white
        receiveBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        receiveBtn.localizedNormalTitle = "asset_section_receive"
        receiveBtn.contentEdgeInsets = UIEdgeInsets(top: 7, left: 15, bottom: 7, right: 15)
        addSubview(receiveBtn)
        receiveBtn.snp.makeConstraints { make in
            make.top.equalTo(walletTypeBtn.snp.bottom).offset(17)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(34)
            make.bottom.equalToSuperview().offset(-16)
        }

        addSubview(sendBtn)
        sendBtn.snp.makeConstraints { make in
            make.height.equalTo(34)
            make.trailing.equalTo(receiveBtn.snp.leading).offset(-10)
            make.centerY.equalTo(receiveBtn.snp.centerY)
        }

        managerBtn.layer.cornerRadius = 17
        addSubview(managerBtn)
        managerBtn.snp.makeConstraints { make in
            make.trailing.equalTo(sendBtn.snp.leading).offset(-10)
            make.height.width.equalTo(44)
            make.centerY.equalTo(sendBtn.snp.centerY)
        }
    }

    override func layoutSubviews() {
        let path = UIBezierPath(roundedRect: walletTypeBtn.bounds, byRoundingCorners: [.bottomLeft, .topLeft], cornerRadii: CGSize(width: 0, height: 12))
        typeShapeMask.path = path.cgPath
        super.layoutSubviews()
    }
}
