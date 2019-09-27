//
//  WalletDetailCell.swift
//  platonWallet
//
//  Created by matrixelement on 23/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import BigInt
import Localize_Swift

class WalletDetailCell: UITableViewCell {
    
    @IBOutlet weak var txTypeLabel: UILabel!
    
    @IBOutlet weak var transferAmoutLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var txIcon: UIImageView!
    
    @IBOutlet weak var unreadTag: UILabel!
    
    
    @IBOutlet weak var sepline: UIView!
    
    lazy var pendingLayer: CALayer = { () -> CALayer in
        let replicatorLayer = CAReplicatorLayer()
        replicatorLayer.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        replicatorLayer.instanceCount = 3
        replicatorLayer.instanceTransform = CATransform3DMakeTranslation((replicatorLayer.frame.size.width-4)/2, 0, 0);
        replicatorLayer.instanceDelay = 1/3.0
        
        let dotLayer = CAShapeLayer()
        dotLayer.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 10, width: 4, height: 4)).cgPath
        dotLayer.fillColor = UIColor(rgb: 0x2a5ffe).cgColor
        replicatorLayer.addSublayer(dotLayer)
        
        let keyAnimation = CAKeyframeAnimation(keyPath: "opacity")
        keyAnimation.isRemovedOnCompletion = false
        keyAnimation.duration = 1.0
        keyAnimation.keyTimes = [NSNumber(value: 0.0), NSNumber(0.5), NSNumber(1.0)]
        keyAnimation.values = [1.0, 0.7, 0.5]
        keyAnimation.repeatCount = Float.infinity
        dotLayer.add(keyAnimation, forKey: nil)
        
        return replicatorLayer
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()

        unreadTag.layer.masksToBounds = true
        unreadTag.layer.cornerRadius = 3
        unreadTag.isHidden = true
        
        txIcon.layer.addSublayer(pendingLayer)
    }
    
    func updateTransferCell(transaction: Transaction?, wallet: Wallet?) {
        guard let tx = transaction else { return }
        updateCellWithAPTTransfer(tx: tx, wallet: wallet)
    }
    
    func updateCellStyle(count: Int, index: Int){

    }

    func updateCellWithAPTTransfer(tx: Transaction, wallet: Wallet?) {
        guard let w = wallet else { return }
        self.unreadTag.isHidden = true
        tx.senderAddress = w.key?.address
        
        transferAmoutLabel.text = tx.amountTextString
        
        if tx.txType == .unknown || tx.txType == .transfer {
            txTypeLabel.text = tx.transactionStauts.localizeTitle
        } else {
            txTypeLabel.text = tx.txType?.localizeTitle
        }

        transferAmoutLabel.textColor = tx.amountTextColor
        txIcon.image = tx.txTypeIcon
        pendingLayer.isHidden = tx.txTypeIcon != nil
        
        guard (tx.confirmTimes != 0) else{
            guard tx.createTime != 0 else {
                timeLabel.text = "--:--:-- --:--"
                return
            }
            timeLabel.text = Date.toStanderTimeDescrition(millionSecondsTimeStamp: tx.createTime)
            return
        }
        
        timeLabel.text = Date.toStanderTimeDescrition(millionSecondsTimeStamp: tx.confirmTimes)
        
    }
    
}
