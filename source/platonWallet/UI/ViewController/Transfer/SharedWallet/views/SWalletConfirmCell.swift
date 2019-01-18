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
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 1
        rotation.isCumulative = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        self.layer.add(rotation, forKey: "rotationAnimation")
    }
}

class SWalletConfirmCell: UICollectionViewCell {

    @IBOutlet weak var statusIcon: UIImageView!

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var loadingView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
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
            statusIcon.image = UIImage(named: "iconUndetermined")
        case .approval:
            nameLabel.text = result.walletName
            statusIcon.image = UIImage(named: "iconConfirm")
        case .revoke:
            nameLabel.text = result.walletName
            statusIcon.image = UIImage(named: "iconReject")
            
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
            nameLabel.text = Localized("MemberSignDetailVC_YOU")
            statusIcon.image = UIImage(named: "iconUndetermined")
            self.loadingView.isHidden = false
            self.loadingView.rotate()
            return
        }
        
        if (result.walletAddress?.ishexStringEqual(other: sender))!{
            if (transaction.txhash?.count)! > 0 && transaction.blockNumber?.count == 0{
                //wait for transaction receipt
                nameLabel.text = Localized("MemberSignDetailVC_YOU")
                statusIcon.image = UIImage(named: "iconUndetermined")
                self.loadingView.isHidden = false
                self.loadingView.rotate()
            }else{
                self.loadingView.isHidden = true
                self.updateImageAndDescription(result: result)
            }
        }else{
            self.loadingView.isHidden = true
            self.updateImageAndDescription(result: result)
        }
    }

    deinit {
        self.loadingView.layer.removeAllAnimations()
    }
}
