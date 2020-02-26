//
//  NodeDetailFooterView.swift
//  platonWallet
//
//  Created by Admin on 3/1/2020.
//  Copyright © 2020 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class NodeDetailGroupCell: UITableViewCell {

    let institutionalLabel = UILabel()
    let websiteLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        let lineHV = UIView()
        lineHV.backgroundColor = UIColor(rgb: 0xE4E7F3)
        contentView.addSubview(lineHV)
        lineHV.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(1/UIScreen.main.scale)
            make.top.equalToSuperview()
        }

        let websiteTipLabel = UILabel()
        websiteTipLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        websiteTipLabel.setContentHuggingPriority(.required, for: .vertical)
        websiteTipLabel.text = Localized("statking_validator_Website")
        websiteTipLabel.textColor = common_darkGray_color
        websiteTipLabel.font = UIFont.systemFont(ofSize: 14)
        contentView.addSubview(websiteTipLabel)
        websiteTipLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(lineHV.snp.bottom).offset(16)
        }

        websiteLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        websiteLabel.setContentHuggingPriority(.required, for: .vertical)
        websiteLabel.isUserInteractionEnabled = true
        websiteLabel.textColor = common_blue_color
        websiteLabel.font = .systemFont(ofSize: 14)
        websiteLabel.numberOfLines = 0
        websiteLabel.text = "--"
        contentView.addSubview(websiteLabel)
        websiteLabel.snp.makeConstraints { make in
            make.leading.equalTo(websiteTipLabel)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(websiteTipLabel.snp.bottom).offset(10)
        }

        let institutionalTipLabel = UILabel()
        institutionalTipLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        institutionalTipLabel.setContentHuggingPriority(.required, for: .vertical)
        institutionalTipLabel.text = Localized("statking_validator_Institutional")
        institutionalTipLabel.textColor = common_darkGray_color
        institutionalTipLabel.font = UIFont.systemFont(ofSize: 14)
        contentView.addSubview(institutionalTipLabel)
        institutionalTipLabel.snp.makeConstraints { make in
            make.leading.equalTo(websiteLabel)
            make.top.equalTo(websiteLabel.snp.bottom).offset(16)
        }

        institutionalLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        institutionalLabel.setContentHuggingPriority(.required, for: .vertical)
        institutionalLabel.textColor = .black
        institutionalLabel.font = .systemFont(ofSize: 14)
        institutionalLabel.text = "--"
        institutionalLabel.numberOfLines = 0
        contentView.addSubview(institutionalLabel)
        institutionalLabel.snp.makeConstraints { make in
            make.leading.equalTo(institutionalTipLabel)
            make.top.equalTo(institutionalTipLabel.snp.bottom).offset(10)
            make.bottom.equalToSuperview().offset(-16)
            make.trailing.equalToSuperview().offset(-16)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
