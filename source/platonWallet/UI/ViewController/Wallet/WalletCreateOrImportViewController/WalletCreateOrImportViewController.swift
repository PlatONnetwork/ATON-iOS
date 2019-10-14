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
        //self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    func setupUI() {
        createWalletBtn.style = .blue
        importWalletBtn.style = .gray
        createWalletBtn.setHorizontalLinerTitleAndImage(image: UIImage(named: "walletCreateIcon")!)
        importWalletBtn.setHorizontalLinerTitleAndImage(image: UIImage(named: "walletImportIcon")!)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

    override func didMove(toParent parent: UIViewController?) {
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }

    @IBAction func onCreateWallet(_ sender: Any) {
        let createWalletVC = CreateIndividualWalletViewController()
        //let createWalletVC = TSLViewControllerTwo()
        self.rt_navigationController.pushViewController(createWalletVC, animated: true, complete: nil)
    }

    @IBAction func onImportWallet(_ sender: Any) {
        self.rt_navigationController.pushViewController(MainImportWalletViewController(), animated: true)
    }

}
