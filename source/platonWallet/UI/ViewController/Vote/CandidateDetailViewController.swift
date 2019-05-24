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
    
    @IBOutlet weak var voteButton: PButton!
    var candidate: Candidate!
    
    lazy var headerShadowLayer : CALayer = {
        let shadowL = CALayer()
        shadowL.cornerRadius = 4.0
        shadowL.frame = headerView.frame
        shadowL.backgroundColor = UIViewController_backround.cgColor
        shadowL.shadowColor = UIColor(rgb: 0x020527, alpha: 0.2).cgColor
        shadowL.shadowOffset = CGSize(width: 0, height: 2)
        shadowL.shadowOpacity = 1
        shadowL.shadowRadius = 3
        return shadowL
    }()
    
    lazy var candidateRankBgLayer : CALayer = {
        let bglayer = CALayer()
        bglayer.cornerRadius = 2
        bglayer.frame = CGRect(x: -4, y: -4, width: statusLabel.frame.size.width + 8, height: statusLabel.frame.size.height + 8)
        bglayer.backgroundColor = UIViewController_backround.cgColor
        bglayer.backgroundColor = UIColor(rgb: 0x256AFE, alpha: 0.2).cgColor
        //bglayer.shadowColor = UIColor(rgb: 0x020527, alpha: 0.2).cgColor
        return bglayer
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
         
        voteButton.style = .blue
        super.leftNavigationTitle = "CandidateDetailVC_title"
        institutionalWebsiteLabel.isUserInteractionEnabled = true
        let tapG = UITapGestureRecognizer(target: self, action: #selector(openUrl(_:)))
        institutionalWebsiteLabel.addGestureRecognizer(tapG)
        setup()
        // Do any additional setup after loading the view.
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let shapeL = CAShapeLayer()
        shapeL.path = UIBezierPath(roundedRect: headerView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 4, height: 4)).cgPath
        headerView.layer.mask = shapeL
        
        headerShadowLayer.frame = headerView.frame
        if statusLabel.layer.sublayers != nil && !statusLabel.layer.sublayers!.contains(candidateRankBgLayer){
            statusLabel.layer.insertSublayer(candidateRankBgLayer, at: 0)
        }
        /*
        if !view.layer.sublayers!.contains(headerShadowLayer) {
            headerView.superview!.layer.insertSublayer(headerShadowLayer, at: 0)
        }
         */
    }
    
    private func setup() {
        candidateNameLabel.text = candidate.name
        locationLabel.text = "(\(candidate.countryName))"
        statusLabel.text = candidate.nodeType?.desc()
        
        joinTimeLabel.text = Localized("CandidateDetailVC_joinTime", arguments: Date(milliseconds: UInt64(candidate.joinTime)).toFormatter("yyyy-MM-dd HH:mm:ss"))
        
        
        rankLabel.text = "\(candidate.rankByDeposit!)"
        stakedLabel.text = (candidate.deposit?.convertToEnergon(round: 4) ?? "-").ATPSuffix()
        ticketsLabel.text = "\(candidate.ticketCount ?? 0)"
        
        if let url = candidate.nodeUrl {
            nodeUrlLabel.text = url
        }

        nodeIdLabel.text = candidate.candidateId!.hasPrefix("0x") ? candidate.candidateId!:"0x\(candidate.candidateId!)"
        rewardRatioLabel.text = candidate.rewardRate
        institutionalNameLabel.text = candidate.orgName
        institutionalWebsiteLabel.text = candidate.orgWebsite
        nodeInfoLabel.text = candidate.intro
         
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
