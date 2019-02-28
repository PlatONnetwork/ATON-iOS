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

class CandidatesListHeaderView: UIView {
  
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var iconImg: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    
    private var curTicketPrice: String?
    private var curTicketPriceUpward: Bool = false
    private var curPoll: Int?
    private var curVoteRate: Float?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }
    
    private func initView() {
        
        backgroundColor = UIColor(hex: "0x1F2841")
        
        let view = Bundle.main.loadNibNamed("CandidatesListHeaderView", owner: self, options: nil)?.first as! UIView
        view.layer.cornerRadius = 4
        addSubview(view)
        view.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }

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
        
        titleLable.text = Localized("CandidateListVC_header_desc", arguments: voteRate, poll, ticketPrice)
//        iconImg.image = curTicketPriceUpward ? UIImage(named: "vote_triangle_up") : UIImage(named: "vote_triangle_down")
        progressView.progress = curVoteRate ?? 0
        
    }
}
