//
//  NodeTableViewCell.swift
//  platonWallet
//
//  Created by Admin on 28/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import Localize_Swift
import Kingfisher

class NodeTableViewCell: UITableViewCell {

    public let avatarIV = UIImageView()
    public let nameLabel = UILabel()
    public let delegateTitleLabel = UILabel()
    public let delegateAmountLabel = UILabel()
    public let rateLabel = UILabel()
    public let statusButton = UIButton()
    public let rankingButton = UIButton()
    
    var cellDidSelectedHandle: (() -> Void)?
    
    var node: Node? {
        didSet {
            avatarIV.kf.setImage(with: URL(string: node?.url ?? ""), placeholder: UIImage(named: "3.icon_default"))
            nameLabel.text = node?.name
            delegateAmountLabel.text = node?.delegateAmount
            statusButton.setTitle(node?.status.0 ?? "--", for: .normal)
            statusButton.setTitleColor(node?.status.1 ?? status_blue_color, for: .normal)
            statusButton.layer.borderColor = (node?.status.1 ?? status_blue_color).cgColor
            rateLabel.text = node?.rate ?? "--"
            rankingButton.setTitle(node?.rank.0 ?? "--", for: .normal)
            rankingButton.setBackgroundImage(node?.rank.1, for: .normal)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = normal_background_color
        
        let containerView = UIButton()
        containerView.backgroundColor = .white
        containerView.addTarget(self, action: #selector(containerViewTapAction), for: .touchUpInside)
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(16)
            make.height.equalTo(80)
            make.bottom.equalToSuperview()
        }
        
        avatarIV.addMaskView(corners: .allCorners, cornerRadiiV: 21)
        avatarIV.image = UIImage(named: "walletAvatar_1")
        containerView.addSubview(avatarIV)
        avatarIV.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(5)
            make.width.height.equalTo(42)
        }
        
        nameLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)
        nameLabel.textColor = .black
        nameLabel.text = "--"
        nameLabel.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
        containerView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(19)
            make.leading.equalTo(avatarIV.snp.trailing).offset(5)
            make.height.equalTo(18)
        }
        
        statusButton.setTitle("--", for: .normal)
        statusButton.setTitleColor(common_blue_color, for: .normal)
        statusButton.layer.cornerRadius = 3.0
        statusButton.layer.borderWidth = 1 / UIScreen.main.scale
        statusButton.titleLabel?.font = UIFont.systemFont(ofSize: 11)
        statusButton.layer.borderColor = status_blue_color.cgColor
        statusButton.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
        statusButton.contentEdgeInsets = UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)
        containerView.addSubview(statusButton)
        statusButton.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel.snp.trailing).offset(6)
            make.height.equalTo(16)
            make.centerY.equalTo(nameLabel)
        }
        
        delegateTitleLabel.font = UIFont.systemFont(ofSize: 13)
        delegateTitleLabel.textColor = common_darkGray_color
        delegateTitleLabel.localizedText = "staking_validator_delegate_total"
        delegateTitleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        delegateTitleLabel.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
        containerView.addSubview(delegateTitleLabel)
        delegateTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(9)
            make.leading.equalTo(nameLabel.snp.leading)
        }
        
        delegateAmountLabel.font = UIFont.systemFont(ofSize: 13)
        delegateAmountLabel.textColor = .black
        delegateAmountLabel.text = "--"
        delegateAmountLabel.adjustsFontSizeToFitWidth = true
        delegateAmountLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        containerView.addSubview(delegateAmountLabel)
        delegateAmountLabel.snp.makeConstraints { make in
            make.leading.equalTo(delegateTitleLabel.snp.trailing).offset(6)
            make.centerY.equalTo(delegateTitleLabel)
            make.trailing.equalToSuperview().offset(-100)
        }
        
        rateLabel.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.medium)
        rateLabel.textColor = common_blue_color
        rateLabel.text = "0.00%"
        rateLabel.textAlignment = .right
        rateLabel.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
        containerView.addSubview(rateLabel)
        rateLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel)
            make.leading.greaterThanOrEqualTo(statusButton.snp.trailing).offset(5)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        let rateTitleLabel = UILabel()
        rateTitleLabel.font = .systemFont(ofSize: 11)
        rateTitleLabel.textColor = common_lightLightGray_color
        rateTitleLabel.localizedText = "staking_validator_delegate_rate_about"
        containerView.addSubview(rateTitleLabel)
        rateTitleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(rateLabel)
            make.top.equalTo(rateLabel.snp.bottom).offset(4)
        }
        
        
        rankingButton.setTitle("--", for: .normal)
        rankingButton.setBackgroundImage(UIImage(named: "3.img_mark1"), for: .normal)
        rankingButton.imageEdgeInsets = .zero
        rankingButton.setTitleColor(.white, for: .normal)
        rankingButton.titleLabel?.font = UIFont.systemFont(ofSize: 11)
        rankingButton.titleEdgeInsets = UIEdgeInsets(top: -3, left: 3, bottom: 0, right: 0)
        containerView.addSubview(rankingButton)
        rankingButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.width.equalTo(20)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func containerViewTapAction() {
        cellDidSelectedHandle?()
    }

}
