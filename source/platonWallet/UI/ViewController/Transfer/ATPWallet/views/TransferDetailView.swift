//
//  TransferDetailView.swift
//  platonWallet
//
//  Created by matrixelement on 26/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import BigInt
import Localize_Swift

class TransferDetailView: UIView {

    @IBOutlet weak var statusIconImageVIew: UIImageView!
    
    @IBOutlet weak var pendingLoadingImage: UIImageView!
    
//    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var fromLabel: UILabel!
    
    @IBOutlet weak var toLabel: UILabel!
    
//    @IBOutlet weak var transactionTypeLabel: UILabel!
//
//    @IBOutlet weak var timeLabel: UILabel!
    
//    @IBOutlet weak var valueLabel: UILabel!
    
//    @IBOutlet weak var feeLabel: UILabel!
    
//    @IBOutlet weak var memoContent: UILabel!
//
//    @IBOutlet weak var hashContent: UILabel!
    
    @IBOutlet weak var copyFromAddrBtn: CopyButton!
    
    @IBOutlet weak var detailContainer: UIView!
    
    @IBOutlet weak var copyToAddrBtn: CopyButton!
    
//    @IBOutlet weak var copyTxBtn: CopyButton!
    
//    @IBOutlet weak var voteExtraView: UIView!
//
//    @IBOutlet weak var nodeNameLabel: UILabel!
//
//    @IBOutlet weak var nodeIdLabel: UILabel!
//
//    @IBOutlet weak var numOfTicketsLabel: UILabel!
//
//    @IBOutlet weak var ticketPriceLabel: UILabel!
//
//    @IBOutlet weak var valueTitle: UILabel!
    
    @IBOutlet weak var walletNameLabel: UILabel!
    
    @IBOutlet weak var fromAvatarIV: UIImageView!
    
    @IBOutlet weak var fromNameLabel: UILabel!
    
    @IBOutlet weak var toAvatarIV: UIImageView!
    
    @IBOutlet weak var toNameLabel: UILabel!
    
    @IBOutlet weak var topValueLabel: UILabel!
    
    @IBOutlet weak var toIconIV: UIImageView!
    
//    @IBOutlet weak var showVoteExtraViewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var baseInfoHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var toLabelLeadingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        copyFromAddrBtn.attachTextView = fromLabel
        copyToAddrBtn.attachTextView = toLabel
////        copyTxBtn.attachTextView = hashContent
//        self.memoContent.isHidden = true
//        self.pendingLoadingImage.isHidden = true
    }
    
    func updateContent(tx : Transaction){
        fromLabel.text = tx.from
        toLabel.text = tx.to
        
        updateStatus(tx: tx)
        
        if let w = WalletService.sharedInstance.getWalletByAddress(address: tx.from ?? ""){
            self.walletNameLabel.text = w.name
        } else {
            let walletNames = AddressBookService.service.getAll().filter { $0.walletAddress == tx.from }.map { $0.walletName }
            guard walletNames.count > 0 else { return }
            self.walletNameLabel.text = walletNames.first!
        }
        
        toNameLabel.text = tx.toNameString
        fromNameLabel.text = tx.fromNameString
        toAvatarIV.image = tx.toAvatarImage
        fromAvatarIV.image = tx.fromAvatarImage
        
        if let valueString = tx.valueString.0, let color = tx.valueString.1 {
            topValueLabel.text = valueString
            topValueLabel.textColor = color
        } else {
            topValueLabel.text = nil
        }
        
        toIconIV.image = tx.toIconImage
        toLabelLeadingConstraint.priority = tx.toIconImage == nil ? UILayoutPriority(rawValue: 997) : UILayoutPriority(rawValue: 999)
    }
    
    func updateStatus(tx : Transaction){
        
//        if tx.txType == .transfer  {
//            transactionTypeLabel.text = tx.direction.localizedDesciption
//        } else {
//            transactionTypeLabel.text = tx.txType?.localizeTitle
//        }
        
        statusLabel.text = tx.transactionStauts.localizeDescAndColor.0
        statusLabel.textColor = .black
        switch tx.transactionStauts {
        case .sending, .receiving, .voting:
            statusIconImageVIew.image = UIImage(named: "statusPending")
            self.pendingLoadingImage.isHidden = false
            self.pendingLoadingImage.rotate()
        case .sendSucceed, .receiveSucceed, .voteSucceed:
            self.pendingLoadingImage.isHidden = true
            statusIconImageVIew.image = UIImage(named: "statusSuccess")
        case .sendFailed, .receiveFailed, .voteFailed:
            self.pendingLoadingImage.isHidden = true
            statusIconImageVIew.image = UIImage(named: "statusFail")
        }
        if tx.txReceiptStatus == TransactionReceiptStatus.timeout.rawValue{
            self.pendingLoadingImage.isHidden = true
            statusIconImageVIew.image = UIImage(named: "txTimeout")
        }
        
    }
    
}


