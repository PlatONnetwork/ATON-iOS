//
//  CommunityContentTableViewCell.swift
//  platonWallet
//
//  Created by Admin on 31/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import SnapKit

class CommunityContentTableViewCell: UITableViewCell {

    public let contentLabel = UILabel()
    public let copyButton = UIButton()
    public let rightButton = UIButton()
    public let lineView = UIView()
    public let qrcodeIV = UIImageView()
    public var lineLeadingConstraint: Constraint?
    public var qrcodeBottomConstraint: Constraint?
    
    var cellDidCopyHandle: ((_ content: String?) -> Void)?
    var cellDidRightHandle: (() -> Void)?
    
    var contact: CommunityContactStyle? {
        didSet {
            contentLabel.text = contact?.contact
            rightButton.setImage(UIImage(named: contact?.action == .scan ? "4.icon-Qr code" : "4.icon-jump"), for: .normal)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        contentLabel.textColor = common_darkGray_color
        contentLabel.font = .systemFont(ofSize: 13)
        contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(56)
            make.top.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-16).priorityMedium()
        }
        
        copyButton.setImage(UIImage(named: "4.icon-copy"), for: .normal)
        copyButton.addTarget(self, action: #selector(copyTapAction), for: .touchUpInside)
        contentView.addSubview(copyButton)
        copyButton.snp.makeConstraints { make in
            make.width.height.equalTo(34)
            make.leading.equalTo(contentLabel.snp.trailing).offset(5)
            make.centerY.equalTo(contentLabel)
        }
        
        rightButton.setImage(UIImage(named: "4.icon-jump"), for: .normal)
        rightButton.addTarget(self, action: #selector(rightTapAction(_:)), for: .touchUpInside)
        contentView.addSubview(rightButton)
        rightButton.snp.makeConstraints { make in
            make.width.height.equalTo(34)
            make.centerY.equalTo(copyButton)
            make.trailing.equalToSuperview().offset(-10)
            make.leading.equalTo(copyButton.snp.trailing)
        }
        
        qrcodeIV.backgroundColor = .red
        contentView.addSubview(qrcodeIV)
        qrcodeIV.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(contentLabel.snp.bottom).offset(16)
            make.height.width.equalTo(120)
            qrcodeBottomConstraint = make.bottom.equalToSuperview().offset(-16).priorityHigh().constraint
        }
        
        lineView.backgroundColor = UIColor(rgb: 0xE4E7F3)
        contentView.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.height.equalTo(1/UIScreen.main.scale)
            lineLeadingConstraint = make.leading.equalTo(contentLabel).priorityHigh().constraint
            make.leading.equalToSuperview().priorityMedium()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        
        qrcodeBottomConstraint?.deactivate()
        lineLeadingConstraint?.deactivate()
        
        qrcodeIV.isHidden = !(qrcodeBottomConstraint?.isActive ?? false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func copyTapAction() {
        cellDidCopyHandle?(contentLabel.text)
    }
    
    @objc func rightTapAction(_ sender: UIButton) {
        if contact?.action == .scan {
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                qrcodeBottomConstraint?.activate()
            } else {
                qrcodeBottomConstraint?.deactivate()
            }
        }
        cellDidRightHandle?()
    }

}
