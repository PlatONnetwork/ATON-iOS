//
//  WalletBalanceTableViewCell.swift
//  platonWallet
//
//  Created by Admin on 29/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import Localize_Swift
import BigInt

class WalletBalanceTableViewCell: UITableViewCell {

    public let balanceTipLabel = UILabel()
    public let balanceLabel = UILabel()
    public let rightImageView = UIImageView()
    public let bottomlineV = UIView()
    public let containerView = UIButton()
    public let shadowView = UIView()

    var cellDidHandle: ((_ cell: WalletBalanceTableViewCell) -> Void)?

    func setupBalanceData(_ balance: (String, String, Bool)) {
        // 传入空字符串时转义成--
        if balance.0.count == 0 {
            balanceTipLabel.text = "--"
        } else {
            balanceTipLabel.text = balance.0
        }
        if balance.1.count == 0 {
            balanceLabel.text = "--"
        } else {
            balanceLabel.text = (balance.1.vonToLATString ?? "0").balanceFixToDisplay(maxRound: 8).ATPSuffix()
        }
    }

    var isTopCell: Bool = false {
        didSet {
            containerView.snp.updateConstraints { make in
                make.top.equalToSuperview().offset(isTopCell ? 14 : 0)
            }
        }
    }

    var isSelectedCell: Bool = false {
        didSet {
            balanceLabel.snp.updateConstraints { make in
                make.trailing.equalToSuperview().offset(isSelectedCell ? -44 : -16)
            }
        }
    }


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = normal_background_color

        contentView.addSubview(shadowView)
        contentView.addSubview(containerView)

        containerView.addTarget(self, action: #selector(containerTapAction), for: .touchUpInside)
        containerView.backgroundColor = .white
        containerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(14)
            make.height.equalTo(50)
            make.bottom.equalToSuperview()
        }

        shadowView.isUserInteractionEnabled = true
        shadowView.layer.shadowColor = UIColor(rgb: 0x9ca7c2).cgColor
        shadowView.layer.shadowRadius = 14.0
        shadowView.layer.shadowOffset = CGSize(width: 5, height: 5)
        shadowView.layer.shadowOpacity = 0.2
        shadowView.snp.makeConstraints { make in
            make.edges.equalTo(containerView)
        }

        balanceTipLabel.textColor = .black
        balanceTipLabel.font = .systemFont(ofSize: 15)
        balanceTipLabel.text = Localized("statking_validator_Balance")
        balanceTipLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        balanceTipLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        containerView.addSubview(balanceTipLabel)
        balanceTipLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(15)
        }

        balanceLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)
        balanceLabel.textColor = .black
        balanceLabel.textAlignment = .right
        balanceLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        balanceLabel.adjustsFontSizeToFitWidth = true
        balanceLabel.text = "0"
        containerView.addSubview(balanceLabel)
        balanceLabel.snp.makeConstraints { make in
            make.centerY.equalTo(balanceTipLabel)
            make.leading.equalTo(balanceTipLabel.snp.trailing).offset(5)
            make.trailing.equalToSuperview().offset(-44)
            make.height.equalTo(18)
        }

        containerView.addSubview(rightImageView)
        rightImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }

        bottomlineV.backgroundColor = UIColor(rgb: 0xE4E7F3)
        containerView.addSubview(bottomlineV)
        bottomlineV.snp.makeConstraints { make in
            make.height.equalTo(1/UIScreen.main.scale)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func containerTapAction() {
        cellDidHandle?(self)
    }

}
