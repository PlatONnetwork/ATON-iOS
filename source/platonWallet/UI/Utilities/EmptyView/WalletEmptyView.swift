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
        btn1.style = .blue
        btn2.style = .gray
        tipsLabel.localizedText = "IndividualWallet_EmptyView_tips"
        
        DispatchQueue.main.async { [weak self] in
            self?.btn1.setHorizontalLinerTitleAndImage(image: UIImage(named: "walletCreateIcon")!)
            self?.btn2.setHorizontalLinerTitleAndImage(image: UIImage(named: "walletImportIcon")!)
        }  
    }
    
    
    @IBAction func onBtn1Click(_ sender: Any) {
        createBtnClickHandler?()
    }
    
    @IBAction func onBtn2Click(_ sender: Any) {
        importBtnClickHandler?()
    }
    
}
