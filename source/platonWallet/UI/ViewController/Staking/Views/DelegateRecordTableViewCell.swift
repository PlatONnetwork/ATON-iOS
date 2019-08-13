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

    public let walletAvatarIV = UIImageView()
    public let walletNameLabel = UILabel()
    public let walletAddressLabel = UILabel()
    public let walletBalanceLabel = UILabel()
    public let recordStatusLabel = UILabel()
    
    public let timeLabel = UILabel()
    public let toAddressView = UIButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = normal_background_color
        
        let containerView = UIButton()
        containerView.backgroundColor = .white
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(16)
            make.height.equalTo(128)
            make.bottom.equalToSuperview()
        }
        
        let walletBackgroundView = UIImageView()
        walletBackgroundView.image = UIImage(named: "bg_staking_wallet_img")?.resizableImage(withCapInsets: UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3))
        containerView.addSubview(walletBackgroundView)
        walletBackgroundView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(60)
        }
        
        walletAvatarIV.addMaskView(corners: .allCorners, cornerRadiiV: 21)
        walletAvatarIV.image = UIImage(named: "walletAvatar_1")
        walletBackgroundView.addSubview(walletAvatarIV)
        walletAvatarIV.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(5)
            make.width.height.equalTo(42)
        }
        
        walletNameLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)
        walletNameLabel.textColor = .black
        walletNameLabel.text = Localized("staking_main_wallet_name")
        walletBackgroundView.addSubview(walletNameLabel)
        walletNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalTo(walletAvatarIV.snp.trailing).offset(5)
            make.trailing.equalToSuperview().offset(-110)
            make.height.equalTo(18)
        }
        
        walletAddressLabel.font = UIFont.systemFont(ofSize: 13)
        walletAddressLabel.textColor = common_darkGray_color
        walletAddressLabel.text = "--"
        walletBackgroundView.addSubview(walletAddressLabel)
        walletAddressLabel.snp.makeConstraints { make in
            make.top.equalTo(walletNameLabel.snp.bottom).offset(3)
            make.leading.equalTo(walletNameLabel.snp.leading)
            make.trailing.equalTo(walletNameLabel.snp.trailing)
        }
        
        walletBalanceLabel.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        walletBalanceLabel.textColor = .black
        walletBalanceLabel.text = "0.00"
        walletBalanceLabel.textAlignment = .right
        walletBackgroundView.addSubview(walletBalanceLabel)
        walletBalanceLabel.snp.makeConstraints { make in
            make.top.equalTo(walletNameLabel)
            make.leading.equalTo(walletNameLabel.snp.trailing).offset(5)
            make.trailing.equalToSuperview().offset(-10)
        }
        
        recordStatusLabel.font = .systemFont(ofSize: 11)
        recordStatusLabel.textColor = .black
        recordStatusLabel.text = "--"
        recordStatusLabel.textAlignment = .right
        walletBackgroundView.addSubview(recordStatusLabel)
        recordStatusLabel.snp.makeConstraints { make in
            make.top.equalTo(walletNameLabel.snp.bottom).offset(6)
            make.leading.trailing.equalTo(walletBalanceLabel)
        }
        
        let delegateBackgroundView = UIView()
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
        
        toAddressView.setTitleColor(common_lightLightGray_color, for: .normal)
        toAddressView.setImage(UIImage(named: "walletAvatar_1_s"), for: .normal)
        toAddressView.titleLabel?.font = .systemFont(ofSize: 15)
        toAddressView.setTitle("--", for: .normal)
        toAddressView.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        toAddressView.contentHorizontalAlignment = .left
        delegateBackgroundView.addSubview(toAddressView)
        toAddressView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
            make.width.equalToSuperview().offset(-10).dividedBy(2)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
