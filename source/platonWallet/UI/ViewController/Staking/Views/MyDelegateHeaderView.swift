//
//  MyDelegateHeaderView.swift
//  platonWallet
//
//  Created by Admin on 24/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class MyDelegateHeaderView: UIView {
    
    var recordButtonHandler: (() -> Void)?
    
    public let totalBalanceLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        let delegateAvatarIV = UIImageView()
        delegateAvatarIV.addMaskView(corners: .allCorners, cornerRadiiV: 21)
        delegateAvatarIV.image = UIImage(named: "3.icon_verifier")
        addSubview(delegateAvatarIV)
        delegateAvatarIV.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(13)
            make.width.height.equalTo(42)
        }
        
        let delegateNameTipLabel = UILabel()
        delegateNameTipLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)
        delegateNameTipLabel.textColor = .black
        delegateNameTipLabel.localizedText = "staking_main_delegate_total"
        addSubview(delegateNameTipLabel)
        delegateNameTipLabel.snp.makeConstraints { make in
            make.top.equalTo(delegateAvatarIV)
            make.leading.equalTo(delegateAvatarIV.snp.trailing).offset(3)
            make.height.equalTo(19)
        }
        
        totalBalanceLabel.font = UIFont.systemFont(ofSize: 14)
        totalBalanceLabel.textColor = common_darkGray_color
        totalBalanceLabel.text = "--"
        addSubview(totalBalanceLabel)
        totalBalanceLabel.snp.makeConstraints { make in
            make.top.equalTo(delegateNameTipLabel.snp.bottom).offset(7)
            make.leading.equalTo(delegateNameTipLabel.snp.leading)
            make.trailing.equalTo(delegateNameTipLabel.snp.trailing)
        }
        
        let recordButton = UIButton()
        recordButton.addTarget(self, action: #selector(recordTapAction), for: .touchUpInside)
        recordButton.localizedNormalTitle = "staking_main_delegate_record"
        recordButton.setTitleColor(common_blue_color, for: .normal)
        recordButton.setImage(UIImage(named: "3.icon_Record"), for: .normal)
        recordButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        recordButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        addSubview(recordButton)
        recordButton.snp.makeConstraints { make in
            make.top.equalTo(delegateAvatarIV)
            make.leading.greaterThanOrEqualTo(delegateNameTipLabel.snp.trailing).offset(5)
            make.trailing.equalToSuperview().offset(-16)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func recordTapAction() {
        recordButtonHandler?()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
