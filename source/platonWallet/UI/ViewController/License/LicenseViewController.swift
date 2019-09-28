//
//  LicenseViewController.swift
//  platonWallet
//
//  Created by matrixelement on 2018/10/26.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit

protocol LicenseVCDelegate: AnyObject {
    
    func didClickNextStep()
    
}

class LicenseViewController: BaseViewController {

    @IBOutlet weak var continueBtn: PButton!
    @IBOutlet weak var content: UILabel!
    
    weak var delegate: LicenseVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        continueBtn.isEnabled = false
    }

    @IBAction func checkBtnClick(_ sender: Any) {
        guard let btn = sender as? UIButton else {
            return
        } 
        btn.isSelected = !btn.isSelected
        continueBtn.isEnabled = btn.isSelected
    }
    
    @IBAction func `continue`(_ sender: Any) {
        
        delegate?.didClickNextStep()
        
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
