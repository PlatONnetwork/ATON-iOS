//
//  NodeInfoTableViewCell.swift
//  platonWallet
//
//  Created by Admin on 29/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit

class NodeInfoTableViewCell: UITableViewCell {

    public let avatarIV = UIImageView()
    public let nameLabel = UILabel()
    public let addressLabel = UILabel()

    public var node: Node? {
        didSet {
            nameLabel.text = node?.name
            addressLabel.text = node?.nodeId?.nodeIdForDisplay()
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        contentView.backgroundColor = normal_background_color

        let containerView = UIButton()
        containerView.backgroundColor = .white
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(72)
        }

        avatarIV.addMaskView(corners: .allCorners, cornerRadiiV: 21)
        avatarIV.image = UIImage(named: "3.icon_default")
        containerView.addSubview(avatarIV)
        avatarIV.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(13)
            make.width.height.equalTo(42)
        }

        nameLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)
        nameLabel.textColor = .black
        nameLabel.text = "--"
        containerView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarIV.snp.top)
            make.leading.equalTo(avatarIV.snp.trailing).offset(5)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(18)
        }

        addressLabel.font = UIFont.systemFont(ofSize: 13)
        addressLabel.textColor = common_darkGray_color
        addressLabel.text = "--"
        containerView.addSubview(addressLabel)
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(3)
            make.leading.equalTo(nameLabel.snp.leading)
            make.trailing.equalTo(nameLabel.snp.trailing)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
