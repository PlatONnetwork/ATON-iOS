//
//  CandidateDetailViewController.swift
//  platonWallet
//
//  Created by juzix on 2018/12/26.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift

class CandidateDetailViewController: BaseViewController {
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var candidateNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var joinTimeLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var stakedLabel: UILabel!
    @IBOutlet weak var ticketsLabel: UILabel!
    @IBOutlet weak var ticketAgeLabel: UILabel!
    
    @IBOutlet weak var nodeUrlLabel: UILabel!
    @IBOutlet weak var nodeIdLabel: UILabel!
    @IBOutlet weak var rewardRatioLabel: UILabel!
    @IBOutlet weak var institutionalNameLabel: UILabel!
    @IBOutlet weak var institutionalWebsiteLabel: UILabel!
    @IBOutlet weak var nodeInfoLabel: UILabel!
    
    var candidate: Candidate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Localized("CandidateDetailVC_title")
        institutionalWebsiteLabel.isUserInteractionEnabled = true
        let tapG = UITapGestureRecognizer(target: self, action: #selector(openUrl(_:)))
        institutionalWebsiteLabel.addGestureRecognizer(tapG)
        setup()
        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let shapeL = CAShapeLayer()
        shapeL.path = UIBezierPath(roundedRect: headerView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 4, height: 4)).cgPath
        shapeL.shadowColor = UIColor(rgb: 0x020527, alpha: 0.2).cgColor
        shapeL.shadowOffset = CGSize(width: 0, height: 2)
        shapeL.shadowOpacity = 1
        shapeL.shadowRadius = 3
        headerView.layer.mask = shapeL
    }
    
    private func setup() {
        
        avatar.image = candidate.avatar
        candidateNameLabel.text = candidate.extra?.nodeName
        locationLabel.text = "(\(candidate.countryName))"
        statusLabel.text = candidate.rankStatus.desc()
        
        joinTimeLabel.text = Localized("CandidateDetailVC_joinTime", arguments: Date(milliseconds: candidate.extra?.time ?? 0).toFormatter("yyyy-MM-dd HH:mm:ss"))
        
        
        rankLabel.text = "\(candidate.rankByDeposit!)"
        stakedLabel.text = (candidate.deposit?.convertToEnergon(round: 4) ?? "-").ATPSuffix()
        ticketsLabel.text = "\(candidate.tickets ?? 0)"
        
        if let host = candidate.host, host.length > 0, let port = candidate.port, port.length > 0 {
            nodeUrlLabel.text = "\(host):\(port)"
        }
        
        nodeIdLabel.text = candidate.candidateId!.hasPrefix("0x") ? candidate.candidateId!:"0x\(candidate.candidateId!)"
        rewardRatioLabel.text = String(format: "%.2f%%", Float((candidate.fee ?? 0) / 100))
        institutionalNameLabel.text = candidate.extra?.nodeDepartment
        institutionalWebsiteLabel.text = candidate.extra?.officialWebsite
        nodeInfoLabel.text = candidate.extra?.nodeDiscription
        
        VoteManager.sharedInstance.GetCandidateEpoch(candidateId: candidate.candidateId!) { (res, data) in
            self.ticketAgeLabel.text = "\(data as? String ?? "-")Bs"
        }
    }
    

    @IBAction func vote(_ sender: Any) {
        
        let res = VoteManager.sharedInstance.checkMyWalletBalanceIsEnoughToVote()
        guard res.canVote else {
            self.showMessage(text: res.errMsg, delay: 3)
            return
        }
        
        let votingVC = VotingViewController0()
        votingVC.candidate = candidate
        navigationController?.pushViewController(votingVC, animated: true)
        
        
    }
    
    @objc func openUrl(_ sender: UIGestureRecognizer) {
        
        guard let url = URL(string: institutionalWebsiteLabel.text ?? "") else {
            return
        }
        
        if #available(iOS 10.0, *) {
            
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            
            UIApplication.shared.openURL(url)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
