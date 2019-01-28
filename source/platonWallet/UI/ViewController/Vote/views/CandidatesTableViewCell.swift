//
//  CandidatesTableViewCell.swift
//  platonWallet
//
//  Created by juzix on 2018/12/26.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class CandidatesTableViewCell: UITableViewCell {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var candidateNameLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var descLabel: UILabel!
    
    @IBOutlet weak var leftView: UIView!
    
    @IBOutlet weak var rightView: UIView!
    
    var voteHandler: (()->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func draw(_ rect: CGRect) {
        
        leftView.addMaskView(corners: [.topLeft,.bottomLeft], cornerRadiiV: 4)
        
        rightView.addMaskView(corners: [.topRight,.bottomRight], cornerRadiiV: 4)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func vote(_ sender: Any) {
        voteHandler?()
    }
    
//    func feedData(avatarName: String, candidateName: String, location: String, rewardRate: String, staked: String, onVoteHandler:@escaping (()->Void)) {
//        
//        avatar.image = UIImage(named: avatarName)
//        candidateNameLabel.text = candidateName
//        locationLabel.text = "(\(location))"
//        descLabel.text = Localized("CandidateListVC_cell_desc", arguments: rewardRate, staked)
//        voteHandler = onVoteHandler
//    }
    
    func feedData(_ candidate: Candidate, onVoteHandler:@escaping (()->Void)) {

        avatar.image = UIImage(named: candidate.avatarName)
        candidateNameLabel.text = candidate.extra?.nodeName ?? ""
        locationLabel.text = "(\(candidate.countryName))"
        let rewardRate = String(format: "%.2f%%", Float(candidate.fee ?? 0)/Float(100))
        let staked = (candidate.deposit?.convertToEnergon(round: 4) ?? "-").ATPSuffix()
        descLabel.text = Localized("CandidateListVC_cell_desc", arguments: rewardRate, staked)
        voteHandler = onVoteHandler
    }
}
