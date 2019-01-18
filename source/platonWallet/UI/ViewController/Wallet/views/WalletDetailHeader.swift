//
//  WalletDetailHeader.swift
//  platonWallet
//
//  Created by matrixelement on 18/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit

enum SWalletType : Int{
    case ownerAccount
    case watchAccount
    
}

extension NSLayoutConstraint {
    
    func setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {
        
        NSLayoutConstraint.deactivate([self])
        
        let newConstraint = NSLayoutConstraint(
            item: firstItem,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = shouldBeArchived
        newConstraint.identifier = identifier
        
        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}

class WalletDetailHeader: UIView {

    @IBOutlet weak var voteBtn: UIButton!
    @IBOutlet weak var recvBtn: UIButton!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var copyButton: CopyButton!
    
    @IBOutlet weak var verticalSep1: UIView!
    
    @IBOutlet weak var verticalSep2: UIView!
    
    @IBOutlet weak var recvWidth: NSLayoutConstraint!
    
    @IBOutlet weak var sendWidth: NSLayoutConstraint!
    
    @IBOutlet weak var voteWidth: NSLayoutConstraint!
    
    @IBOutlet weak var buttonBG: UILabel!
    
    override func awakeFromNib() {
        copyButton.attachTextView = addressLabel
        buttonBG.addMaskView(corners: [.bottomRight,.bottomLeft], cornerRadiiV: 10)
    }
    
    func setSWalletType(_ type: SWalletType){
        
        if type == .ownerAccount{
            let _ = recvWidth.setMultiplier(multiplier: 0.48)
            let _ = sendWidth.setMultiplier(multiplier: 0.48)
            let _ = voteWidth.setMultiplier(multiplier: 0.001)
            verticalSep2.isHidden = true
            voteBtn.isHidden = true
        }else if type == .watchAccount{
            let _ = recvWidth.setMultiplier(multiplier: 0.99)
            let _ = sendWidth.setMultiplier(multiplier: 0.001)
            let _ = voteWidth.setMultiplier(multiplier: 0.001)
            verticalSep2.isHidden = true
            verticalSep1.isHidden = true
            voteBtn.isHidden = true
            sendBtn.isHidden = true
        }
    }
    
    func enableVoteBtn(_ enable : Bool){
        if enable{
            let _ = recvWidth.setMultiplier(multiplier: 0.29)
            let _ = sendWidth.setMultiplier(multiplier: 0.29)
            let _ = voteWidth.setMultiplier(multiplier: 0.29)
            verticalSep2.isHidden = false
            voteBtn.isHidden = false
        }else{
            let _ = recvWidth.setMultiplier(multiplier: 0.48)
            let _ = sendWidth.setMultiplier(multiplier: 0.48)
            let _ = voteWidth.setMultiplier(multiplier: 0.001)
            verticalSep2.isHidden = true
            voteBtn.isHidden = true
        }
    }
    
    override func layoutSubviews() {
    }
}
