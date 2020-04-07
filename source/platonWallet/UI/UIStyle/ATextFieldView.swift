//
//  ATextFieldView.swift
//  platonWallet
//
//  Created by Admin on 29/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import Localize_Swift
import SnapKit
import BigInt

class ATextFieldView: UIView {

    public let titleLabel = UILabel()
    public let magnitudeLabel = UILabel()
    public let textField = UITextField()
    public let lineView = UIView()
    public let tipsLabel = UILabel()
    private let tipLabelLeadingV = UIView()
    public let feeLabel = UILabel()

    var textFieldShouldReturnCompletion : ((_ textField: UITextField) -> (Bool))?

    var shouldChangeCharactersCompletion: ((_ concatenated: String, _ replacement: String) -> (Bool))?

    var endEditCompletion: ((_ string: String) -> Void)?

    private var actions:[() -> Void] = []

    var internalHeight: Float = 65.0

    var appendText = ""

    var isValidUInt: Bool = false
    var maxBinUIntValue: BigUInt?

    var isValidMagitude: Bool = true

    private var mode: TextFieldCheckMode = .endEdit

    private var check: ((String, Bool) -> (correct: Bool, errMsg: String))?

    private var heightChange: ((ATextFieldView) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        titleLabel.textColor = common_darkGray_color
        titleLabel.font = .systemFont(ofSize: 16)
        titleLabel.text = Localized("ATextFieldView_title")
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
        }

        textField.textColor = .black
        textField.font = .systemFont(ofSize: 14)
        textField.delegate = self
        textField.textAlignment = .left
        addSubview(textField)
        textField.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(7)
            make.trailing.equalToSuperview()
            make.height.equalTo(40)
        }

        magnitudeLabel.textColor = UIColor(rgb: 0x8c8c8c)
        magnitudeLabel.font = .systemFont(ofSize: 12)
        magnitudeLabel.text = ""
        addSubview(magnitudeLabel)
        magnitudeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.bottom.equalTo(textField.snp.top).offset(8)
        }

        tipLabelLeadingV.backgroundColor = UIColor(rgb: 0x1B60F3)
        tipLabelLeadingV.isHidden = true
        addSubview(tipLabelLeadingV)
        tipLabelLeadingV.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.width.equalTo(1)
            make.height.equalTo(7)
            make.centerY.equalTo(magnitudeLabel)
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

        feeLabel.textColor = common_darkGray_color
        feeLabel.font = .systemFont(ofSize: 13)
        feeLabel.textAlignment = .right
        feeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        addSubview(feeLabel)
        feeLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.equalTo(textField.snp.bottom).offset(8)
            make.leading.equalTo(tipsLabel.snp.trailing).offset(5)
            make.bottom.equalToSuperview()
        }

        NotificationCenter.default.addObserver(self, selector: #selector(textDidBeginEditing(_:)), name: UITextField.textDidBeginEditingNotification, object: nil)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    class func create(title: String) -> ATextFieldView {
        let textFieldView = ATextFieldView()
        textFieldView.titleLabel.localizedText = title
        return textFieldView
    }

    func addAction(title: String? = nil, icon: UIImage? = nil, action: @escaping (() -> Void)) {

        let btn = UIButton(type: .custom)
        if title != nil {
            btn.localizedNormalTitle = title
            btn.setTitleColor(common_blue_color, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        }
        if icon != nil {
            btn.setImage(icon, for: .normal)
            btn.imageView?.contentMode = .center
        }

        btn.tag = 100 + actions.count
        btn.addTarget(self, action: #selector(action(_:)), for: .touchUpInside)
        btn.setContentCompressionResistancePriority(.required, for: .horizontal)
        btn.setContentHuggingPriority(.required, for: .horizontal)
        addSubview(btn)

        var lastButton = viewWithTag(100 + actions.count - 1)
        btn.snp.makeConstraints { make in
            make.height.equalTo(40)
            if let view = lastButton {
                make.trailing.equalTo(view.snp.leading)
            } else {
                make.trailing.equalToSuperview()
            }

            make.centerY.equalTo(textField)
        }

        actions.append(action)

        lastButton = viewWithTag(100 + actions.count - 1)
        textField.snp.remakeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(7)
            if let view = lastButton {
                make.trailing.equalTo(view.snp.leading).offset(-12)
            } else {
                make.trailing.equalToSuperview()
            }
            make.height.equalTo(40)
        }

        layoutIfNeeded()
    }

    func checkInput(mode: TextFieldCheckMode, check: @escaping ((String, Bool) -> (Bool, String)), heightChange: @escaping ((ATextFieldView) -> Void)) {
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
        magnitudeLabel.text = nil
        tipLabelLeadingV.isHidden = true
    }

    @objc private func action(_ sender: UIButton) {
        actions[sender.tag - 100]()
    }

    private func startCheck(text: String, isDelete: Bool, showErrorMsg: Bool = true, isEditing: Bool = false) -> (correct: Bool, errMsg: String)? {
        guard check != nil else {
            return nil
        }

//        guard text.count > 0 else {
//            return nil
//        }

        // 展示数量级
        if isValidMagitude {
            let magnitude = text.inputAmountForMagnitude()
            magnitudeLabel.text = magnitude
            tipLabelLeadingV.isHidden = magnitude == nil
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

extension ATextFieldView: UITextFieldDelegate {

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
        if string != "" {
            if isValidUInt {
                if !string.isPureInt() {
                    return false
                }
            } else {
                if !string.validFloatNumber() {
                    return false
                }
            }

            if let text = textField.text, let textRange = Range(range, in: text) {
                let appendtext = text.replacingCharacters(in: textRange, with: string)
                if !appendtext.trimNumberLeadingZero().isValidInputAmoutWith8DecimalPlace() {
                    return false
                }
            }
        }

        if mode == .textChange || mode == .all {
            if let text = textField.text, let textRange = Range(range, in: text) {
                let appendtext = text.replacingCharacters(in: textRange, with: string)
                if let maxBInt = maxBinUIntValue, let inputBInt = BigUInt(appendtext) {
                    if inputBInt > maxBInt {
                        return false
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    _ = self.startCheck(text: appendtext, isDelete: string == "", isEditing: true)
                }
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
