//
//  SendInputTableViewCell.swift
//  platonWallet
//
//  Created by Admin on 29/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit

class SendInputTableViewCell: UITableViewCell {
    
    var cellDidContentChangeHandle: (() -> Void)?
    
    lazy var amountView = { () -> ATextFieldView in
        let amountView = ATextFieldView.create(title: "ATextFieldView_withdraw_title")
        amountView.textField.LocalizePlaceholder = "send_amount_placeholder"
        amountView.feeLabel.text = "0.0000"
        amountView.textField.keyboardType = .phonePad
        amountView.addAction(title: "send_sendAll", action: { [weak self] in
            
        })
        amountView.checkInput(mode: .all, check: { [weak self] text -> (Bool, String) in
            let inputformat = CommonService.checkTransferAmoutInput(text: text, checkBalance: false, fee: nil)
            if !inputformat.0{
                return inputformat
            }
            
            return inputformat
            }, heightChange: { [weak self] view in
                if amountView.textField.isFirstResponder {
                    self?.cellDidContentChangeHandle?()
                }
                
        })
        
        amountView.shouldChangeCharactersCompletion = { [weak self] (concatenated,replacement) in
            if replacement == ""{
                return true
            }
            if !replacement.validFloatNumber(){
                return false
            }
            return concatenated.trimNumberLeadingZero().isValidInputAmoutWith8DecimalPlace()
        }
        
        amountView.endEditCompletion = { [weak self] text in
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
