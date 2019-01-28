//
//  CreateWalletSuccessViewController.swift
//  platonWallet
//
//  Created by matrixelement on 2018/10/23.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import Localize_Swift

protocol BackupDelegate: AnyObject {
    func startBackupClick()
}

class CreateWalletSuccessViewController: BaseViewController {
    
    weak var delegate: BackupDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.localizedText = "createWalletSuccessVC_title"
    }
    
    @IBAction func startBackup(_ sender: Any) {
        delegate?.startBackupClick()
    }
    
    override func back() {
        (UIApplication.shared.delegate as? AppDelegate)?.gotoMainTab()
    }
}
