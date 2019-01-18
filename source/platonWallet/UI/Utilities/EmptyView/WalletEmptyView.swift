//
//  WalletEmptyView.swift
//  platonWallet
//
//  Created by matrixelement on 2018/10/31.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class WalletEmptyView: UIView {
    
    @IBOutlet weak var tipsLabel: UILabel!
    
    @IBOutlet weak var btn1: PButton!

    @IBOutlet weak var btn2: PButton!
    
    var createBtnClickHandler: (()->Void)?
    var importBtnClickHandler: (()->Void)?
    
    convenience init(walletType: WalletType, createBtnClickHandler:@escaping ()->Void, importBtnClickHandler: @escaping ()->Void) {
        
        self.init()
        self.createBtnClickHandler = createBtnClickHandler
        self.importBtnClickHandler = importBtnClickHandler
        
        let view = Bundle.main.loadNibNamed("WalletEmptyView", owner: self, options: nil)?.first as! UIView
        addSubview(view)
        view.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        setupUIFor(walletType)
    }
    
    func setupUIFor(_ type: WalletType) {
        
        if type == .ATPWallet {
            tipsLabel.localizedText = "IndividualWallet_EmptyView_tips" 
            btn1.localizedNormalTitle = "IndividualWallet_EmptyView_createBtn_title"
            btn2.localizedNormalTitle = "IndividualWallet_EmptyView_importBtn_title"

        }else {
            tipsLabel.localizedText = "SharedWallet_EmptyView_tips"
            btn1.localizedNormalTitle = "SharedWallet_EmptyView_createBtn_title"
            btn2.localizedNormalTitle = "SharedWallet_EmptyView_importBtn_title"
        }
        
    }
    
    
    @IBAction func onBtn1Click(_ sender: Any) {
        createBtnClickHandler?()
    }
    
    @IBAction func onBtn2Click(_ sender: Any) {
        importBtnClickHandler?()
    }
    
}
