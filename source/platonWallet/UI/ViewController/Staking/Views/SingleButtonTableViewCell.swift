//
//  SingleButtonTableViewCell.swift
//  platonWallet
//
//  Created by Admin on 29/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import SnapKit

class SingleButtonTableViewCell: UITableViewCell {

    public let button = PButton()
    public let errorLabel = UILabel()

    var canDelegation: CanDelegation? {
        didSet {
            if let canDel = canDelegation, canDel.canDelegation == true {
                buttonToBottomConstaint?.update(priority: .high)
                errorLabelToBottomConstaint?.update(priority: .medium)

                errorLabel.isHidden = true
                errorLabel.attributedText = nil
                button.style = disableTapAction == true ? .disable : .blue
            } else {
                buttonToBottomConstaint?.update(priority: .medium)
                errorLabelToBottomConstaint?.update(priority: .high)

                errorLabel.isHidden = false

                if let localizedDesciption = canDelegation?.message?.localizedDesciption {
                    let attachment = NSTextAttachment()
                    attachment.bounds = CGRect(x: 0, y: 0, width: 10, height: 10)
                    attachment.image = UIImage(named: "3.icon_warning")

                    let attr = NSMutableAttributedString()
                    attr.append(NSAttributedString(attachment: attachment))
                    attr.append(NSAttributedString(string: " "))
                    attr.append(NSAttributedString(string: localizedDesciption))

                    errorLabel.attributedText = attr
                }

                button.style = .disable
            }
        }
    }

    var buttonToBottomConstaint: Constraint?
    var errorLabelToBottomConstaint: Constraint?

    public var disableTapAction: Bool = false {
        didSet {
            if disableTapAction {
                button.style = .disable
            } else {
                button.style = .blue
            }
        }
    }

    var cellDidTapHandle: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = normal_background_color

        button.frame = CGRect(x: 16, y: 16, width: UIScreen.main.bounds.width - 32, height: 44)
        button.addTarget(self, action: #selector(tapAction), for: .touchUpInside)
        contentView.addSubview(button)
        button.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            buttonToBottomConstaint = make.bottom.equalToSuperview().offset(-16).priorityHigh().constraint
            make.centerX.equalToSuperview()
            make.height.equalTo(44)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }

        errorLabel.font = .systemFont(ofSize: 14)
        errorLabel.textColor = UIColor(rgb: 0xff6b00)
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        contentView.addSubview(errorLabel)
        errorLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(button)
            make.top.equalTo(button.snp.bottom).offset(15)
            errorLabelToBottomConstaint = make.bottom.equalToSuperview().offset(-15).priorityMedium().constraint
        }

        button.style = .blue
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func tapAction() {
        cellDidTapHandle?()
    }

}
