//
//  NewAddressInfoViewController.swift
//  platonWallet
//
//  Created by matrixelement on 29/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class NewAddressInfoViewController: BaseViewController , UITextFieldDelegate {

    enum FromScene {
        case add,edit
    }

    var fromScene: FromScene = .add
    var addressInfo: AddressInfo?

    var defaultAddress: String = ""

    var addCompletion: (() -> Void)?

    let contentView = UIView.viewFromXib(theClass: AddAddressInfoView.self) as! AddAddressInfoView

    static let maxTextCount = 20

    override func viewDidLoad() {
        super.viewDidLoad()
        initSubViews()
        initNavigationItem()
        contentView.addressField.text = defaultAddress
        contentView.scanButton.addTarget(self, action: #selector(onScanButton), for: .touchUpInside)
        self.autoAdjustInset()

        if fromScene == .edit {
            contentView.nameTextField.text = addressInfo?.walletName
            contentView.addressField.text = addressInfo?.walletAddress
            self.contentView.confirmButton.setTitle(Localized("Save"), for: .normal)
        }

        contentView.addressField.delegate = self
        contentView.nameTextField.delegate = self

        _ = self.checkConfirmButtonEnable(showTip: false)

    }

    func initSubViews() {

        view.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        contentView.confirmButton.addTarget(self, action: #selector(onConfirm), for: .touchUpInside)
    }

    func initNavigationItem() {

        if fromScene == .add {
            super.leftNavigationTitle = "AddAddress_nav_title"
        } else if fromScene == .edit {
            super.leftNavigationTitle = "EditAddress_nav_title"
        }
        /*
        let scanButton = UIButton(type: .custom)
        scanButton.setImage(UIImage(named: "navScanBlack"), for: .normal)
        scanButton.addTarget(self, action: #selector(onScanButton), for: .touchUpInside)
        scanButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        let rightBarButtonItem = UIBarButtonItem(customView: scanButton)
        navigationItem.rightBarButtonItem = rightBarButtonItem
        */
    }

    @objc func onScanButton() {

        let scanner = QRScannerViewController()
        scanner.scanCompletion = { [weak self] result in
            let qrcodeType = QRCodeDecoder().decode(result)
            switch qrcodeType {
            case .address(let data):
                self?.showMessage(text: Localized("QRScan_success_tips"))
                self?.contentView.addressField.text = data
                _ = self?.checkConfirmButtonEnable(showTip: false)
            case .error(let data):
                self?.showMessage(text: data)
            default:
                self?.showMessage(text: Localized("QRScan_failed_tips"))
            }
        }

        scanner.rescan()
        scanner.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(scanner, animated: true)
    }

    @objc func onConfirm() {

        if contentView.nameTextField.text?.length == 0 {
            contentView.showWalletNameTipWithString(desciption: Localized("NewAddress_name_empty_tip"))
            return
        }

        if (contentView.nameTextField.text?.length)! > 20 {
            contentView.showWalletNameTipWithString(desciption: Localized("NewAddress_name_Incorrect_tip"))
            return
        }

        if contentView.addressField.text?.length == 0 {
            contentView.showAddressTipWithString(desciption: Localized("NewAddress_address_empty_tip"))
            return
        }

        if !WalletUtil.isValidAddress(contentView.addressField.text!) {
            contentView.showAddressTipWithString(desciption: Localized("NewAddress_address_Incorrect_tip"))
            return
        }

        if fromScene == .add {
            let info = AddressInfo()
            info.walletName = contentView.nameTextField.text
            info.walletAddress = contentView.addressField.text
            info.createTime = Date().millisecondsSince1970
            info.addressType = AddressType_AddressBook
            AddressBookService.service.replaceInto(addrInfo: info, completion: addCompletion)
        } else if fromScene == .edit {

            guard let info = addressInfo else {
                return
            }
            let newA = AddressInfo()
            newA.walletName = contentView.nameTextField.text
            newA.walletAddress = contentView.addressField.text
            newA.createTime = info.createTime
            newA.addressType = AddressType_AddressBook
            newA.updateTime = Date().millisecondsSince1970
            AddressBookService.service.replaceInto(addrInfo: newA, completion: addCompletion)

            if contentView.addressField.text != info.walletAddress {
                AddressBookService.service.delete(addressInfo: info)
            }
        }

        navigationController?.popViewController(animated: true)
    }

    // MARK: UITextFieldDelegate

    func textFieldDidEndEditing(_ textField: UITextField) {
        _ = self.checkConfirmButtonEnable(showTip: false)
        if textField == contentView.nameTextField {
            _ = self.checkName(showTip: true)
        } else if textField == contentView.addressField {
            _ = self.checkAddress(showTip: true)
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        guard textField == contentView.nameTextField else {
            return true
        }
        
        if let text = textField.text, let textRange = Range(range, in: text) {
            let appendtext = text.replacingCharacters(in: textRange, with: string)
            if appendtext.count > NewAddressInfoViewController.maxTextCount {
                return false
            }
        }

        return true
    }

    func checkName(showTip :Bool) -> Bool {
        let resp = CommonService.checkNewAddressName(contentView.nameTextField.text ?? "")
        if resp.0 {
            contentView.hideWalletNameTip()
            contentView.nameTextField.setBottomLineStyle(style: .Normal)
        } else {
            if showTip {
                contentView.showWalletNameTipWithString(desciption: resp.1!)
                contentView.nameTextField.setBottomLineStyle(style: .Error)
            }

        }
        return resp.0
    }

    func checkAddress(showTip :Bool) -> Bool {
        let resp = CommonService.checkNewAddressString(contentView.addressField.text)
        if resp.0 {
            contentView.hideAddressTip()
            contentView.addressField.setBottomLineStyle(style: .Normal)
        } else {
            if showTip {
                contentView.showAddressTipWithString(desciption: resp.1!)
                contentView.addressField.setBottomLineStyle(style: .Error)
            }
        }
        return resp.0
    }

    func checkConfirmButtonEnable(showTip :Bool) -> Bool {
        let result = self.checkName(showTip: showTip) && self.checkAddress(showTip: showTip)
        contentView.confirmButton.setCommonEanbleStyle(result)
        if result {
            contentView.addButton.style = .blue
        } else {
            contentView.addButton.style = .disable
        }
        return result
    }
}
