//
//  BackupMnemonicViewController.swift
//  platonWallet
//
//  Created by matrixelement on 2018/10/25.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class BackupMnemonicViewController: BaseViewController {

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var button: PButton!

    var walletAddress : String?

    var mnemonic: String!

    var mnemonicGridView : MnemonicGridView? = UIView.viewFromXib(theClass: MnemonicGridView.self) as? MnemonicGridView

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        button.style = .blue
        super.leftNavigationTitle = "backupMnemonicVC_title"
        self.shadowView.addSubview(self.mnemonicGridView!)
        self.mnemonicGridView?.snp.makeConstraints({ (make) in
            make.edges.equalTo(self.shadowView)
        })
        self.mnemonicGridView?.setMnemonic(mnemonic: mnemonic)
        self.mnemonicGridView?.setDisableEditStyle()
        button.setHorizontalLinerTitleAndImage(image: UIImage(named: "nextBtnIcon")!)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showNotScreeshotAler()
        }
    }

    func showNotScreeshotAler() {
        let alertVC = AlertStylePopViewController.initFromNib()
        alertVC.style = PAlertStyle.AlertWithRedTitle(title: "alert_screenshot_ban_title", message: "alert_backupMnemonic_ban_msg")
        alertVC.confirmButton.localizedNormalTitle = "alert_screenshot_ban_confirmBtn_title"
        alertVC.onAction(confirm: { (_, _) -> (Bool) in
            return true
        }) { (_, _) -> (Bool) in
            return true
        }
        alertVC.showInViewController(viewController: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.rt_disableInteractivePop = true
        //self.rt_navigationController.rt_disableInteractivePop = true
        //addShadow()
    }

    func addShadow() {

        let shadowL = CALayer()
        shadowL.frame = shadowView.frame
        shadowL.backgroundColor = view.backgroundColor?.cgColor
        shadowL.shadowColor = UIColor(rgb: 0x020527, alpha: 0.2).cgColor
        shadowL.shadowOffset = CGSize(width: 0, height: 2)
        shadowL.shadowOpacity = 0.2
        shadowL.shadowRadius = 3
        view.layer.insertSublayer(shadowL, below: shadowView.layer)

    }

    override func rt_customBackItem(withTarget target: Any!, action: Selector!) -> UIBarButtonItem! {
        if self.useDefaultLeftBarButtonItem && super.leftNavigationTitle != nil && (super.leftNavigationTitle?.length)! > 0 {
            return self.getBasicLeftBarButtonItemWithBasicStyle(localizedText: super.leftNavigationTitle)
        }
        return UIBarButtonItem(image: UIImage(named: "nav_back"), style: .plain, target: self, action: #selector(back))
    }

    @IBAction func next(_ sender: Any) {

        let vc = VerifyMnemonicViewController()
        vc.walletAddress = self.walletAddress
        //mnemonic = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
        vc.words_order = mnemonic.split(separator: " ").map({ return String($0) })
        rt_navigationController.pushViewController(vc, animated: true)
    }

    override func back() {
        self.gotoMainTabController()
    }

    func showChoiceView() {
        let alertVC = AlertStylePopViewController.initFromNib()
        alertVC.style = PAlertStyle.ChoiceView(message: "backup_quit_tip")
        alertVC.onAction(confirm: { (_, _) -> (Bool) in
            self.gotoMainTabController()
            return true
        }) { (_, _) -> (Bool) in
            return true
        }
        alertVC.showInViewController(viewController: self)
    }

    func gotoMainTabController() {
        self.afterBackupRouter()
    }

    override func onCustomBack() {
        self.showChoiceView()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
