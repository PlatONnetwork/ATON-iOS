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
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var fromLabel: UILabel!
    
    @IBOutlet weak var toLabel: UILabel!
    
    @IBOutlet weak var transactionTypeLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var valueLabel: UILabel!
    
    @IBOutlet weak var feeLabel: UILabel!
    
    @IBOutlet weak var memoContent: UILabel!
    
    @IBOutlet weak var hashContent: UILabel!
    
    @IBOutlet weak var copyFromAddrBtn: CopyButton!
    
    @IBOutlet weak var detailContainer: UIView!
    
    @IBOutlet weak var copyToAddrBtn: CopyButton!
    
    @IBOutlet weak var copyTxBtn: CopyButton!
    
    @IBOutlet weak var voteExtraView: UIView!
    
    @IBOutlet weak var nodeNameLabel: UILabel!
    
    @IBOutlet weak var nodeIdLabel: UILabel!
    
    @IBOutlet weak var numOfTicketsLabel: UILabel!
    
    @IBOutlet weak var ticketPriceLabel: UILabel!
    
    @IBOutlet weak var valueTitle: UILabel!
    
    @IBOutlet weak var walletNameLabel: UILabel!
    
    
    @IBOutlet weak var showVoteExtraViewConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        
        copyFromAddrBtn.attachTextView = fromLabel
        copyToAddrBtn.attachTextView = toLabel
        copyTxBtn.attachTextView = hashContent
        self.memoContent.isHidden = true
        self.pendingLoadingImage.isHidden = true
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        let extraPedding =  CGFloat(88.0 + 50.0 + 20.0 + 15.0)
//        let h = self.detailContainer.frame.size.height + extraPedding
//        if h  < self.frame.size.height{
//            self.detailContainer.frame = CGRect(x: self.detailContainer.frame.origin.x,
//                                                y: self.detailContainer.frame.origin.y,
//                                                width: self.detailContainer.frame.size.width,
//                                                height: self.frame.size.height - extraPedding)
//        }
//    }
    
    func updateContent(tx : Transaction){
        if tx.txType == .voteTicket {
            voteExtraView.isHidden = false
            showVoteExtraViewConstraint.priority = .defaultHigh
            valueTitle.text = Localized("TransactionDetailVC_voteStaked")
            
            if let txInfo = tx.extra, let data = txInfo.data(using: .utf8) {
                let decoder = JSONDecoder()
                let voteTicketInfo = try? decoder.decode(VoteTicketInfo.self, from: data)
                nodeNameLabel.text = voteTicketInfo?.parameters?.nodeName
                nodeIdLabel.text = voteTicketInfo?.parameters?.nodeId
                numOfTicketsLabel.text = String(describing: voteTicketInfo?.parameters?.count ?? 0)

                if voteTicketInfo?.parameters?.price?.description.count ?? 0 > 0 {
                    ticketPriceLabel.text = BigUInt.safeInit(str: voteTicketInfo?.parameters?.price?.description ?? "").divide(by: ETHToWeiMultiplier, round: 4).EnergonSuffix()
                } else {
                    ticketPriceLabel.text = "-".EnergonSuffix()
                }
            } else {
                guard let singleVote = VotePersistence.getSingleVotesByTxHash(tx.txhash!) else {
                    nodeNameLabel.text = "-"
                    nodeIdLabel.text = "-"
                    numOfTicketsLabel.text = "-"
                    ticketPriceLabel.text = "-"
                    return
                }
                
                let candidateInfo = VotePersistence.getCandidateInfoWithId(singleVote.candidateId ?? "")
                nodeNameLabel.text = candidateInfo.name
                nodeIdLabel.text = singleVote.candidateId?.add0x()
                if singleVote.validNum.count > 0{
                    numOfTicketsLabel.text = "\(singleVote.validNum)"
                }else{
                    numOfTicketsLabel.text = "-"
                }
                if (singleVote.deposit?.count)! > 0{
                    ticketPriceLabel.text = BigUInt.safeInit(str: singleVote.deposit ?? "").divide(by: ETHToWeiMultiplier, round: 4).EnergonSuffix()
                }else{
                    ticketPriceLabel.text = "-".EnergonSuffix()
                }
            }
        } else {
            voteExtraView.isHidden = true
            showVoteExtraViewConstraint.priority = .defaultLow
            valueTitle.text = Localized("TransactionDetailVC_value")
        }
        
        hashContent.text = tx.txhash?.add0x()
        if tx.confirmTimes != 0 {
            timeLabel.text = Date.toStanderTimeDescrition(millionSecondsTimeStamp: tx.confirmTimes)
        } else {
            timeLabel.text = Date.toStanderTimeDescrition(millionSecondsTimeStamp: tx.createTime)
        }
        fromLabel.text = tx.from
        toLabel.text = tx.to
        valueLabel.text = tx.valueDescription!.ATPSuffix()
        feeLabel.text = tx.actualTxCostDescription?.ATPSuffix()
        
        updateStatus(tx: tx)
        
        if let w = WalletService.sharedInstance.getWalletByAddress(address: tx.from ?? ""){
            self.walletNameLabel.text = w.name
        } else {
            let walletNames = AddressBookService.service.getAll().filter { $0.walletAddress == tx.from }.map { $0.walletName }
            guard walletNames.count > 0 else { return }
            self.walletNameLabel.text = walletNames.first!
        }
    }
    
    func updateStatus(tx : Transaction){
        
        if tx.txType == .transfer  {
            transactionTypeLabel.text = tx.transactionStauts.localizeTitle
        } else {
            transactionTypeLabel.text = tx.txType?.localizeTitle
        }
        
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

        
    }
    
}


