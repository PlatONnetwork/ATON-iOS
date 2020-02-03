//
//  NodeDetailFooterView.swift
//  platonWallet
//
//  Created by Admin on 3/1/2020.
//  Copyright © 2020 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class NodeDetailFooterView: UIView {

    let institutionalLabel = UILabel()
    let websiteLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        let lineHV = UIView()
        lineHV.backgroundColor = UIColor(rgb: 0xE4E7F3)
        addSubview(lineHV)
        lineHV.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(1/UIScreen.main.scale)
            make.top.equalToSuperview()
        }

        let websiteTipLabel = UILabel()
        websiteTipLabel.text = Localized("statking_validator_Website")
        websiteTipLabel.textColor = common_darkGray_color
        websiteTipLabel.font = UIFont.systemFont(ofSize: 14)
        addSubview(websiteTipLabel)
        websiteTipLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(lineHV.snp.bottom).offset(16)
        }

        websiteLabel.isUserInteractionEnabled = true
        websiteLabel.textColor = common_blue_color
        websiteLabel.font = .systemFont(ofSize: 14)
        websiteLabel.text = "--"
        addSubview(websiteLabel)
        websiteLabel.snp.makeConstraints { make in
            make.leading.equalTo(websiteTipLabel)
            make.top.equalTo(websiteTipLabel.snp.bottom).offset(10)
        }

        let institutionalTipLabel = UILabel()
        institutionalTipLabel.text = Localized("statking_validator_Institutional")
        institutionalTipLabel.textColor = common_darkGray_color
        institutionalTipLabel.font = UIFont.systemFont(ofSize: 14)
        addSubview(institutionalTipLabel)
        institutionalTipLabel.snp.makeConstraints { make in
            make.leading.equalTo(websiteLabel)
            make.top.equalTo(websiteLabel.snp.bottom).offset(16)
        }

        institutionalLabel.textColor = .black
        institutionalLabel.font = .systemFont(ofSize: 14)
        institutionalLabel.text = "--"
        addSubview(institutionalLabel)
        institutionalLabel.snp.makeConstraints { make in
            make.leading.equalTo(institutionalTipLabel)
            make.top.equalTo(institutionalTipLabel.snp.bottom).offset(10)
            make.bottom.equalToSuperview().offset(-16)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
