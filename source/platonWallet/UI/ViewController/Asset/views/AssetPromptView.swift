//
//  AssetPromptView.swift
//  platonWallet
//
//  Created by Admin on 30/3/2020.
//  Copyright © 2020 ju. All rights reserved.
//

import UIKit

enum AssetPromptType {
    case backup
    case offline
    case notConnect

    var title: String {
        switch self {
        case .backup:
            return "asset_prompt_backup_title"
        case .offline:
            return "asset_prompt_offline_title"
        case .notConnect:
            return "asset_prompt_notConnect_title"
        }
    }

    var description: String {
        switch self {
        case .backup:
            return "asset_prompt_backup_description"
        case .offline:
            return "asset_prompt_offline_description"
        case .notConnect:
            return "asset_prompt_notConnect_description"
        }
    }

    var buttonText: String {
        switch self {
        case .backup:
            return "asset_prompt_backup_button"
        case .offline:
            return "asset_prompt_offline_button"
        case .notConnect:
            return "asset_prompt_notConnect_button"
        }
    }

    var backgroundColor: UIColor {
        switch self {
        case .backup:
            return UIColor(rgb: 0xEFF4FD)
        case .offline:
            return UIColor(rgb: 0xEFF4FD)
        case .notConnect:
            return UIColor(rgb: 0xFFE6D1)
        }
    }

    var descriptionColor: UIColor {
        switch self {
        case .backup,
             .offline:
            return UIColor.black
        case .notConnect:
            return common_darkGray_color
        }
    }

    var iconImage: UIImage? {
        switch self {
        case .backup,
             .offline:
            return UIImage(named: "1.icon_prompt")
        case .notConnect:
            return UIImage(named: "3.icon_warning")
        }
    }

    var isHideCloseButton: Bool {
        switch self {
        case .notConnect:
            return true
        default:
            return false
        }
    }
}

class AssetPromptView: UIView {

    let iconIV = UIImageView()
    let titleLabel = UILabel()
    let subTitleLabel = UILabel()
    let button = UIButton()
    let closeBtn = UIButton()
    var onComplete: (() -> Void)?

    convenience init(type: AssetPromptType, onComplete: (() -> Void)? = nil) {
        self.init(frame: .zero)
        self.onComplete = onComplete
        setupUI(type: type)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        initialUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func onPressed() {
        onComplete?()
    }

    @objc func onClosePressed() {
        dismiss()
    }

    func dismiss() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0.0
        }) { (_) in
//            self.removeFromSuperview()
            // 不能移除，防止干扰其他钱包的备份视图的显示和隐藏
            self.isHidden = true
            self.alpha = 1.0
        }
    }

    func setupUI(type: AssetPromptType) {
        backgroundColor = type.backgroundColor

        iconIV.image = type.iconImage
        titleLabel.localizedText = type.title
        subTitleLabel.localizedText = type.description
        subTitleLabel.textColor = type.descriptionColor
        button.localizedNormalTitle = type.buttonText
        closeBtn.isHidden = type.isHideCloseButton

        if type != .notConnect {
            iconIV.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(16)
                make.leading.equalToSuperview().offset(16)
            }

            titleLabel.snp.remakeConstraints { make in
                make.centerY.equalTo(iconIV.snp.centerY)
                make.leading.equalTo(iconIV.snp.trailing).offset(10)
            }

            subTitleLabel.snp.remakeConstraints { make in
                make.top.equalTo(iconIV.snp.bottom).offset(13)
                make.leading.equalToSuperview().offset(16)
                make.bottom.equalToSuperview().offset(-16)
            }

            button.snp.remakeConstraints { make in
                make.trailing.equalToSuperview().offset(-16)
                make.centerY.equalTo(subTitleLabel.snp.centerY)
                make.leading.equalTo(subTitleLabel.snp.trailing).offset(10)
                make.top.greaterThanOrEqualTo(closeBtn.snp.bottom).offset(5).priorityMedium()
                make.height.equalTo(34)
                make.bottom.equalToSuperview().offset(-16).priorityMedium()
            }
        }
    }

    func initialUI() {
        addSubview(iconIV)
        iconIV.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(16)
        }

        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .black
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalTo(iconIV.snp.trailing).offset(10)
        }

        subTitleLabel.font = .systemFont(ofSize: 13)
        subTitleLabel.numberOfLines = 0
        addSubview(subTitleLabel)
        subTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-9)
        }

        closeBtn.addTarget(self, action: #selector(onClosePressed), for: .touchUpInside)
        closeBtn.setImage(UIImage(named: "1.icon_shut down"), for: .normal)
        addSubview(closeBtn)
        closeBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(16)
        }

        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.backgroundColor = common_blue_color
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.contentEdgeInsets = UIEdgeInsets(top: 7, left: 16, bottom: 7, right: 16)
        button.addTarget(self, action: #selector(onPressed), for: .touchUpInside)
        button.layer.cornerRadius = 17
        addSubview(button)
        button.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.leading.lessThanOrEqualTo(subTitleLabel.snp.trailing).offset(10)
            make.height.equalTo(34)
        }
    }

}
