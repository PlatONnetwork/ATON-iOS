//
//  CandidatesListHeaderView.swift
//  platonWallet
//
//  Created by juzix on 2018/12/25.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import UIKit
import Localize_Swift

fileprivate extension UIImage {
    static func gradientImage(with bounds: CGRect,
                              colors: [CGColor],
                              locations: [NSNumber]?) -> UIImage? {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors
        // This makes it horizontal
        gradientLayer.startPoint = CGPoint(x: 0.0,
                                           y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0,
                                         y: 0.5)
        
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return image
    }
}

class CandidatesListHeaderView: UIView {
  
    @IBOutlet weak var voteRateLabel: UILabel!
    @IBOutlet weak var voteNumberLabel: UILabel!
    @IBOutlet weak var ticketPrice: UILabel!
    
    @IBOutlet weak var myVoteButton: UIButton!
    @IBOutlet weak var iconImg: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var bgImageView: UIImageView!
    private var curTicketPrice: String?
    private var curTicketPriceUpward: Bool = false
    private var curPoll: Int?
    private var curVoteRate: Float?
    
    var gradientImage : UIImage = UIImage()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if progressView.frame.width != 0{
            gradientImage = UIImage.gradientImage(with: progressView.frame,
                                                  colors: [UIColor(rgb: 0x28ADFF).cgColor, UIColor(rgb: 0x105CFE).cgColor],
                                                  locations: nil)!
            self.progressView.progressImage = gradientImage
        }
        
    }
    
    private func initView() {
        
        let view = Bundle.main.loadNibNamed("CandidatesListHeaderView", owner: self, options: nil)?.first as! UIView
        view.layer.cornerRadius = 4
        addSubview(view)
        view.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        self.bgImageView.isUserInteractionEnabled = true
        
        update()
    }
    

    func updateTicketPrice(_ price: String?, isUpward: Bool) {
        
        curTicketPrice = price
        curTicketPriceUpward = isUpward
        update()
    }
    
    func updatePoll(_ poll: Int?, voteRate: Float?) {
        
        curPoll = poll
        curVoteRate = voteRate
        update()
    }
    
    private func update() {
        
        let voteRate = curVoteRate == nil ? "-%":String(format: "%.2f%%", curVoteRate! * 100)
        let poll = curPoll == nil ? "-":"\(curPoll!)"
        let ticketPrice = "\(curTicketPrice ?? "-")".ATPSuffix()
        
        voteRateLabel.text = Localized("CandidateListVC_header_desc", arguments: voteRate, poll, ticketPrice)
        voteRateLabel.text = Localized("CandidateListVC_voteRate_desc", arguments: voteRate)
        voteNumberLabel.text = Localized("CandidateListVC_VoteNumber_desc", arguments: poll)
        self.ticketPrice.text = Localized("CandidateListVC_TicketPrice_desc", arguments: ticketPrice)
        

        
//        iconImg.image = curTicketPriceUpward ? UIImage(named: "vote_triangle_up") : UIImage(named: "vote_triangle_down")
        progressView.progress = curVoteRate ?? 0
        
    }
    
    func updateHeaderViewStyle(_ alpha: CGFloat) {
        ticketPrice.alpha = alpha
        voteNumberLabel.alpha = alpha
        bgImageView.alpha = alpha
        progressView.alpha = alpha
        
        if alpha < 0.2 {
            voteRateLabel.text = Localized("CandidateListVC_title")
            myVoteButton.isHidden = true
        } else {
            let voteRate = curVoteRate == nil ? "-%":String(format: "%.2f%%", curVoteRate! * 100)
            voteRateLabel.text = Localized("CandidateListVC_voteRate_desc", arguments: voteRate)
            myVoteButton.isHidden = false
        }
    }
}
