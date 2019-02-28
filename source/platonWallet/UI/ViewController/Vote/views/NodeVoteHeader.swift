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
    
    var tickets : [Ticket] = []
    
    
    func updateView(_ summary: [NodeVoteSummary]){
        
        tickets.removeAll()
        let _ = summary.map { sum in
            tickets.append(contentsOf: sum.tickets)
        }
        
        validandinvalidTicketNum.text = String(format: "%d/%d", tickets.validTicketCount,tickets.invalidTicketCount)
        lockedAsset.text = tickets.lockedAssetSum.divide(by: ETHToWeiMultiplier, round: 4).EnergonSuffix()
        reward.text = self.tickets.tickets_voteEarnings?.EnergonSuffix()
    }

}
