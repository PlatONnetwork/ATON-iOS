//
//  SharedPresentedVC.swift
//  platonWallet
//
//  Created by Ned on 17/12/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class SharedPresentedVC: BaseViewController {

    var transitionView : UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.view.addSubview(transitionView!)
        transitionView?.snp.makeConstraints({ (make) in
            make.edges.equalTo(self.view)
        })
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
