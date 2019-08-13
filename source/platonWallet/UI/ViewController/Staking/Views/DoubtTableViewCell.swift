//
//  DoubtTableViewCell.swift
//  platonWallet
//
//  Created by Admin on 29/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit

class DoubtTableViewCell: UITableViewCell {
    
    public let titleLabel = UILabel()
    public let contentLabel = UILabel()
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = normal_background_color
        
        let lineV = UIView()
        lineV.backgroundColor = UIColor(rgb: 0x1B60F3)
        contentView.addSubview(lineV)
        lineV.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.top.equalToSuperview().offset(12)
            make.width.equalTo(2)
            make.height.equalTo(14)
        }
        
        
        titleLabel.textColor = .black
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(lineV.snp.trailing).offset(8)
            make.centerY.equalTo(lineV)
        }
        
        contentLabel.textColor = common_lightLightGray_color
        contentLabel.numberOfLines = 0
        contentLabel.font = .systemFont(ofSize: 14)
        contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.leading.equalTo(lineV)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(lineV.snp.bottom).offset(8)
            make.bottom.equalToSuperview().offset(-12)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
