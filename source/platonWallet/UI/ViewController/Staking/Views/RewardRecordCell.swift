//
//  RewardRecordCell.swift
//  platonWallet
//
//  Created by Admin on 3/1/2020.
//  Copyright © 2020 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class RewardRecordCell: UITableViewCell {

    let avatarIV = UIImageView()
    let nameLabel = UILabel()
    let addressLabel = UILabel()
    let balanceLabel = UILabel()
    let detailButton = UIButton()
    let timeLabel = UILabel()
    let detailContentView = UIView()

    var cellDidHandler: ((RewardRecordCell) -> Void)?
    var recordDetailDidHadler: ((RewardRecordCell) -> Void)?

    var reward: RewardModel? {
        didSet {
            avatarIV.image = reward?.avatarImage
            nameLabel.text = reward?.walletName ?? "--"
            addressLabel.text = reward?.walletAddress ?? "--"
            balanceLabel.text = reward?.amountForDisplay ?? "--"
            timeLabel.text = reward?.recordTime ?? "--"
            detailButton.isSelected = reward?.isOpen ?? false

            _ = detailContentView.subviews.filter { $0 is RewardRecordDetailView }.map { $0.removeFromSuperview() }

            if let records = reward?.records, (records.count > 0 && reward?.isOpen == true) {

                for (index, record) in records.enumerated() {
                    let view = RewardRecordDetailView()
                    view.tag = index + 1
                    view.titleLabel.text = record.nodeName ?? "--"
                    view.valueLabel.text = record.amountForDisplay
                    detailContentView.addSubview(view)

                    view.snp.makeConstraints { make in
                        make.leading.trailing.equalToSuperview()
                        if index == records.count - 1 {
                            make.bottom.equalToSuperview().offset(-16)
                        }
                        if index > 0 {
                            let preView = detailContentView.viewWithTag(index)
                            make.top.equalTo(preView!.snp.bottom)
                        } else {
                            make.top.equalToSuperview().offset(1)
                        }
                    }
                }
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
        containerView.addTarget(self, action: #selector(cellTapAction), for: .touchUpInside)
        containerView.backgroundColor = .white
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(16)
//            make.height.equalTo(128)
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
        walletBackgroundView.image = UIImage(named: "bg_staking_wallet_img")?.resizableImage(withCapInsets: UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3), resizingMode: .stretch)
        containerView.addSubview(walletBackgroundView)
        walletBackgroundView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(60)
        }

        avatarIV.addMaskView(corners: .allCorners, cornerRadiiV: 21)
        avatarIV.image = UIImage(named: "walletAvatar_1")
        walletBackgroundView.addSubview(avatarIV)
        avatarIV.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(5)
            make.width.height.equalTo(42)
        }

        nameLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)
        nameLabel.textColor = .black
        nameLabel.text = Localized("staking_main_wallet_name")
        nameLabel.setContentHuggingPriority(.required, for: .horizontal)
        walletBackgroundView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalTo(avatarIV.snp.trailing).offset(5)
            make.height.equalTo(18)
        }

        addressLabel.font = UIFont.systemFont(ofSize: 13)
        addressLabel.textColor = common_darkGray_color
        addressLabel.text = "--"
        walletBackgroundView.addSubview(addressLabel)
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(3)
            make.leading.equalTo(nameLabel.snp.leading)
        }

        balanceLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)
        balanceLabel.textColor = .black
        balanceLabel.text = "0.00"
        balanceLabel.textAlignment = .right
        balanceLabel.adjustsFontSizeToFitWidth = true
        balanceLabel.minimumScaleFactor = 0.5
        balanceLabel.setContentHuggingPriority(.required, for: .horizontal)
        balanceLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        walletBackgroundView.addSubview(balanceLabel)
        balanceLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel)
            make.leading.equalTo(nameLabel.snp.trailing).offset(5)
            make.trailing.equalToSuperview().offset(-10)
        }

        let delegateBackgroundView = UIView()
        delegateBackgroundView.isUserInteractionEnabled = false
        delegateBackgroundView.backgroundColor = .white
        containerView.addSubview(delegateBackgroundView)
        delegateBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(walletBackgroundView.snp.bottom)
            make.leading.trailing.equalTo(walletBackgroundView)
//            make.bottom.equalToSuperview()
        }

        timeLabel.text = "#"
        timeLabel.textColor = common_lightLightGray_color
        timeLabel.font = .systemFont(ofSize: 15)
        timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        delegateBackgroundView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-16)
            make.height.equalTo(15)
            //            make.width.equalToSuperview().offset(-10).dividedBy(2)
        }

        detailButton.setImage(UIImage(named: "3.icon_Drop-down"), for: .normal)
        detailButton.setImage(UIImage(named: "3.icon_Pull up"), for: .selected)
//        detailButton.addTarget(self, action: #selector(recordDetailAction), for: .touchUpInside)
        delegateBackgroundView.addSubview(detailButton)
        detailButton.snp.makeConstraints { make in
            make.height.width.equalTo(21)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-10)
        }

        containerView.addSubview(detailContentView)
        detailContentView.snp.makeConstraints { make in
            make.top.equalTo(delegateBackgroundView.snp.bottom)
            make.leading.trailing.equalTo(walletBackgroundView)
            make.bottom.equalToSuperview()
        }

        let lineV = UIView()
        lineV.backgroundColor = UIColor(rgb: 0xE4E7F3)
        detailContentView.addSubview(lineV)
        lineV.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(1/UIScreen.main.scale)
            make.top.equalToSuperview()
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func cellTapAction() {
        cellDidHandler?(self)
    }

    @objc private func recordDetailAction() {
        recordDetailDidHadler?(self)
    }

}

class RewardRecordDetailView: UIView {

    let titleLabel = UILabel()
    let valueLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = .black
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(16)
            make.bottom.equalToSuperview()
        }

        valueLabel.font = .systemFont(ofSize: 14, weight: .medium)
        valueLabel.textColor = .black
        valueLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        valueLabel.setContentHuggingPriority(.required, for: .horizontal)
        addSubview(valueLabel)
        valueLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing)
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalTo(titleLabel.snp.centerY)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
