//
//  NodeDetailCell.swift
//  platonWallet
//
//  Created by Admin on 3/1/2020.
//  Copyright © 2020 ju. All rights reserved.
//

import UIKit

class NodeDetailCell: UITableViewCell {

    let titleLabel = UILabel()
    let valueLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        titleLabel.font = .systemFont(ofSize: 15)
        titleLabel.textColor = common_lightLightGray_color
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-16)
        }

        valueLabel.font = .systemFont(ofSize: 15, weight: .medium)
        valueLabel.textColor = .black
        valueLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        valueLabel.setContentHuggingPriority(.required, for: .horizontal)
        contentView.addSubview(valueLabel)
        valueLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing)
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(titleLabel.snp.centerY)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
