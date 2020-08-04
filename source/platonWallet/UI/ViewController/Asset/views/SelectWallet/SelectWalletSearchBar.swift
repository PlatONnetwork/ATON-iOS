//
//  SelectWalletSearchBar.swift
//  platonWallet
//
//  Created by juzix on 2020/7/20.
//  Copyright © 2020 ju. All rights reserved.
//

import UIKit
@_exported import Localize_Swift

class SelectWalletSearchBar: UIView {
    
    var hideButtonClickCallback: ((UIButton) -> Void)?
    var textFieldMainValueEditingCallback: ((String) -> Void)?
    fileprivate var mainTextField = UITextField()
    fileprivate var hideButton = UIButton(type: .custom)

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(mainTextField)
        addSubview(hideButton)
        hideButton.setTitle(Localized("Wallet_selecting_hideSearchBar"), for: .normal)
        hideButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        hideButton.setTitleColor(UIColor(hex: "105CFE"), for: .normal)
        hideButton.addTarget(self, action: #selector(hideButtonClick(sender:)), for: .touchUpInside)
        hideButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.right.equalTo(-10)
            make.height.equalTo(20)
            make.width.greaterThanOrEqualTo(30)
        }
        mainTextField.placeholder = Localized("Wallet_searchBarPlaceHolder")
        mainTextField.font = UIFont.systemFont(ofSize: 13)
        mainTextField.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.centerY.equalTo(self)
            make.top.equalTo(8)
            make.right.equalTo(hideButton.snp.left).offset(-16)
        }
        mainTextField.addTarget(self, action: #selector(mainTextFieldTextChange(textField:)), for: .editingChanged)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.bounds.size.height / 2.0
        self.layer.borderColor = UIColor(hex: "105CFE").cgColor
        self.layer.borderWidth = 1
    }
    
    // MARK: Events
    
    @objc func hideButtonClick(sender: UIButton) {
        guard let callback = self.hideButtonClickCallback else {
            return
        }
        self.mainTextField.text = ""
        callback(sender)
    }

    @objc func mainTextFieldTextChange(textField: UITextField) {
        print("textField Value:", textField.text ?? "")
        guard let callback = textFieldMainValueEditingCallback else { return }
        callback(textField.text ?? "")
    }
}
