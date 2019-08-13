//
//  CommunityNameTableViewCell.swift
//  platonWallet
//
//  Created by Admin on 31/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit

class CommunityNameTableViewCell: UITableViewCell {

    public let avatarIV = UIImageView()
    public let nameLabel = UILabel()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        avatarIV.addMaskView(corners: .allCorners, cornerRadiiV: 15)
        contentView.addSubview(avatarIV)
        avatarIV.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(16)
            make.height.equalTo(30)
            make.width.equalTo(30)
        }
        
        nameLabel.textColor = .black
        nameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarIV.snp.trailing).offset(10)
            make.centerY.equalTo(avatarIV)
            make.trailing.equalToSuperview().offset(-16)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
