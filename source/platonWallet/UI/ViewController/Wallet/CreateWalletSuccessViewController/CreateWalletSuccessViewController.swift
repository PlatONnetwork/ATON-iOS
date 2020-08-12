//
//  CreateWalletSuccessViewController.swift
//  platonWallet
//
//  Created by matrixelement on 2018/10/23.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import Localize_Swift

protocol StartBackupMnemonicDelegate: AnyObject {
    func startBackup()
}

class CreateWalletSuccessViewController: BaseViewController {

    @IBOutlet weak var nextButton: PButton!
    weak var delegate: StartBackupMnemonicDelegate?
    var wallet: Wallet?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.nextButton.style = .blue
        self.nextButton.setHorizontalLinerTitleAndImage(image: UIImage(named: "nextBtnIcon")!)
        //super.leftNavigationTitle = "createWalletSuccessVC_title"
    }

    override func rt_customBackItem(withTarget target: Any!, action: Selector!) -> UIBarButtonItem! {

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.localizedText = "createWalletSuccessVC_title"
        let leftBarButtonItem = UIBarButtonItem(customView: label)
        return leftBarButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.rt_disableInteractivePop = true
    }

    @IBAction func startBackup(_ sender: Any) {
        delegate?.startBackup()
        if let addr = wallet?.address {
            AssetViewControllerV060.getInstance()?.reloadCurrentWallet(addr: addr)
        }
    }

    override func back() {
        backToMain()
    }

    @IBAction func onSkip(_ sender: Any) {
        backToMain()
    }
    
    func backToMain() {
        (UIApplication.shared.delegate as? AppDelegate)?.gotoMainTab()
        if let addr = wallet?.address {
            AssetViewControllerV060.getInstance()?.reloadCurrentWallet(addr: addr)
        }
    }

}
