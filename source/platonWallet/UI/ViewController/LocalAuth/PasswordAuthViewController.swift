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
    
    @IBOutlet weak var pswTF: PTextFieldWithPadding!
    
//    var wallets = WalletService.sharedInstance.wallets
    
    var selectedWallet: Wallet! {
        didSet {
            walletName.text = selectedWallet.name
            address.text = selectedWallet.key?.address
        }
    }
    
    var completion: (()->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        selectedWallet = WalletService.sharedInstance.wallets[0] 
        
    }

    func setupUI() {

        navigationItem.localizedText = "PasswordAuthVC_title"
        
        endEditingWhileTapBackgroundView = true
        addressContainer.layer.cornerRadius = 5.0
        addressContainer.layer.masksToBounds = true
        
        unlockBtn.isEnabled = false
        
        chooseWalletBtn.setupSwitchWalletStyle()
    }

    @IBAction func unlock(_ sender: Any) {
        
        view.endEditing(true)

        showLoading(text: Localized("PasswordAuthVC_unlocking_text"))
        WalletService.sharedInstance.exportPrivateKey(wallet: selectedWallet, password: pswTF.text!) {[weak self](_, error) in
            self?.hideLoading()
            if error == nil {
                self?.showMessage(text: Localized("PasswordAuthVC_unlockSuccess_text"))
                self?.completion?()
            }else {
                self?.showMessage(text: Localized("PasswordAuthVC_unlockFail_text"))
            }
        }
        
    }
    
    @IBAction func switchWallet(_ sender: Any) {
        
        WalletSelectionView.show(inViewController: self, lastSelectedWallet: selectedWallet) { [weak self](newWallet) in
            self?.selectedWallet = newWallet
        }
    }
  

}

extension PasswordAuthViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) { 
            self.unlockBtn.isEnabled = self.pswTF.text!.length > 5
        }
        return true
    }
    
}
