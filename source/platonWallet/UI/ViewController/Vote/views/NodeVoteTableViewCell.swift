//
//  NodeVoteTableViewCell.swift
//  platonWallet
//
//  Created by Ned on 26/12/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class NodeVoteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var leftView: UIView!
    
    @IBOutlet weak var rightView: UIView!
    
    @IBOutlet weak var validandinvalidTicketNum: UILabel!
    
    @IBOutlet weak var lockedAsset: UILabel!
    
    @IBOutlet weak var reward: UILabel!
    
    @IBOutlet weak var voteBtn: UIButton!
    
    @IBOutlet weak var avatar: UIImageView!
    
    @IBOutlet weak var nodeName: UILabel!
    
    @IBOutlet weak var location: UILabel!
    
    var candidateId : String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    override func draw(_ rect: CGRect) {
        
        leftView.addMaskView(corners: [.topLeft,.bottomLeft], cornerRadiiV: 4)
        
        rightView.addMaskView(corners: [.topRight,.bottomRight], cornerRadiiV: 4)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateCell(nodeVote: NodeVoteSummary, candidate:Candidate){
        candidateId = nodeVote.CandidateId
        
        nodeName.text = candidate.extra?.nodeName ?? ""
        location.text = "(\(candidate.countryName))"
        
        validandinvalidTicketNum.text = String(format: "%d/%d", nodeVote.validCount,nodeVote.invalidCount)
        lockedAsset.text = nodeVote.assetOflocked?.EnergonSuffix()
        reward.text = nodeVote.voteEarnings
    }
    
}
