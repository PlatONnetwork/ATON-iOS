//
//  NodeVoteTableViewCell.swift
//  platonWallet
//
//  Created by Ned on 26/12/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift
import BigInt

class NodeVoteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var validandinvalidTicketNum: UILabel!
    
    @IBOutlet weak var lockedAsset: UILabel!
    
    @IBOutlet weak var reward: UILabel!
    
    @IBOutlet weak var voteBtn: UIButton!
    
    @IBOutlet weak var middleDashsepline: UILabel!
    
    @IBOutlet weak var nodeName: UILabel!
    
    @IBOutlet weak var location: UILabel!
    
    var candidateId : String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        let lineLayer = CAShapeLayer()
        lineLayer.strokeColor = UIColor(rgb: 0xE4E7F3).cgColor
        lineLayer.lineWidth = 1
        lineLayer.lineDashPattern = [4,4]
        let path = CGMutablePath()
        path.addLines(between: [CGPoint(x: 0, y: 0),CGPoint(x: kUIScreenWidth - 16, y: 0)])
        lineLayer.path = path
        self.middleDashsepline.layer.addSublayer(lineLayer)
        
        voteBtn.backgroundColor = .clear
        voteBtn.layer.borderColor = UIColor(rgb: 0x105CFE ).cgColor
        voteBtn.layer.borderWidth = 1.0
    }
    
  
    override func layoutSubviews() {
        super.layoutSubviews()
        voteBtn.layer.cornerRadius = voteBtn.frame.size.height * 0.5
    }
    
    override func draw(_ rect: CGRect) {
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateCell(nodeVote: NodeVoteSummary, candidate:CandidateBasicInfo){
        candidateId = nodeVote.CandidateId
        nodeName.text = candidate.name ?? ""
        let ipInfo = IPGeoPersistence.getIpInfo(candidate.host ?? "")
        location.text = "(\(ipInfo.localizeCountryName ?? Localized("IP_location_unknown")))"
        validandinvalidTicketNum.text = String(format: "%d/%d", nodeVote.validCount,nodeVote.invalidCount)
        
        let lockedB = BigUInt(nodeVote.assetOflocked ?? "0")!
        let lockedS = lockedB.divide(by: ETHToWeiMultiplier, round: 8)
        lockedAsset.text = lockedS
        let earningsDes = BigUInt.safeInit(str: nodeVote.voteEarnings).divide(by: ETHToWeiMultiplier, round: 8)
        reward.text = earningsDes
    }
    
}
