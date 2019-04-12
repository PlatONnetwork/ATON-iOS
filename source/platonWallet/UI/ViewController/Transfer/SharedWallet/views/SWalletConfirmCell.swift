//
//  SWalletConfirmCell.swift
//  platonWallet
//
//  Created by matrixelement on 15/11/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift



extension UIView {
    func rotate() {
        if self.layer.animation(forKey: "rotationAnimation") == nil{
            let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
            rotation.toValue = NSNumber(value: Double.pi * 2)
            rotation.duration = 1
            rotation.isCumulative = true
            rotation.repeatCount = Float.greatestFiniteMagnitude
            self.layer.add(rotation, forKey: "rotationAnimation")
        }

    }
    func stopRotate(){
        self.layer.removeAllAnimations()
    }
}

class SWalletConfirmCell: UICollectionViewCell {

    @IBOutlet weak var statusIconContainer: UIView!
    
    @IBOutlet weak var statusIcon: UIImageView!

    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.statusIconContainer.layer.masksToBounds = true
        self.statusIconContainer.layer.cornerRadius = 20
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        /*
        if statusIcon.frame.size.height > 0 {
            statusIcon.layer.cornerRadius = statusIcon.frame.size.height * 0.5
            statusIcon.layer.masksToBounds = true
        }
         */
        
        
    }
    
    func updateImageAndDescription(result : DeterminedResult)  {
        switch result.operationEnum {
        case .undetermined:
            nameLabel.text = ""
            self.statusIconContainer.backgroundColor = UIColor(rgb: 0xF9FBFF)
            //statusIcon.image = UIImage(named: "memberIconUndetermined")
            statusIcon.image = UIImage(named: "")
        case .approval:
            self.statusIconContainer.backgroundColor = UIColor(rgb: 0xF9FBFF)
            nameLabel.text = result.walletName
            statusIcon.image = UIImage(named: "memberIconConfirm")
        case .revoke:
            self.statusIconContainer.backgroundColor = UIColor(rgb: 0xF9FBFF)
            nameLabel.text = result.walletName
            statusIcon.image = UIImage(named: "memberIconReject")
        }
        
        //loading-s
        
    }
    
    func updateCell(result : DeterminedResult, transaction: STransaction, swallet: SWallet, specifyWallet: Wallet? = nil)  {
        
        var sender: String?
        if specifyWallet != nil{
            sender = specifyWallet?.key?.address
        }else{
            sender = swallet.walletAddress
        }
        
        if (result.walletAddress?.ishexStringEqual(other: sender))! &&
            transaction.txhash != nil &&
            (transaction.txhash?.count)! > 0 &&
            result.operationEnum == .undetermined{
            //wait for contranct confirm list to take effect
            statusIcon.image = UIImage(named: "memberIconUndetermined")
            self.statusIcon.rotate()
            return
        }
        
        if (result.walletAddress?.ishexStringEqual(other: sender))!{
            if (transaction.txhash?.count)! > 0 && transaction.blockNumber?.count == 0{
                //wait for transaction receipt
                nameLabel.text = Localized("MemberSignDetailVC_YOU")
                statusIcon.image = UIImage(named: "memberIconUndetermined")
                self.statusIcon.rotate()
            }else{
                self.statusIcon.stopRotate()
                self.updateImageAndDescription(result: result)
            }
        }else{
            self.statusIcon.stopRotate()
            self.updateImageAndDescription(result: result)
        }
    }

    deinit {
        self.statusIcon.layer.removeAllAnimations()
    }
}
