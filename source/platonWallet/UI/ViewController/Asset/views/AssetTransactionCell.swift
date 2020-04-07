//
//  AssetTransactionCell.swift
//  platonWallet
//
//  Created by Admin on 30/3/2020.
//  Copyright © 2020 ju. All rights reserved.
//

import UIKit

class AssetTransactionCell: UITableViewCell {

    lazy var txTypeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .black
        return label
    }()

    lazy var transferAmoutLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()

    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = common_darkGray_color
        return label
    }()

    lazy var txIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "txSendSign")
        return imageView
    }()

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

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        initialUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initialUI() {
        selectionStyle = .none
        
        contentView.backgroundColor = UIColor(rgb: 0xF9FBFF)
        let containerView = UIView()
        containerView.backgroundColor = .white
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-12)
        }

        containerView.addSubview(txIcon)
        txIcon.snp.makeConstraints { make in
            make.height.width.equalTo(24)
            make.top.equalToSuperview().offset(18)
            make.bottom.equalToSuperview().offset(-18)
            make.leading.equalToSuperview().offset(10)
        }

        transferAmoutLabel.setContentHuggingPriority(.required, for: .horizontal)
        transferAmoutLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        containerView.addSubview(transferAmoutLabel)
        transferAmoutLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-10)
        }

        txTypeLabel.setContentHuggingPriority(.required, for: .horizontal)
        txTypeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        containerView.addSubview(txTypeLabel)
        txTypeLabel.snp.makeConstraints { make in
            make.leading.equalTo(txIcon.snp.trailing).offset(10)
            make.top.equalToSuperview().offset(11)
            make.trailing.lessThanOrEqualTo(transferAmoutLabel).offset(-5)
        }

        timeLabel.setContentHuggingPriority(.required, for: .horizontal)
        timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        containerView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(txTypeLabel.snp.bottom).offset(4)
            make.leading.equalTo(txTypeLabel.snp.leading)
            make.trailing.lessThanOrEqualTo(transferAmoutLabel).offset(-5)
        }

        txIcon.layer.addSublayer(pendingLayer)
    }

    func updateTransferCell(transaction: Transaction?, wallet: Wallet?) {
        guard let tx = transaction else { return }
        updateCellWithAPTTransfer(tx: tx, wallet: wallet)
    }

    func updateCellStyle(count: Int, index: Int) {

    }

    func updateCellWithAPTTransfer(tx: Transaction, wallet: Wallet?) {
        guard let w = wallet else { return }
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
