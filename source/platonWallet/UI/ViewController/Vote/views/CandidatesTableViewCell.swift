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

    //@IBOutlet weak var avatar: UIImageView!
    
    @IBOutlet weak var candidateNameLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var descLabel: UILabel!
    
    @IBOutlet weak var voteButton: UIButton!
    
    @IBOutlet weak var leftView: UIView!
    
    @IBOutlet weak var rightView: UIView!
    
    @IBOutlet weak var voteLabel: UILabel!
    var voteHandler: (()->Void)?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        voteButton.backgroundColor = .clear
        voteButton.layer.borderColor = UIColor(rgb: 0x105CFE ).cgColor
        voteButton.layer.borderWidth = 1.0
        NotificationCenter.default.addObserver(self, selector: #selector(changeBackground(_:)), name: NSNotification.Name(ChangeCandidatesTableViewCellbackground), object: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        voteButton.layer.cornerRadius = voteButton.frame.size.height * 0.5
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
    

    
    func feedData(_ candidate: Candidate, onVoteHandler:@escaping (()->Void)) {

        candidateNameLabel.text = candidate.extra?.nodeName ?? ""
        locationLabel.text = "(\(candidate.countryName))"
        let rewardRate = candidate.rewardRate
        let staked = (candidate.deposit?.convertToEnergon(round: 4) ?? "-").ATPSuffix()
        descLabel.text = Localized("CandidateListVC_cell_desc", arguments: rewardRate, staked)
        voteHandler = onVoteHandler
    }
    
    @objc func changeBackground(_ notification : Notification){
        guard let color = notification.object as? UIColor else {
            return
        }
        self.backgroundColor = color
        return
    }
}
