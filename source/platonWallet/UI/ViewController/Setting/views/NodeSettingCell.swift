//
//  NodeSettingCell.swift
//  platonWallet
//
//  Created by Admin on 25/11/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class NodeSettingCell: UITableViewCell {

    let titleLabel = UILabel()
    let sublabel = UILabel()
    let selectionImgV = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        titleLabel.textColor = .black
        titleLabel.font = .boldSystemFont(ofSize: 14)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(20)
        }

        sublabel.textColor = UIColor(rgb: 0x898c9e)
        sublabel.font = .systemFont(ofSize: 13)
        addSubview(sublabel)
        sublabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.bottom.equalToSuperview().offset(-20)
        }

        selectionImgV.image = UIImage(named: "memberIconConfirm")
        addSubview(selectionImgV)
        selectionImgV.snp.makeConstraints { make in
            make.width.height.equalTo(19)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-16)
        }

        let lineIV = UIImageView()
        lineIV.backgroundColor = UIColor(rgb: 0xE4E7F3)
        addSubview(lineIV)
        lineIV.snp.makeConstraints { make in
            make.height.equalTo(1/UIScreen.main.scale)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(nodeName: String, nodeUrl: String, isSelected: Bool, chainId: String) {
        selectionImgV.isHidden = !isSelected
        titleLabel.text = nodeName
        sublabel.text = nodeUrl + "(chainId:" + chainId + ")"
    }

}
