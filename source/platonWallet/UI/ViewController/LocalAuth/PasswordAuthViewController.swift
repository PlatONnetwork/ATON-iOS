//
//  PasswordAuthViewController.swift
//  platonWallet
//
//  Created by matrixelement on 2018/11/6.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class PasswordAuthViewController: BaseViewController {

    @IBOutlet weak var addressContainer: UIView!

    @IBOutlet weak var walletName: UILabel!

    @IBOutlet weak var address: UILabel!

    @IBOutlet weak var chooseWalletBtn: UIButton!

    @IBOutlet weak var unlockBtn: PButton!

    @IBOutlet weak var walletIcon: UIImageView!

    @IBOutlet weak var pswTF: PTextFieldWithPadding!

//    var wallets = WalletService.sharedInstance.wallets

    var selectedWallet: Wallet! {
        didSet {
            walletName.text = selectedWallet.name
            address.text = selectedWallet.address
            walletIcon.image = selectedWallet.image()
        }
    }

    var completion: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        if WalletService.sharedInstance.wallets.count == 0 {
            // 没钱包名义上不进入该页面，进入即退出程序
            exit(0)
        }
        setupUI()
        selectedWallet = WalletService.sharedInstance.wallets[0].selectedWallet
        unlockBtn.style = .disable
//
//        pswTF.checkInput(mode: .textChange, check: {[weak self] (text) -> (Bool, String) in
//            let ret = CommonService.isValidWalletPassword(text)
//            if ret.0{
//                self?.unlockBtn.style = .blue
//            }else{
//                self?.unlockBtn.style = .disable
//            }
//            //away set as Editting
//            self?.pswTF.setBottomLineStyle(style: .Editing)
//            return (ret.0,ret.1 ?? "")
//        }) { (view) in
//            
//        }

        pswTF.endEditCompletion = {[weak self] text in
            let ret = CommonService.isValidWalletPassword(text)
            if ret.0 {
                self?.unlockBtn.style = .blue
            } else {
                self?.unlockBtn.style = .disable
            }
            self?.pswTF.setBottomLineStyle(style: .Normal)
        }

    }

    func setupUI() {

        super.leftNavigationTitle = "PasswordAuthVC_title"

        endEditingWhileTapBackgroundView = true
        addressContainer.layer.cornerRadius = 5.0
        addressContainer.layer.masksToBounds = true

        chooseWalletBtn.setupSwitchWalletStyle()
    }

    @IBAction func unlock(_ sender: Any) {

        view.endEditing(true)

        showLoadingHUD(text: Localized("PasswordAuthVC_unlocking_text"))
        WalletService.sharedInstance.exportPrivateKey(wallet: selectedWallet, password: pswTF.text!) {[weak self](_, error) in
            self?.hideLoadingHUD()
            if error == nil {
                self?.showMessage(text: Localized("PasswordAuthVC_unlockSuccess_text"))
                self?.completion?()
            } else {
                self?.showMessage(text: Localized("PasswordAuthVC_unlockFail_text"))
            }
        }

    }

    @IBAction func switchWallet(_ sender: Any) {

        let popUpVC = PopUpViewController()
        let view = UIView.viewFromXib(theClass: TransferSwitchWallet.self) as! TransferSwitchWallet
        view.selectedAddress = self.selectedWallet.address
        view.checkSufficient = false
        view.refresh()
        popUpVC.setUpContentView(view: view, size: CGSize(width: PopUpContentWidth, height: 289))
        popUpVC.setCloseEvent(button: view.closeBtn)
        view.selectionCompletion = { wallet in
            popUpVC.onDismissViewController()
            self.selectedWallet = wallet as? Wallet
        }
        popUpVC.show(inViewController: self)
    }

}

extension PasswordAuthViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            if CommonService.isValidWalletPassword(self.pswTF.text ?? "").0 {
                self.unlockBtn.style = .blue
            } else {
                self.unlockBtn.style = .disable
            }
        }
        return true
    }

}
