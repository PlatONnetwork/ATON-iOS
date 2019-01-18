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
    
    @IBOutlet weak var mnemonicLabel: UILabel!
    
    var mnemonic: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.localizedText = "backupMnemonicVC_title"
        shadowView.layer.cornerRadius = 4.0
        shadowView.layer.masksToBounds = true
        
        let subArr = mnemonic.split(separator: " ")
        let newMnemonic = subArr.joined(separator: "   ")
        
        let attr = NSMutableAttributedString(string: newMnemonic)
        let paragraphStye = NSMutableParagraphStyle()
        
        //调整行间距
        paragraphStye.lineSpacing = 8
        let rang = NSMakeRange(0, newMnemonic.length)
        attr.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStye, range: rang)

        mnemonicLabel.attributedText = attr
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()
        
        
        let alertC = PAlertController(title: Localized("alert_screenshot_ban_title"), message: Localized("alert_backupMnemonic_ban_msg"), image: UIImage(named: "icon_screenshot_ban"))
        alertC.addAction(title: Localized("alert_screenshot_ban_confirmBtn_title")) { 
            
        }
        alertC.show(inViewController: self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addShadow()
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

    @IBAction func next(_ sender: Any) {
        
        let vc = VerifyMnemonicViewController()
        vc.words_order = mnemonic.split(separator: " ").map({ return String($0) })
        rt_navigationController.pushViewController(vc, animated: true)
    }
    
    override func back() {
        
        (UIApplication.shared.delegate as? AppDelegate)?.gotoMainTab()
        
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
