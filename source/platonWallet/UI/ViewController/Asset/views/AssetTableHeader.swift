
//
//  AssetTableHeader.swift
//  platonWallet
//
//  Created by matrixelement on 18/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import SnapKit
import Localize_Swift

class AssetTableHeader: UIView {
    
    let bgView = UIImageView()
    let assetDesLabel = UILabel()
    let assetLabel = UILabel()
    let unitLabel = UILabel()
    
    
    override init(frame: CGRect) {
        super.init(frame : frame)
        initialized()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        initialized()
    }
    
    override func layoutSubviews() {
        bgView.snp.makeConstraints { (make) in
            make.leading.equalTo(self).offset(0)
            make.trailing.equalTo(self).offset(0)
            make.top.equalTo(self).offset(12)
            make.bottom.equalTo(self).offset(-12)
        }
        
        assetDesLabel.snp.makeConstraints { (make) in
            make.top.equalTo(bgView).offset(8)
            make.centerX.equalTo(bgView)
            make.height.equalTo(20)
        }
        
        assetLabel.snp.makeConstraints { (make) in
            make.top.equalTo(assetDesLabel).offset(8)
//            make.centerX.equalTo(bgView)
            make.bottom.equalTo(bgView)
            make.leading.equalTo(bgView).offset(5)
            make.trailing.equalTo(bgView).offset(-5)
        }
        assetLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
//        unitLabel.snp.makeConstraints { (make) in
//            make.leading.equalTo(assetLabel.snp_trailingMargin)
//            make.top.equalTo(assetDesLabel).offset(8)
//            make.trailing.equalTo(bgView).offset(80)
//        }
//        unitLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
//
        
    }
    
    func initialized() {
        backgroundColor = UIViewController_backround
        addSubview(bgView)
        bgView.image = UIImage(named: "totalAssetBG")
        bgView.addSubview(assetDesLabel)
        bgView.addSubview(assetLabel)
//        bgView.addSubview(unitLabel)
        
        assetDesLabel.font = UIFont.systemFont(ofSize: 12)
        assetDesLabel.textColor = .white
        assetDesLabel.localizedText = "asset_header_total_asset"
        
        assetLabel.font = UIFont.boldSystemFont(ofSize: 24)
        assetLabel.textColor = total_asset_color
        assetLabel.adjustsFontSizeToFitWidth = true
        assetLabel.minimumScaleFactor = 0.2
        assetLabel.textAlignment = .center
        
        unitLabel.font = UIFont.boldSystemFont(ofSize: 24)
        unitLabel.textColor = total_asset_color
        unitLabel.adjustsFontSizeToFitWidth = true
        unitLabel.minimumScaleFactor = 0.2
        
    }
    
    func updateAssetValue(value : String) {
        
        let myShadow = NSShadow()
        myShadow.shadowBlurRadius = 3
        myShadow.shadowOffset = CGSize(width: 0.5, height: 2)
        myShadow.shadowColor = UIColor(rgb: 0x000000, alpha: 0.3)
        let allString = value.ATPSuffix()
        let myAttribute = [ NSAttributedString.Key.shadow: myShadow ]
        let myAttrString = NSMutableAttributedString(string: allString, attributes: myAttribute)
        
        let atpUnitAttributes = [NSAttributedString.Key.foregroundColor: total_asset_color,
                       NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)] as [NSAttributedString.Key : Any]
        myAttrString.addAttributes(atpUnitAttributes, range: NSMakeRange(allString.length - "".ATPSuffix().length, "".ATPSuffix().length))
        
        
        let tmp = myAttrString.size()
        let finalSize = myAttrString.boundingRect(with: CGSize(width: 10000, height: tmp.height), options: .usesLineFragmentOrigin, context: nil)
        
        if finalSize.width >  bgView.frame.size.width{
            assetLabel.attributedText = NSAttributedString(string: "")
            assetLabel.text = value.ATPSuffix()
        }else{
            assetLabel.text = nil
            assetLabel.attributedText = myAttrString
        }
        
        
    }
    
    
    
}
