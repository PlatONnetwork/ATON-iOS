//
//  MnemonicGridView.swift
//  platonWallet
//
//  Created by Ned on 7/3/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import UIKit

protocol MnemonicGridViewDelegate : AnyObject {
    func onTextFieldSelected(index: Int,word: String)
}

class MnemonicGridView: UIView,UITextFieldDelegate {

    weak var delegate: MnemonicGridViewDelegate?

    override func awakeFromNib() {
        for textField in self.getTextFields() {
            textField.delegate = self
        }
    }

    func setDisableEditStyle() {
        for item in self.getTextFields() {
            //item.isUserInteractionEnabled = false
            let button = UIButton(type: .custom)
            button.backgroundColor = .clear
            button.tag = item.tag
            item.addSubview(button)
            button.snp.makeConstraints { (make) in
                make.edges.equalTo(item)
            }
            button.addTarget(self, action: #selector(onItemPress), for: .touchUpInside)
        }
    }

    func getTextFields() -> [UITextField] {
        let textFields = self.subviews.filter({$0.isKind(of: UITextField.self)}).sorted { (view1, view2) -> Bool in
            return view1.tag < view2.tag
            } as? [UITextField]

        return textFields!
    }

    func getTextField(index: Int) -> UITextField {
        let textFields = self.getTextFields()
        return (textFields[index])
    }

    func nonEmptyCount() -> Int {
        var textFields = self.subviews.filter({$0.isKind(of: UITextField.self)}).sorted { (view1, view2) -> Bool in
            return view1.tag < view2.tag
            } as? [UITextField]
        textFields = textFields?.filter({$0.text?.length ?? 0 > 0})
        return textFields?.count ?? 0
    }

    func getMnemonic() -> String {
        var textFields = self.subviews.filter({$0.isKind(of: UITextField.self)}).sorted { (view1, view2) -> Bool in
            return view1.tag < view2.tag
            } as? [UITextField]
        textFields = textFields?.filter({$0.text?.length ?? 0 > 0})
        let initialResult = ""
        let mnemonic =  textFields?.reduce(initialResult, { (tmp, textField) -> String in
            let inputtext = textField.text ?? ""
            let trimWhiteSpace = inputtext.replacingOccurrences(of: " ", with: "")
            return tmp + " " + (trimWhiteSpace)
        })
        if (mnemonic?.hasPrefix(" "))! {
            return (mnemonic?.trimmingCharacters(in: .whitespaces))!
        }
        return mnemonic ?? ""
    }

    func setMnemonic(mnemonic: String) {
        let mneArray = mnemonic.split(separator: " ").map({return String($0)})
        let textFields = self.getTextFields()
        _ = textFields.enumerated().map { (offset, element)in
            element.text = mneArray[offset]
        }
    }

    func setTextAtIndex(index: Int, text: String) {
        guard index < self.getTextFields().count else {
            return
        }
        self.getTextField(index: index).text = text
    }

    func removeAllContent() {
        let textFields = self.getTextFields()
        _ = textFields.map { view in
            view.text = ""
        }
    }

    func getFirstEmptyFieldIndex() -> Int {
        for item in self.getTextFields() {
            if item.text == nil || item.text?.length == 0 {
                return item.tag
            }
        }
        return self.getTextFields().count - 1
    }

    @objc func onItemPress(button: UIButton) {
        guard self.delegate != nil else {
            return
        }
        let textField = self.getTextField(index: button.tag)
        self.delegate?.onTextFieldSelected(index: button.tag, word: textField.text ?? "")
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == " "{
            if textField.tag < 11 {
                let nextTextField = self.getTextField(index: textField.tag + 1)
                DispatchQueue.main.async {
                    nextTextField.becomeFirstResponder()
                }
            } else {
                textField.resignFirstResponder()
            }
        }
        return true
    }

}
