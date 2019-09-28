//
//  ClassicWalletCollectionViewCell.swift
//  platonWallet
//
//  Created by juzix on 2019/3/8.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit

class ClassicWalletCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var bgImgV: UIImageView!
    
    @IBOutlet weak var iconImgV: UIImageView!
    
    @IBOutlet weak var walletNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //AssetVCSharedData.sharedData.registerSelectedWalletChangeNotify(object: self)
    }
    
    func cwalletStyle(){
        
    }
    
    func jwalletStyle(){
        
    }
    
    func setUnhighlightState() {
        layer.shadowOpacity = 0
        self.bgImgV.image = UIImage(named: "home_classicWallet_bg_normal")
        self.iconImgV.image = UIImage(named: "home_classicWallet_icon_normal")
        walletNameLabel.textColor = common_blue_color
    }
    
    func setHighlightState() {
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 4).cgPath
        layer.shadowOpacity = 0.8
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 3
        layer.shadowColor = common_blue_color.cgColor
        self.bgImgV.image = UIImage(named: "home_classicWallet_bg_selected")
        self.iconImgV.image = UIImage(named: "home_classicWallet_icon_selected") 
        walletNameLabel.textColor = UIColor.white
    }
    
    func updateWallet(walletObj: Wallet){
        walletNameLabel.text = walletObj.name
        //iconImgV.image = walletObj.image()
        guard let tmp = AssetVCSharedData.sharedData.selectedWallet as? Wallet else {
            self.setUnhighlightState()
            return
        }
        if tmp == walletObj{
            self.setHighlightState()
        }else{
            self.setUnhighlightState()
        }
    }




}
