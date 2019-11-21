//
//  DelegateRecordTableViewCell.swift
//  platonWallet
//
//  Created by Admin on 24/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class DelegateRecordTableViewCell: UITableViewCell {

    public let nodeAvatarIV = UIImageView()
    public let nodeNameLabel = UILabel()
    public let nodeAddressLabel = UILabel()
    public let nodeBalanceLabel = UILabel()
    public let recordStatusLabel = UILabel()

    public let timeLabel = UILabel()
    public let walletAvatarIV = UIImageView()
    public let walletAddressLabel = UILabel()

    var cellDidHandler: ((DelegateRecordTableViewCell) -> Void)?

    var transaction: Transaction? {
        didSet {
            nodeAvatarIV.image = transaction?.recordIconIV
            if let nodeName = transaction?.nodeName, nodeName.count > 0 {
                nodeNameLabel.text = nodeName
            } else {
                nodeNameLabel.text = "--"
            }
            nodeAddressLabel.text = transaction?.nodeId?.nodeIdForDisplayShort() ?? "--"
            nodeBalanceLabel.text = transaction?.recordAmountForDisplay ?? "--"
            recordStatusLabel.text = transaction?.recordStatus.0
            recordStatusLabel.textColor = transaction?.recordStatus.1

            timeLabel.text = transaction?.recordTime ?? "--"
            walletAvatarIV.image = transaction?.fromAvatarImage
            walletAddressLabel.text = transaction?.recordWalletName ?? "--"
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
        containerView.addTarget(self, action: #selector(cellTapAction), for: .touchUpInside)
        containerView.backgroundColor = .white
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(16)
            make.height.equalTo(128)
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
//        walletBackgroundView.isUserInteractionEnabled = true
        walletBackgroundView.image = UIImage(named: "bg_staking_wallet_img")?.resizableImage(withCapInsets: UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3))
        containerView.addSubview(walletBackgroundView)
        walletBackgroundView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(60)
        }

        nodeAvatarIV.addMaskView(corners: .allCorners, cornerRadiiV: 21)
        nodeAvatarIV.image = UIImage(named: "walletAvatar_1")
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

        nodeAddressLabel.font = UIFont.systemFont(ofSize: 13)
        nodeAddressLabel.textColor = common_darkGray_color
        nodeAddressLabel.text = "--"
        walletBackgroundView.addSubview(nodeAddressLabel)
        nodeAddressLabel.snp.makeConstraints { make in
            make.top.equalTo(nodeNameLabel.snp.bottom).offset(3)
            make.leading.equalTo(nodeNameLabel.snp.leading)
        }

        nodeBalanceLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)
        nodeBalanceLabel.textColor = .black
        nodeBalanceLabel.text = "0.00"
        nodeBalanceLabel.textAlignment = .right
        nodeBalanceLabel.adjustsFontSizeToFitWidth = true
        nodeBalanceLabel.minimumScaleFactor = 0.5
        walletBackgroundView.addSubview(nodeBalanceLabel)
        nodeBalanceLabel.snp.makeConstraints { make in
            make.top.equalTo(nodeNameLabel)
            make.leading.equalTo(nodeNameLabel.snp.trailing).offset(5)
            make.trailing.equalToSuperview().offset(-10)
        }

        recordStatusLabel.font = .systemFont(ofSize: 11)
        recordStatusLabel.textColor = .black
        recordStatusLabel.text = "--"
        recordStatusLabel.textAlignment = .right
        walletBackgroundView.addSubview(recordStatusLabel)
        recordStatusLabel.snp.makeConstraints { make in
            make.top.equalTo(nodeNameLabel.snp.bottom).offset(6)
            make.trailing.equalTo(nodeBalanceLabel)
            make.leading.equalTo(nodeAddressLabel.snp.trailing).offset(5)
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

        timeLabel.text = "#"
        timeLabel.textColor = common_lightLightGray_color
        timeLabel.font = .systemFont(ofSize: 15)
        delegateBackgroundView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.height.equalTo(15)
            make.width.equalToSuperview().offset(-10).dividedBy(2)
        }

        walletAvatarIV.image = UIImage(named: "walletAvatar_1_s")
        delegateBackgroundView.addSubview(walletAvatarIV)
        walletAvatarIV.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
//            make.leading.equalTo(timeLabel.snp.trailing).offset(10)
            make.height.width.equalTo(20)
        }

        walletAddressLabel.textColor = common_lightLightGray_color
        walletAddressLabel.font = .systemFont(ofSize: 15)
        delegateBackgroundView.addSubview(walletAddressLabel)
        walletAddressLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
            make.leading.equalTo(walletAvatarIV.snp.trailing).offset(2)
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func cellTapAction() {
        cellDidHandler?(self)
    }

}
