//
//  ShareWalletConfirmVC.swift
//  platonWallet
//
//  Created by matrixelement on 14/11/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit

class ShareWalletConfirmVC: BaseViewController {

    var sTransaction : STransaction?
    
    var swallet : SWallet?
    
    //navigation from WalletDetailViewController
    var specifiedWallet : Wallet?
    
    let stransferConfirmView = UIView.viewFromXib(theClass: STransferConfirmView.self) as! STransferConfirmView
    override func viewDidLoad() {
        super.viewDidLoad()
        initsubViews()
        navigationItem.localizedText = "ConfrimVC_nav_title"
    } 
    
    func initsubViews(){
        stransferConfirmView.sw = swallet
        stransferConfirmView.specifiedWallet = specifiedWallet
        stransferConfirmView.viewController = self
        self.view.addSubview(stransferConfirmView)
        stransferConfirmView.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        
        stransferConfirmView.updateUI(transaction: sTransaction!)
    }
    
    deinit {
        stransferConfirmView.willDeinit()
    }

}
