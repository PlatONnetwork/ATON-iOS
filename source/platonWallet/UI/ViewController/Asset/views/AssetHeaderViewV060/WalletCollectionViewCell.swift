//
//  WalletCollectionViewCell.swift
//  platonWallet
//
//  Created by Admin on 23/9/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit

class WalletCollectionViewCell: UICollectionViewCell {
    
    let bgImgV = UIImageView()
    let iconImgV = UIImageView()
    let walletNameLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        contentView.addSubview(bgImgV)
        bgImgV.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        
        contentView.addSubview(iconImgV)
        iconImgV.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(9)
            make.top.equalToSuperview().offset(19)
            make.width.height.equalTo(24)
        }
        
        walletNameLabel.font = UIFont.systemFont(ofSize: 12)
        contentView.addSubview(walletNameLabel)
        walletNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImgV.snp.trailing).offset(6)
            make.centerY.equalTo(iconImgV.snp.centerY)
            make.trailing.equalToSuperview()
        }
    }
    
    func setUnhighlightState() {
        layer.shadowOpacity = 0
        bgImgV.image = UIImage(named: "home_classicWallet_bg_normal")
        iconImgV.image = UIImage(named: "home_classicWallet_icon_normal")
        walletNameLabel.textColor = common_blue_color
    }
    
    func setHighlightState() {
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 4).cgPath
        layer.shadowOpacity = 0.8
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 3
        layer.shadowColor = common_blue_color.cgColor
        bgImgV.image = UIImage(named: "home_classicWallet_bg_selected")
        iconImgV.image = UIImage(named: "home_classicWallet_icon_selected")
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
            setHighlightState()
        }else{
            setUnhighlightState()
        }
    }
}
