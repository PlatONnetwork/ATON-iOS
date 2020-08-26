//
//  AssetWalletsSectionView.swift
//  platonWallet
//
//  Created by Admin on 27/3/2020.
//  Copyright © 2020 ju. All rights reserved.
//

import UIKit
import BigInt

class AssetWalletsSectionView: UIView {
    
    lazy var backView: UIView = {
        let view = UIView()
        return view
    }()

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
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    lazy var restrictedLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    lazy var typeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        return label
    }()

    lazy var typeContentView: UIView = {
        let typeView = UIView()
        typeView.backgroundColor = UIColor(rgb: 0xC0D5FF)
        return typeView
    }()

    lazy var typeContentLabel: UILabel = {
        let label = PaddingLabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        label.backgroundColor = UIColor(rgb: 0xC0D5FF)
        label.topInset = 2
        label.bottomInset = 2
        label.leftInset = 10
        label.rightInset = 10
        return label
    }()

    lazy var walletIV: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    lazy var managerBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon-wallet-manager"), for: .normal)
        button.addTarget(self, action: #selector(managerPressed), for: .touchUpInside)
        button.contentEdgeInsets = .zero
        button.imageView?.contentMode = .scaleAspectFill
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
        button.addTarget(self, action: #selector(sendPressed), for: .touchUpInside)
        return button
    }()

    lazy var sectionTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .black
        label.localizedText = "asset_section_title"
        return label
    }()

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
            guard let self = self else { return }
            self.walletNameLabel.text = wallet?.name
            if self.viewModel.assetIsHide.value {
                self.balanceLabel.text = "***"
            } else {
                self.balanceLabel.text = self.viewModel.freeBalance.value.description.vonToLATString
            }

            if self.viewModel.lockBalance.value > BigUInt.zero {
                let attribute_1 = NSAttributedString(string: "staking_balance_locked_position")
                let attribute_2 = NSAttributedString(string: ":")
                if self.viewModel.assetIsHide.value {
                    self.restrictedLabel.localizedAttributedTexts = [attribute_1, attribute_2, NSAttributedString(string: "***")]
                } else {
                    self.restrictedLabel.localizedAttributedTexts = [attribute_1, attribute_2, NSAttributedString(string: self.viewModel.lockBalance.value.description.vonToLATString ?? "0.00")]
                }
                // 如果文字溢出， 数字换行显示
                if(self.restrictedLabel.isTruncated) {
                    self.restrictedLabel.localizedAttributedTexts = [attribute_1, attribute_2, NSAttributedString(string: "\n"),NSAttributedString(string: self.viewModel.lockBalance.value.description.vonToLATString ?? "0.00")]
                }
            } else {
                self.restrictedLabel.text = nil
            }

            self.walletIV.image = UIImage(named: wallet?.avatar ?? "")

            guard let wallet = wallet else { return }
            self.typeContentLabel.localizedText = wallet.type.localizeText

            if wallet.type == .cold {
                self.sendBtn.setTitleColor(.white, for: .normal)
                self.sendBtn.localizedNormalTitle = "asset_section_signature"
                self.sendBtn.backgroundColor = UIColor(rgb: 0xF59A23)
            } else {
                self.sendBtn.setTitleColor(common_blue_color, for: .normal)
                self.sendBtn.localizedNormalTitle = "asset_section_send"
                self.sendBtn.backgroundColor = .white
            }

            if wallet.type == .classic {
                self.typeContentLabel.isHidden = true
            } else {
                self.typeContentLabel.isHidden = false
//                self.layoutIfNeeded()

//                let path = UIBezierPath(roundedRect: self.typeContentLabel.bounds, byRoundingCorners: [.topLeft, .bottomLeft], cornerRadii: CGSize(width: 12, height: 0))
//                let typeShapeMask = CAShapeLayer()
//                typeShapeMask.path = path.cgPath
//                self.typeContentLabel.layer.mask = typeShapeMask
            }
        }

        viewModel.assetIsHide.addObserver { [weak self] (isHide) in
            if isHide {
                self?.balanceLabel.text = "***"
                self?.balanceTipLabel.text = nil
            } else {
                self?.balanceLabel.text = self?.viewModel.wallet.value?.balanceString
                self?.balanceTipLabel.text = "LAT"
            }
        }

        viewModel.freeBalance.addObserver { [weak self] (value) in
            guard let self = self else { return }
            if self.viewModel.assetIsHide.value {
                self.balanceLabel.text = "***"
            } else {
                self.balanceLabel.text = value.description.vonToLATString
            }
        }

        viewModel.lockBalance.addObserver { [weak self] (value) in
            guard let self = self else { return }
            if self.viewModel.lockBalance.value > BigUInt.zero {
                let attribute_1 = NSAttributedString(string: "staking_balance_locked_position")
                let attribute_2 = NSAttributedString(string: ":")
                if self.viewModel.assetIsHide.value {
                    self.restrictedLabel.localizedAttributedTexts = [attribute_1, attribute_2, NSAttributedString(string: "***")]
                } else {
                    self.restrictedLabel.localizedAttributedTexts = [attribute_1, attribute_2, NSAttributedString(string: value.description.vonToLATString ?? "0.00")]
                }
                // 如果文字溢出， 数字换行现实
                if(self.restrictedLabel.isTruncated) {
                    self.restrictedLabel.localizedAttributedTexts = [attribute_1, attribute_2, NSAttributedString(string: "\n"),NSAttributedString(string: self.viewModel.lockBalance.value.description.vonToLATString ?? "0.00")]
                }
            } else {
                self.restrictedLabel.localizedAttributedTexts = nil
            }
        }
    }

    func initView() {
        addSubview(backView)
        backView.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.top.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(0)
        }
        
        backgroundColor = UIColor(rgb: 0xf9fbff)
        backView.backgroundColor = backgroundColor

        let contentView = UIView()
        backView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
