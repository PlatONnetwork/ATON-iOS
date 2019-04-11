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
    
    //@IBOutlet weak var rewardLabel: UILabel!
    
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
        let validNumber = Int(singleVote.validNum) ?? 0
        let invalidNumber = singleVote.invalidNumber
        validInvalidLabel.text = String(format: "%d/%d", validNumber, invalidNumber)
        
        let price = BigUInt(singleVote.deposit ?? "0")!
        let priceDes = price.divide(by: ETHToWeiMultiplier, round: 8).EnergonSuffix()
        ticketPriceLabel.text = priceDes
        
        let lockedDes = price.multiplied(by: BigUInt(String(validNumber))!).divide(by: ETHToWeiMultiplier, round: 8)
        let releaseDes = price.multiplied(by: BigUInt(String(invalidNumber))!).divide(by: ETHToWeiMultiplier, round: 8)
    
        lockedAndReleaseLabel.text = String(format: "%@/%@", lockedDes,releaseDes)
        
        //rewardLabel.text = singleVote.voteEarnings?.EnergonSuffix()
        
        voteWalletAddressLabel.text = "\(singleVote.owner)(\(singleVote.walletName))"
        
        expiredTime.text = Date(timeIntervalSince1970: TimeInterval(singleVote.createTime + TicketEffectivePeriod)).toFormatter("yyyy-MM-dd HH:mm:ss")
    }
    
}
