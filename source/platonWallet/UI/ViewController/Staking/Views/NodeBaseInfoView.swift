//
//  NodeBaseInfoView.swift
//  platonWallet
//
//  Created by Admin on 29/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class NodeBaseInfoView: UIView {

    public let nodeAvatarIV = UIImageView()
    public let nodeNameLabel = UILabel()
    public let nodeAddressLabel = UILabel()
    public let statusButton = UIButton()
    public let rateLabel = UILabel()
    
    
    public let totalStakedLabel = UILabel()
    public let delegationsLabel = UILabel()
    public let delegatorsLabel = UILabel()
    public let slashLabel = UILabel()
    public let blocksLabel = UILabel()
    public let blocksRateLabel = UILabel()
    public let nodeNameButton = UIButton()
    
    var nodeLinkHandler: ((_ url: String) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        let nodeBackgroundView = UIImageView()
        nodeBackgroundView.image = UIImage(named: "bg_staking_wallet_img")?.resizableImage(withCapInsets: UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3))
        addSubview(nodeBackgroundView)
        nodeBackgroundView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(60)
        }
        
        nodeAvatarIV.addMaskView(corners: .allCorners, cornerRadiiV: 21)
        nodeAvatarIV.image = UIImage(named: "walletAvatar_1")
        nodeBackgroundView.addSubview(nodeAvatarIV)
        nodeAvatarIV.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(5)
            make.width.height.equalTo(42)
        }
        
        nodeNameLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)
        nodeNameLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        nodeNameLabel.textColor = .black
        nodeNameLabel.text = Localized("staking_main_wallet_name")
        addSubview(nodeNameLabel)
        nodeNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalTo(nodeAvatarIV.snp.trailing).offset(5)
            make.height.equalTo(18)
        }
        
        statusButton.setTitle("--", for: .normal)
        statusButton.setTitleColor(common_blue_color, for: .normal)
        statusButton.layer.cornerRadius = 3.0
        statusButton.layer.borderWidth = 1 / UIScreen.main.scale
        statusButton.titleLabel?.font = UIFont.systemFont(ofSize: 11)
        statusButton.layer.borderColor = status_blue_color.cgColor
        statusButton.contentEdgeInsets = UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)
        statusButton.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
        addSubview(statusButton)
        statusButton.snp.makeConstraints { make in
            make.leading.equalTo(nodeNameLabel.snp.trailing).offset(4)
            make.centerY.equalTo(nodeNameLabel)
        }
        
        
        nodeNameButton.setImage(UIImage(named: "3.icon_link"), for: .normal)
        addSubview(nodeNameButton)
        nodeNameButton.snp.makeConstraints { make in
            make.leading.equalTo(statusButton.snp.trailing).offset(6)
            make.height.equalTo(16)
            make.centerY.equalTo(nodeNameLabel)
        }
        
        nodeAddressLabel.font = UIFont.systemFont(ofSize: 13)
        nodeAddressLabel.textColor = common_darkGray_color
        nodeAddressLabel.text = "--"
        addSubview(nodeAddressLabel)
        nodeAddressLabel.snp.makeConstraints { make in
            make.top.equalTo(nodeNameLabel.snp.bottom).offset(3)
            make.leading.equalTo(nodeNameLabel.snp.leading)
        }
        
        rateLabel.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.medium)
        rateLabel.textColor = common_blue_color
        rateLabel.text = "0.00%"
        rateLabel.textAlignment = .right
        rateLabel.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
        addSubview(rateLabel)
        rateLabel.snp.makeConstraints { make in
            make.top.equalTo(nodeNameLabel)
            make.leading.greaterThanOrEqualTo(statusButton.snp.trailing).offset(5)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        let rateTitleLabel = UILabel()
        rateTitleLabel.font = .systemFont(ofSize: 11)
        rateTitleLabel.textColor = common_lightLightGray_color
        rateTitleLabel.text = Localized("staking_validator_delegate_rate_about")
        addSubview(rateTitleLabel)
        rateTitleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(rateLabel)
            make.top.equalTo(rateLabel.snp.bottom).offset(4)
            make.leading.equalTo(nodeAddressLabel.snp.trailing)
        }
        
        let delegateBackgroundView = UIView()
        delegateBackgroundView.backgroundColor = .white
        addSubview(delegateBackgroundView)
        delegateBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(nodeBackgroundView.snp.bottom)
            make.leading.trailing.equalTo(nodeBackgroundView)
            make.bottom.equalToSuperview()
        }
        
        let totalStakedTipLabel = UILabel()
        totalStakedTipLabel.text = Localized("statking_validator_total_staked")
        totalStakedTipLabel.textColor = common_lightLightGray_color
        totalStakedTipLabel.font = UIFont.systemFont(ofSize: 12)
        delegateBackgroundView.addSubview(totalStakedTipLabel)
        totalStakedTipLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(14)
            make.height.equalTo(14)
            make.width.equalToSuperview().offset(-24).dividedBy(2)
        }
        
        totalStakedLabel.textColor = .black
        totalStakedLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        totalStakedLabel.text = "--"
        delegateBackgroundView.addSubview(totalStakedLabel)
        totalStakedLabel.snp.makeConstraints { make in
            make.leading.equalTo(totalStakedTipLabel)
            make.top.equalTo(totalStakedTipLabel.snp.bottom).offset(9)
            make.width.equalTo(totalStakedTipLabel.snp.width)
            make.height.equalTo(14)
        }
        
        let delegationsTipLabel = UILabel()
        delegationsTipLabel.text = Localized("statking_validator_delegations")
        delegationsTipLabel.textColor = common_lightLightGray_color
        delegationsTipLabel.font = UIFont.systemFont(ofSize: 12)
        delegateBackgroundView.addSubview(delegationsTipLabel)
        delegationsTipLabel.snp.makeConstraints { make in
            make.leading.equalTo(totalStakedTipLabel.snp.trailing)
            make.top.equalTo(totalStakedTipLabel.snp.top)
            make.width.equalTo(totalStakedTipLabel)
        }
        
        delegationsLabel.textColor = .black
        delegationsLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        delegationsLabel.text = "--"
        delegateBackgroundView.addSubview(delegationsLabel)
        delegationsLabel.snp.makeConstraints { make in
            make.leading.equalTo(delegationsTipLabel)
            make.top.equalTo(delegationsTipLabel.snp.bottom).offset(9)
            make.width.equalTo(delegationsTipLabel.snp.width)
            make.height.equalTo(14)
        }
        
        let delegatorsTipLabel = UILabel()
        delegatorsTipLabel.text = Localized("statking_validator_delegators")
        delegatorsTipLabel.textColor = common_lightLightGray_color
        delegatorsTipLabel.font = UIFont.systemFont(ofSize: 12)
        delegateBackgroundView.addSubview(delegatorsTipLabel)
        delegatorsTipLabel.snp.makeConstraints { make in
            make.leading.equalTo(totalStakedLabel)
            make.top.equalTo(totalStakedLabel.snp.bottom).offset(15)
            make.height.equalTo(14)
            make.width.equalTo(totalStakedTipLabel)
        }
        
        delegatorsLabel.textColor = .black
        delegatorsLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        delegatorsLabel.text = "--"
        delegateBackgroundView.addSubview(delegatorsLabel)
        delegatorsLabel.snp.makeConstraints { make in
            make.leading.equalTo(delegatorsTipLabel)
            make.top.equalTo(delegatorsTipLabel.snp.bottom).offset(9)
            make.height.equalTo(14)
            make.width.equalTo(delegatorsTipLabel.snp.width)
        }
        
        let slashTipLabel = UILabel()
        slashTipLabel.text = Localized("statking_validator_slash")
        slashTipLabel.textColor = common_lightLightGray_color
        slashTipLabel.font = UIFont.systemFont(ofSize: 12)
        delegateBackgroundView.addSubview(slashTipLabel)
        slashTipLabel.snp.makeConstraints { make in
            make.leading.equalTo(delegatorsTipLabel.snp.trailing)
            make.top.equalTo(delegatorsTipLabel.snp.top)
            make.width.equalTo(delegatorsTipLabel)
        }
        
        slashLabel.textColor = .black
        slashLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        slashLabel.text = "--"
        delegateBackgroundView.addSubview(slashLabel)
        slashLabel.snp.makeConstraints { make in
            make.leading.equalTo(slashTipLabel)
            make.top.equalTo(slashTipLabel.snp.bottom).offset(9)
            make.height.equalTo(14)
            make.width.equalTo(slashTipLabel.snp.width)
        }
        
        let blocksTipLabel = UILabel()
        blocksTipLabel.text = Localized("statking_validator_blocks")
        blocksTipLabel.textColor = common_lightLightGray_color
        blocksTipLabel.font = UIFont.systemFont(ofSize: 12)
        delegateBackgroundView.addSubview(blocksTipLabel)
        blocksTipLabel.snp.makeConstraints { make in
            make.leading.equalTo(delegatorsLabel)
            make.top.equalTo(delegatorsLabel.snp.bottom).offset(15)
            make.height.equalTo(14)
            make.width.equalTo(delegatorsTipLabel)
        }
        
        blocksLabel.textColor = .black
        blocksLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        blocksLabel.text = "--"
        delegateBackgroundView.addSubview(blocksLabel)
        blocksLabel.snp.makeConstraints { make in
            make.leading.equalTo(blocksTipLabel)
            make.top.equalTo(blocksTipLabel.snp.bottom).offset(9)
            make.height.equalTo(14)
            make.width.equalTo(blocksTipLabel.snp.width)
        }
        
        let blocksRateTipLabel = UILabel()
        blocksRateTipLabel.text = Localized("statking_validator_blocks_rate")
        blocksRateTipLabel.textColor = common_lightLightGray_color
        blocksRateTipLabel.font = UIFont.systemFont(ofSize: 12)
        delegateBackgroundView.addSubview(blocksRateTipLabel)
        blocksRateTipLabel.snp.makeConstraints { make in
            make.leading.equalTo(blocksTipLabel.snp.trailing)
            make.top.equalTo(blocksTipLabel.snp.top)
            make.width.equalTo(blocksTipLabel)
        }
        
        blocksRateLabel.textColor = .black
        blocksRateLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        blocksRateLabel.text = "--"
        delegateBackgroundView.addSubview(blocksRateLabel)
        blocksRateLabel.snp.makeConstraints { make in
            make.leading.equalTo(blocksRateTipLabel)
            make.top.equalTo(blocksRateTipLabel.snp.bottom).offset(9)
            make.height.equalTo(14)
            make.width.equalTo(blocksRateTipLabel.snp.width)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
