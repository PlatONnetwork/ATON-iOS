//
//  SelectWalletTCell.swift
//  platonWallet
//
//  Created by juzix on 2020/7/20.
//  Copyright © 2020 ju. All rights reserved.
//

import UIKit

class SelectWalletTCell: UITableViewCell {

    var wallet: Wallet? {
        didSet {
            titleLabel.text = wallet?.name
            addrLabel.text = wallet?.address.addressForDisplayBech32()
        }
    }
    fileprivate let contentBackView = UIView()
    fileprivate let titleLabel = UILabel()
    fileprivate let addrLabel = UILabel()
    
    var isChoosed: Bool = false {
        didSet {
            if isChoosed == true {
                contentBackView.layer.borderColor = UIColor(hex: "105CFE").cgColor
            } else {
                contentBackView.layer.borderColor = UIColor.white.cgColor
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        contentView.backgroundColor = UIColor(hex: "F9FBFF")

        contentView.addSubview(contentBackView)
        contentBackView.backgroundColor = .white
        contentBackView.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(5)
            make.bottom.equalTo(-5)
        }
        contentBackView.layer.masksToBounds = true
        contentBackView.layer.borderWidth = 1
        
        contentBackView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(10)
            make.top.equalTo(10)
        }
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)

        contentBackView.addSubview(addrLabel)
        addrLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(10)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.right.equalTo(-10)
            make.bottom.equalTo(contentBackView.snp.bottom).offset(-10)
        }
        addrLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        addrLabel.numberOfLines = 1

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
