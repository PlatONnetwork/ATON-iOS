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
    
    func updateCell(voteTransaction: VoteTransaction){
        
        voteDateLabel.text = Date(timeIntervalSince1970: (TimeInterval(voteTransaction.transactionTime ?? "0") ?? 0)/1000.0).toFormatter("yyyy-MM-dd HH:mm:ss")
        let validNumber = Int(voteTransaction.validNum ?? "0") ?? 0
        let invalidNumber = voteTransaction.invalidNumber
        validInvalidLabel.text = String(format: "%d/%d", validNumber, invalidNumber)
        
        let price = BigUInt(voteTransaction.price ?? "0")!
        let priceDes = price.divide(by: ETHToWeiMultiplier, round: 8).EnergonSuffix()
        ticketPriceLabel.text = priceDes
        
        let lockedDes = price.multiplied(by: BigUInt(String(validNumber))!).divide(by: ETHToWeiMultiplier, round: 8)
        let releaseDes = price.multiplied(by: BigUInt(String(invalidNumber))!).divide(by: ETHToWeiMultiplier, round: 8)
    
        lockedAndReleaseLabel.text = String(format: "%@/%@", lockedDes,releaseDes)
        
        //返回的数值是科学计数，需要转成非科学计数，才可以转成bigint类型
        let formatter = NumberFormatter()
        let number = formatter.number(from: voteTransaction.earnings ?? "0")
        let rewardBig = BigUInt.safeInit(str: formatter.string(from: number!)).divide(by: ETHToWeiMultiplier, round: 4)
        
        rewardLabel.text = rewardBig.EnergonSuffix()
        
        voteWalletAddressLabel.text = "\(String(describing: voteTransaction.walletAddress ?? "0"))(\(voteTransaction.walletName))"
        
        expiredTime.text = Date(timeIntervalSince1970: (TimeInterval(voteTransaction.deadLine ?? "0") ?? 0)/1000.0).toFormatter("yyyy-MM-dd HH:mm:ss")
    }
    
}
