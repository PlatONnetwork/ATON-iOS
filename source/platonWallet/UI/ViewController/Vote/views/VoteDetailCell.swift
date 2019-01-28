//
//  VoteDetailCell.swift
//  platonWallet
//
//  Created by Ned on 28/12/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import BigInt

class VoteDetailCell: UITableViewCell {

    @IBOutlet weak var voteDateLabel: UILabel!
    
    @IBOutlet weak var validInvalidLabel: UILabel!
    
    @IBOutlet weak var ticketPriceLabel: UILabel!
    
    @IBOutlet weak var lockedAndReleaseLabel: UILabel!
    
    @IBOutlet weak var rewardLabel: UILabel!
    
    @IBOutlet weak var voteWalletAddressLabel: UILabel!
    
    
    @IBOutlet weak var expiredTime: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateCell(singleVote: SingleVote){
       
        voteDateLabel.text = Date(timeIntervalSince1970: TimeInterval(singleVote.createTime)).toFormatter("yyyy-MM-dd HH:mm:ss")
        
        validInvalidLabel.text = String(format: "%d/%d", Array(singleVote.tickets).tickets_validCount,Array(singleVote.tickets).tickets_invalidCount)
        ticketPriceLabel.text = BigUInt((singleVote.tickets.first?.deposit) ?? "0")?.divide(by: THE18powerof10, round: 2).EnergonSuffix()
        lockedAndReleaseLabel.text = String(format: "%@/%@", (Array(singleVote.tickets).tickets_assetOflocked?.EnergonSuffix())!,(Array(singleVote.tickets).tickets_releaseOfVote?.EnergonSuffix())!)
        
        let wallet = WalletService.sharedInstance.getWalletByAddress(address: singleVote.owner)
        voteWalletAddressLabel.text = "\(singleVote.owner)(\(wallet?.name ?? ""))"
        expiredTime.text = Date(timeIntervalSince1970: TimeInterval(singleVote.createTime + TicketEffectivePeriod)).toFormatter("yyyy-MM-dd HH:mm:ss")
    }
    
}
