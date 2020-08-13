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
import platonWeb3

enum SendInputTableViewCellType {
    case delegate
    case withdraw
    case transfer
}

class SendInputTableViewCell: UITableViewCell {

    var cellDidContentEditingHandler: ((BigUInt, Bool) -> Void)?
    var maxAmountLimit: BigUInt?
    var gas: BigUInt?
    var type: SendInputTableViewCellType? {
        didSet {
            if type == .withdraw {
                // 赎回时，显示”全部“
                self.amountView.handleBtn.setTitle(Localized("redeem_all"), for: .normal)
            }
        }
    }

    lazy var amountView = { () -> ATextFieldView in
        let amountView = ATextFieldView.create(title: "ATextFieldView_withdraw_title")
        amountView.feeLabel.text = "0.00".displayFeeString
        amountView.textField.keyboardType = .decimalPad
        amountView.addAction(title: "send_sendAll", action: { [weak self] in
            self?.showDelegateAllView()
        })

//        amountView.shouldChangeCharactersCompletion = { [weak self] (concatenated,replacement) in
//            print("concatenated: \(concatenated), replacement: \(replacement)")
//            if replacement == "" {
//                self?.cellDidContentEditingHandler?(BigUInt.mutiply(a: concatenated, by: ETHToWeiMultiplier) ?? BigUInt.zero, false)
//                return true
//            }
//
//            if !replacement.validFloatNumber() {
//                return false
//            }
//
//            if !concatenated.trimNumberLeadingZero().isValidInputAmoutWith8DecimalPlace() {
//                return false
//            }
//
//            self?.cellDidContentEditingHandler?(BigUInt.mutiply(a: concatenated, by: ETHToWeiMultiplier) ?? BigUInt.zero, true)
//            return true
//        }

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

    func showDelegateAllView() {
        guard let cellType = type, cellType == .delegate else {
            if let maxAmount = maxAmountLimit {
                amountView.textField.text = maxAmount.divide(by: ETHToWeiMultiplier, round: 8)
                cellDidContentEditingHandler?(maxAmount, true)
                let _ = amountView.checkInvalidNow(showErrorMsg: true)
            }
            return
        }

        guard let controller = viewController() else { return }
        let alertVC = AlertStylePopViewController.initFromNib()
        alertVC.style = PAlertStyle.ChoiceView(message: Localized("delegate_all_warnings", arguments: (SettingService.shareInstance.thresholdValue/PlatonConfig.VON.LAT).description.ATPSuffix()))

        let confirmAttr = NSMutableAttributedString(string: Localized("alert_delegate_all_without_01"), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)])
        let without01Attr = NSAttributedString(string: " (0.1LAT)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)])
        confirmAttr.append(without01Attr)

        alertVC.confirmButton.setAttributedTitle(confirmAttr, for: .normal)
        alertVC.cancelButton.setTitle(Localized("alert_delegate_all"), for: .normal)
        alertVC.onAction(confirm: { [weak self](_, _) -> (Bool) in
            self?.retainLATForDelegate()
            return true
        }) { [weak self] (_, _) -> (Bool) in
            self?.persistDelegateAll()
            return true
        }
        alertVC.showInViewController(viewController: controller)
    }

    func persistDelegateAll() {
        guard let maxAmount = maxAmountLimit, let gasBInt = gas else { return }
        guard maxAmount > gasBInt else {
            amountView.textField.text = "0.00"
            cellDidContentEditingHandler?(maxAmount, true)
            amountView.resetErrorState(errMsg: Localized("staking_withdraw_balance_Insufficient_error"))
            return
        }
        amountView.textField.text = maxAmount.divide(by: ETHToWeiMultiplier, round: 8)
        cellDidContentEditingHandler?(maxAmount, true)
        amountView.checkInvalidNow(showErrorMsg: true)
    }

    func retainLATForDelegate() {
        guard let maxAmount = maxAmountLimit, let gasBInt = gas else { return }
        let LAT0_1 = (BigUInt(1) * PlatonConfig.VON.LAT)/BigUInt(10)
        guard maxAmount > LAT0_1 + gasBInt else {
            amountView.textField.text = "0.00"
            cellDidContentEditingHandler?(maxAmount, true)
            amountView.resetErrorState(errMsg: Localized("staking_delegateall_keep_balance_error"))
            return
        }
        let newAmount = maxAmount - LAT0_1 - gasBInt

        amountView.textField.text = newAmount.divide(by: ETHToWeiMultiplier, round: 8)
        cellDidContentEditingHandler?(maxAmount, true)
        amountView.checkInvalidNow(showErrorMsg: true)
    }
}
