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
        replicatorLayer.instanceTransform = CATransform3DMakeTranslation((replicatorLayer.frame.size.width-4)/2, 0, 0)
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
        txTypeLabel.font = .systemFont(ofSize: 13.0, weight: .medium)
        transferAmoutLabel.font = .systemFont(ofSize: 14.0, weight: .medium)
    }

    func updateTransferCell(transaction: Transaction?, wallet: Wallet?) {
        guard let tx = transaction else { return }
        updateCellWithAPTTransfer(tx: tx, wallet: wallet)
    }

    func updateCellStyle(count: Int, index: Int) {

    }

    func updateCellWithAPTTransfer(tx: Transaction, wallet: Wallet?) {
        guard let w = wallet else { return }
        self.unreadTag.isHidden = true
        tx.senderAddress = w.address

        transferAmoutLabel.text = tx.amountTextString

        if tx.txType == .unknown || tx.txType == .transfer {
            txTypeLabel.text = tx.transactionStauts.localizeTitle
        } else {
            txTypeLabel.text = tx.txType?.localizeTitle
        }

        txTypeLabel.textColor = tx.typeTextColor
        transferAmoutLabel.textColor = tx.amountTextColor
        if tx.txReceiptStatus == TransactionReceiptStatus.pending.rawValue {
            txIcon.image = nil
            pendingLayer.isHidden = false
        } else {
            txIcon.image = tx.txTypeIcon
            pendingLayer.isHidden = true
        }

        //最后处理超时状态
        if tx.txReceiptStatus == TransactionReceiptStatus.timeout.rawValue {
            guard let selectedAddress = AssetVCSharedData.sharedData.selectedWalletAddress else { return }
            var direction = TransactionDirection.unknown
            direction = tx.getTransactionDirection(selectedAddress)
//            switch tx.txType! {
//            case .transfer:
//                direction = (selectedAddress.lowercased() == tx.from?.lowercased() ? .Sent : selectedAddress.lowercased() == tx.to?.lowercased() ? .Receive : .unknown)
//            case .delegateWithdraw,
//                 .stakingWithdraw,
//                 .claimReward:
//                direction = .Receive
//            default:
//                direction = .Sent
//            }
            txIcon.image = Transaction.getTxTypeIconByDirection(direction: direction, txType: tx.txType)
            pendingLayer.isHidden = true
        }

        guard (tx.confirmTimes != 0) else {
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
