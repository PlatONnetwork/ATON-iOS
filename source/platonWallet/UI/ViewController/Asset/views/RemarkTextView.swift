//
//  RemarkTextView.swift
//  platonWallet
//
//  Created by Admin on 28/2/2020.
//  Copyright © 2020 ju. All rights reserved.
//

import UIKit

class RemarkTextView: UIView {

    public let textField = UITextField()
    public let lineView = UIView()
    public let tipsLabel = UILabel()

    var maxTextCount: Int = 30

    var textFieldShouldReturnCompletion : ((_ textField: UITextField) -> (Bool))?

    var shouldChangeCharactersCompletion: ((_ concatenated: String, _ replacement: String) -> (Bool))?

    var endEditCompletion: ((_ string: String) -> Void)?

    private var actions:[() -> Void] = []

    var internalHeight: Float = 65.0

    var appendText = ""

    private var mode: TextFieldCheckMode = .endEdit

    private var check: ((String, Bool) -> (correct: Bool, errMsg: String))?

    private var heightChange: ((RemarkTextView) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        textField.textColor = .black
        textField.font = .systemFont(ofSize: 14)
        textField.delegate = self
        textField.textAlignment = .left
        textField.clearButtonMode = .always
        addSubview(textField)
        textField.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(40)
        }

        lineView.backgroundColor = UIColor(rgb: 0xd5d8df)
        addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.height.equalTo(1/UIScreen.main.scale)
            make.top.equalTo(textField.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }

        tipsLabel.textColor = UIColor(rgb: 0xf5302c)
        tipsLabel.font = .systemFont(ofSize: 11)
        tipsLabel.numberOfLines = 2
        addSubview(tipsLabel)
        tipsLabel.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(8)
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        NotificationCenter.default.addObserver(self, selector: #selector(textDidBeginEditing(_:)), name: UITextField.textDidBeginEditingNotification, object: nil)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func checkInput(mode: TextFieldCheckMode, check: @escaping ((String, Bool) -> (Bool, String)), heightChange: @escaping ((RemarkTextView) -> Void)) {
        self.mode = mode
        self.check = check
        self.heightChange = heightChange
    }

    public func checkInvalidNow(showErrorMsg: Bool) -> (correct: Bool, errMsg: String)? {
        if self.check == nil {
            assert(false, "Fatal Error:no check logic")
        }
        return startCheck(text: textField.text ?? "", isDelete: false, showErrorMsg: showErrorMsg)
    }

    public func cleanErrorState() {
        tipsLabel.text = ""
        lineView.backgroundColor = UIColor(rgb: 0xD5D8DF)
        internalHeight = 65.0
        tipsLabel.isHidden = true
        heightChange?(self)
    }

    private func startCheck(text: String, isDelete: Bool, showErrorMsg: Bool = true, isEditing: Bool = false) -> (correct: Bool, errMsg: String)? {
        guard check != nil else {
            return nil
        }

        // 校验数量是否符合
        let res = check!(text, isDelete)

        if !showErrorMsg {
            return res
        }
        if res.correct {
            self.setTextFieldStyle(style: isEditing ? .Editing : .Normal, notifyHeightChange: true)
        } else if !res.correct {
            tipsLabel.text = res.errMsg
            self.setTextFieldStyle(style: .Error, notifyHeightChange: true)
        }
        return res
    }

    func resetErrorState(errMsg: String) {
        tipsLabel.text = errMsg
        self.setTextFieldStyle(style: .Error, notifyHeightChange: false)
    }

    public enum TextFieldCheckMode {
        case endEdit
        case textChange
        case all
    }

}

extension RemarkTextView: UITextFieldDelegate {

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {

        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard self.endEditCompletion != nil else {
            return
        }

        self.endEditCompletion!(textField.text!)

        //check must be in the last
        if mode == .endEdit || mode == .all {
            _ = startCheck(text: textField.text ?? "", isDelete: false)
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if let text = textField.text, let textRange = Range(range, in: text) {
            let appendtext = text.replacingCharacters(in: textRange, with: string)
            if appendtext.count > maxTextCount {
                return false
            }
        }

        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard self.textFieldShouldReturnCompletion != nil else {
            return false
        }
        return self.textFieldShouldReturnCompletion!(textField)
    }

    // MARK: - TextField Notification
    @objc func textDidBeginEditing(_ notification: Notification) {
        if let theTextField = notification.object as? UITextField, theTextField == self.textField {
            self.setTextFieldStyle(style: .Editing, notifyHeightChange: true)
        }
    }

    func setTextFieldStyle(style: TextFiledStyle, notifyHeightChange: Bool = false, isEditing: Bool = false) {
        if style == TextFiledStyle.Editing {
            internalHeight = 65.0
            tipsLabel.isHidden = true
            lineView.backgroundColor = bottomLineEditingColor
        } else if style == TextFiledStyle.Normal {
            internalHeight = 65.0
            tipsLabel.isHidden = true
            lineView.backgroundColor = bottomLineNormalColor
        } else if style == TextFiledStyle.Error {
            tipsLabel.isHidden = false
            lineView.backgroundColor = bottomLineErrorColor
            internalHeight = 90.0
        }

        if notifyHeightChange {
            heightChange?(self)
        }
    }

}