//            make.top.trailing.leading.equalToSuperview()
            make.top.equalTo(-1)
            make.leading.trailing.equalToSuperview()
        }

        let bgImageView = UIImageView()
        bgImageView.image = UIImage(named: "asset_bj2")
        contentView.addSubview(bgImageView)
        bgImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        backView.addSubview(sectionTitleLabel)
        sectionTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(contentView.snp.bottom).offset(12)
            make.bottom.equalToSuperview().offset(-16)
        }

        contentView.addSubview(walletNameLabel)
        walletNameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-72)
            make.top.equalToSuperview().offset(16)
        }

        contentView.addSubview(balanceLabel)
        balanceLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(walletNameLabel.snp.bottom).offset(10)
        }

        balanceTipLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        balanceTipLabel.setContentHuggingPriority(.required, for: .horizontal)
        balanceTipLabel.font = UIFont.systemFont(ofSize: 14)
        balanceTipLabel.textColor = .white
        balanceTipLabel.text = "LAT"
        contentView.addSubview(balanceTipLabel)
        balanceTipLabel.snp.makeConstraints { make in
            make.leading.equalTo(balanceLabel.snp.trailing).offset(6)
            make.bottom.equalTo(balanceLabel.snp.bottom).offset(-5)
            make.trailing.lessThanOrEqualToSuperview().offset(-16).priorityRequired()
        }

        walletIV.layer.cornerRadius = 20
        contentView.addSubview(walletIV)
        walletIV.snp.makeConstraints { make in
            make.height.width.equalTo(40)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(10)
        }

        contentView.addSubview(restrictedLabel)
        restrictedLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(balanceLabel.snp.bottom).offset(7)
            make.trailing.equalToSuperview().offset(-100)
            make.height.equalTo(40)
        }

        typeContentLabel.setContentHuggingPriority(.required, for: .vertical)
        typeContentLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        contentView.addSubview(typeContentLabel)
        typeContentLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.equalTo(balanceLabel.snp.bottom).offset(4)
        }

        let receiveBtn = UIButton()
        receiveBtn.layer.cornerRadius = 17.0
        receiveBtn.setTitleColor(common_blue_color, for: .normal)
        receiveBtn.backgroundColor = .white
        receiveBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        receiveBtn.localizedNormalTitle = "asset_section_receive"
        receiveBtn.contentEdgeInsets = UIEdgeInsets(top: 7, left: 15, bottom: 7, right: 15)
        receiveBtn.addTarget(self, action: #selector(receivePressed), for: .touchUpInside)
        contentView.addSubview(receiveBtn)
        receiveBtn.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(typeContentLabel.snp.bottom).offset(17)
            make.top.greaterThanOrEqualTo(restrictedLabel.snp.bottom).offset(17)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(34)
            make.bottom.equalToSuperview().offset(-16)
        }

        contentView.addSubview(sendBtn)
        sendBtn.snp.makeConstraints { make in
            make.height.equalTo(34)
            make.trailing.equalTo(receiveBtn.snp.leading).offset(-10)
            make.centerY.equalTo(receiveBtn.snp.centerY)
        }

        contentView.addSubview(managerBtn)
        managerBtn.snp.makeConstraints { make in
            make.trailing.equalTo(sendBtn.snp.leading).offset(-10)
            make.height.width.equalTo(34)
            make.centerY.equalTo(sendBtn.snp.centerY)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
            self.typeContentLabel.cropView(corners: [.topLeft, .bottomLeft], cornerRadiiV: self.typeContentLabel.bounds.height / 2.0)
        }
    }

    @objc func sendPressed() {
        if let type = viewModel.wallet.value?.type, type == .cold {
            viewModel.onSignaturePressed?()
        } else {
            viewModel.onSendPressed?()
        }
    }

    @objc func receivePressed() {
        viewModel.onReceivePressed?()
    }

    @objc func managerPressed() {
        viewModel.onManagerPressed?()
    }
}
