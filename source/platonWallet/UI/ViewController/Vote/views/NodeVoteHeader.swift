//
//  NodeVoteHeader.swift
//  platonWallet
//
//  Created by Ned on 26/12/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit

class NodeVoteHeader: UIView {

    @IBOutlet weak var lockedAsset: UILabel!
    
    @IBOutlet weak var validandinvalidTicketNum: UILabel!
    
    @IBOutlet weak var reward: UILabel!
    
    var voteStatic: MyVoteStatic? {
        didSet {
            validandinvalidTicketNum.text = String(format: "%d/%d", voteStatic!.validNum,voteStatic!.inValidNum)
            lockedAsset.text = voteStatic!.locktotal.divide(by: ETHToWeiMultiplier, round: 4)
            reward.text = voteStatic!.earnings.divide(by: ETHToWeiMultiplier, round: 4)
        }
    }

}
