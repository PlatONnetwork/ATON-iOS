//
//  JointWalletCollectionViewCell.swift
//  platonWallet
//
//  Created by juzix on 2019/3/8.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit

class JointWalletCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var bgImgV: UIImageView!
    
    @IBOutlet weak var iconImgV: UIImageView!
    
    @IBOutlet weak var walletNameBGLabel: UILabel!
    
    @IBOutlet weak var walletNameLabel: UILabel!
    
    @IBOutlet weak var redDot: UILabel!
    
    @IBOutlet weak var container: UIView!
    
    var jointWallet : SWallet?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdatejointWalletProgress), name: NSNotification.Name(DidJointWalletUpdateProgress_Notification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateUnreadDot), name: Notification.Name(WillUpdateUnreadDot_Notification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willDeleteWallet(_:)), name: Notification.Name(WillDeleateWallet_Notification), object: nil)
        
    } 
    
    func setProgress(_ progress: CGFloat) {
        let w = bounds.width * progress
        let maskLayer = CALayer()
        maskLayer.frame = CGRect(x: 0, y: 0, width: w, height: bounds.height)
        maskLayer.backgroundColor = UIColor.red.cgColor
        container.layer.mask = maskLayer
    }
    
    func setHighlightState() {
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 4).cgPath
        layer.shadowOpacity = 0.8
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 3
        layer.shadowColor = common_blue_color.cgColor
        self.bgImgV.image = UIImage(named: "home_jointWallet_bg_selected")
        self.iconImgV.image = UIImage(named: "home_jointWallet_icon_selected")
        walletNameLabel.textColor = UIColor.white
    }
     
    func setUnhighlightState() {
        layer.shadowOpacity = 0
        walletNameLabel.textColor = common_blue_color
        self.bgImgV.image = UIImage(named: "home_jointWallet_bg_normal")
        self.iconImgV.image = UIImage(named: "home_jointWallet_icon_normal")
    }
    
    func updateWallet(walletObj: SWallet){
        
        jointWallet = walletObj
        
        self.walletNameBGLabel.text = walletObj.name
        self.walletNameLabel.text = walletObj.name
        
        if jointWallet!.privateKey != nil && (jointWallet!.privateKey?.length)! > 0{
            self.setUnhighlightState()
            self.didUpdatejointWalletProgress()
            return
        }
        
        guard let tmp = AssetVCSharedData.sharedData.selectedWallet as? SWallet else {
            self.setUnhighlightState()
            return
        }
        if tmp == walletObj{
            self.setHighlightState()
        }else{
            self.setUnhighlightState()
        }
        
    }
    
    //MARK: - Notification
    
    @objc func didUpdatejointWalletProgress(){
        
        guard jointWallet != nil, jointWallet!.privateKey != nil,(jointWallet!.privateKey?.count)! > 0 else{
            return
        }
        self.setProgress(CGFloat(jointWallet!.progress) * 0.01)
    }
    
    @objc func updateUnreadDot(){
        guard jointWallet != nil else {
            return
        }
        redDot.isHidden = !STransferPersistence.unreadMessageExistedWithContractAddress(jointWallet!.contractAddress)
    }
    
    @objc func willDeleteWallet(_ notification: Notification){
        if let wallet = notification.object as? SWallet{
            if wallet.contractAddress.ishexStringEqual(other: jointWallet?.contractAddress){
                jointWallet = nil
            }
        }
    }

    
    override func prepareForReuse() {
        self.redDot.isHidden = true
        self.setProgress(1)
    }

}
