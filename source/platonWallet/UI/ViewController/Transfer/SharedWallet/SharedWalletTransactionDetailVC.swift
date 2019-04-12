//
//  SharedWalletTXDetailVC.swift
//  platonWallet
//
//  Created by matrixelement on 19/11/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit

class SharedWalletTransactionDetailVC: BaseViewController {
    
    var sTransaction : STransaction?
    
    var swallet : SWallet?
    
    let transferView = UIView.viewFromXib(theClass: STransferDetailView.self) as! STransferDetailView

    override func viewDidLoad() {
        super.viewDidLoad()
        
        super.leftNavigationTitle = "SharedWalletDetailVC_nav_title"

        view.addSubview(transferView)
        transferView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        transferView.updateUI(transaction: sTransaction!, swallet: swallet!)
    
    }
    

    


}
