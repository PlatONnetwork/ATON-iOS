//
//  TransactionDetailHashTableViewCell.swift
//  platonWallet
//
//  Created by Admin on 23/9/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit

class TransactionDetailHashTableViewCell: UITableViewCell {

    public let titleLabel = UILabel()
    public let valueLabel = UILabel()
    public let button = CopyButton()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview()
        }

        contentView.addSubview(valueLabel)
        valueLabel.snp.makeConstraints { make in
//            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(titleLabel)
            make.bottom.equalToSuperview().offset(-16)
            make.leading.equalTo(titleLabel.snp.trailing).offset(5)
        }

        button.attachTextView = valueLabel
        button.setImage(UIImage(named: "copyIcon"), for: .normal)
        contentView.addSubview(button)
        button.snp.makeConstraints { make in
            make.leading.equalTo(valueLabel.snp.trailing).offset(5)
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(valueLabel.snp.centerY)
            make.width.equalTo(16)
            make.height.equalTo(16)
        }

        titleLabel.textColor = common_darkGray_color
        titleLabel.font = .systemFont(ofSize: 14)

        valueLabel.textAlignment = .right
        valueLabel.numberOfLines = 0
        valueLabel.textColor = .black
        valueLabel.font = .systemFont(ofSize: 14)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
