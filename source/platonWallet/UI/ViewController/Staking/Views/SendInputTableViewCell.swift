//
//  SendInputTableViewCell.swift
//  platonWallet
//
//  Created by Admin on 29/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import Localize_Swift
import BigInt

enum SendInputTableViewCellType {
    case delegate
    case withdraw
    case transfer
}

class SendInputTableViewCell: UITableViewCell {

    var cellDidContentChangeHandler: (() -> Void)?
    var cellDidContentEditingHandler: ((BigUInt, Bool) -> Void)?

    // 最少输入的数量
    var minAmountLimit: BigUInt?
    var maxAmountLimit: BigUInt?
    var estimateUseGas: BigUInt?
    var balance: BigUInt?
    var isLockAmount: Bool? = false
    var inputType: SendInputTableViewCellType?

    lazy var amountView = { () -> ATextFieldView in
        let amountView = ATextFieldView.create(title: "ATextFieldView_withdraw_title")
        amountView.textField.LocalizePlaceholder = Localized("staking_amount_placeholder", arguments: minAmountLimit?.description ?? "10")
        amountView.feeLabel.text = "0.00".displayFeeString
        amountView.textField.keyboardType = .decimalPad
        amountView.addAction(title: "send_sendAll", action: { [weak self] in
            if let maxAmount = self?.maxAmountLimit {
                amountView.textField.text = maxAmount.divide(by: ETHToWeiMultiplier, round: 8)
                self?.cellDidContentEditingHandler?(maxAmount, true)
                amountView.checkInvalidNow(showErrorMsg: true)
            }
        })
        amountView.checkInput(mode: .all, check: { [weak self] text -> (Bool, String) in
            let inputformat = CommonService.checkTransferAmoutInput(text: text, balance: self?.balance ?? BigUInt.zero, minLimit: self?.minAmountLimit, maxLimit: self?.maxAmountLimit, fee: self?.estimateUseGas, type: self?.inputType, isLockAmount: self?.isLockAmount)
//            let inputformat = CommonService.checkTransferAmoutInput(text: text, minLimit: self?.minAmountLimit, maxLimit: self?.maxAmountLimit, fee: self?.estimateUseGas, type: self?.inputType)
            if !inputformat.0 {
                return inputformat
            }
            return inputformat

            }, heightChange: { [weak self] _ in
                if amountView.textField.isFirstResponder {
                    self?.cellDidContentChangeHandler?()
                }

        })

        amountView.shouldChangeCharactersCompletion = { [weak self] (concatenated,replacement) in
            print("concatenated: \(concatenated), replacement: \(replacement)")
            if replacement == "" {
                self?.cellDidContentEditingHandler?(BigUInt.mutiply(a: concatenated, by: ETHToWeiMultiplier) ?? BigUInt.zero, false)
                return true
            }

            if !replacement.validFloatNumber() {
                return false
            }

            if !concatenated.trimNumberLeadingZero().isValidInputAmoutWith8DecimalPlace() {
                return false
            }

            self?.cellDidContentEditingHandler?(BigUInt.mutiply(a: concatenated, by: ETHToWeiMultiplier) ?? BigUInt.zero, true)
            return true
        }

        amountView.endEditCompletion = { [weak self] text in
            self?.cellDidContentEditingHandler?(BigUInt.mutiply(a: text, by: ETHToWeiMultiplier) ?? BigUInt.zero, true)
//            let _ = self?.checkConfirmButtonAvailable()
//            let _ = amountView.checkInvalidNow(showErrorMsg: false)
        }
        return amountView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = normal_background_color

        contentView.addSubview(amountView)
        amountView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
