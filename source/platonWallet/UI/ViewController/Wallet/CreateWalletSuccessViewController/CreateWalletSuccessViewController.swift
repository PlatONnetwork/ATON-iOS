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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.nextButton.style = .blue
        self.nextButton.setHorizontalLinerTitleAndImage(image: UIImage(named: "nextBtnIcon")!)
        //super.leftNavigationTitle = "createWalletSuccessVC_title"
    }

    override func rt_customBackItem(withTarget target: Any!, action: Selector!) -> UIBarButtonItem! {

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        label.textColor = UIColor.black
        label.font = UIFont.boldSystemFont(ofSize: 16)
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
    }

    override func back() {
        (UIApplication.shared.delegate as? AppDelegate)?.gotoMainTab()
    }

    @IBAction func onSkip(_ sender: Any) {
        (UIApplication.shared.delegate as? AppDelegate)?.gotoMainTab()
    }

}
