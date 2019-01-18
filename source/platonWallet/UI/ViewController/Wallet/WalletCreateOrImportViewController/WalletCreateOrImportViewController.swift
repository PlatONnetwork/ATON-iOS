//
//  WalletCreateOrImportViewController.swift
//  platonWallet
//
//  Created by matrixelement on 2018/10/22.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import Localize_Swift

class WalletCreateOrImportViewController: BaseViewController {
    
    @IBOutlet weak var createWalletBtn: PButton!
    
    @IBOutlet weak var importWalletBtn: PButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        createWalletBtn.setTitle(Localized("WelcomePage_create_wallet"), for: .normal)
        importWalletBtn.setTitle(Localized("WelcomePage_import_wallet"), for: .normal)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func onCreateWallet(_ sender: Any) {
        let createWalletVC = CreateIndividualWalletViewController()
        
        rt_navigationController.pushViewController(createWalletVC, animated: true)
    }
    
    @IBAction func onImportWallet(_ sender: Any) {
        
        rt_navigationController.pushViewController(MainImportWalletViewController(), animated: true)
        
    }
    
    
}
