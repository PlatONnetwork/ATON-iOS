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
    
    func updateView(_ summary: MyVoteStatic){
        validandinvalidTicketNum.text = String(format: "%d/%d", summary.validNum,summary.inValidNum)
        lockedAsset.text = summary.locktotal.divide(by: oneMultiplier, round: 4).EnergonSuffix()
        reward.text = summary.earnings.divide(by: oneMultiplier, round: 4).EnergonSuffix()
    }

}
