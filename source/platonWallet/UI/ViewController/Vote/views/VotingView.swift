//
//  VotingView.swift
//  platonWallet
//
//  Created by Ned on 27/12/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import BigInt

class VotingView: UIView ,UITextFieldDelegate{

    @IBOutlet weak var nodeNameLabel: UILabel!
    
    @IBOutlet weak var nodeIdLabel: UILabel!
    
    @IBOutlet weak var walletName: UILabel!
    
    @IBOutlet weak var walletAddress: UILabel!
    
    @IBOutlet weak var switchWalletBtn: UIButton!
    
    @IBOutlet weak var voteNumber: UITextField!
    
    @IBOutlet weak var decreaseBtn: UIButton!
    
    @IBOutlet weak var increaseBtn: UIButton!
    
    @IBOutlet weak var ticketPrice: UILabel!
    
    @IBOutlet weak var totalPayment: UILabel!
    
    @IBOutlet weak var confirmBtn: UIButton!
    
    @IBOutlet weak var voteButton: PButton!
    
    @IBOutlet weak var walletAvatar: UIImageView!
    
    
    override func awakeFromNib() {
        initSubViews()
        voteNumber.delegate = self
        voteButton.style = .blue
    }
    
    func initSubViews(){
        switchWalletBtn.setupSwitchWalletStyle()
        ticketPrice.text =        (VoteManager.sharedInstance.ticketPrice?.convertToEnergon(round: 4) ?? "-").ATPSuffix()
        updateTotalPayment(numOfTickets: voteNumber.text!)
    }
    
    func updateWithCandidate(candidate: Candidate){
        nodeNameLabel.text = candidate.extra?.nodeName
        nodeIdLabel.text = candidate.candidateId?.add0x()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let text = textField.text,let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            
            if string == "" || (updatedText.ispureUint() && !updatedText.reachMaxVoteTicketsNumber(remained: self.getRemainMaxTicketForVote())){
                updateTotalPayment(numOfTickets: updatedText)
                return true
            }
            
        }
        
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField.text == nil || textField.text! == "" {
            textField.text = "1"
            updateTotalPayment(numOfTickets: voteNumber.text!)
        }
        
    }
    
    
    @IBAction func onDecrease(_ sender: Any) {
        
        if (voteNumber.text?.length == 0){
            return
        }
        
        var inputVoteNum = UInt64(voteNumber.text!) ?? 0
        if (inputVoteNum <= 1){
            return
        }
        
        inputVoteNum -= 1
        voteNumber.text = String(format: "%lld", inputVoteNum)
        
        updateTotalPayment(numOfTickets: voteNumber.text!)
        
    }
    
    
    @IBAction func onIncrease(_ sender: Any) {
        
        if (voteNumber.text?.length == 0){
            voteNumber.text = "1"
            updateTotalPayment(numOfTickets: voteNumber.text!)
            return
        }
        
        var inputVoteNum = UInt64(voteNumber.text!) ?? 0
        if (inputVoteNum >= self.getRemainMaxTicketForVote()){
            return
        }
        
        inputVoteNum += 1
        voteNumber.text = String(format: "%lld", inputVoteNum)
        
        updateTotalPayment(numOfTickets: voteNumber.text!)
        
    }
    
    func getRemainMaxTicketForVote() -> UInt64{
        //todo
        return 52000
    }

    func updateTotalPayment(numOfTickets: String) {

        guard let ticketPrice = VoteManager.sharedInstance.ticketPrice, Int(numOfTickets) != nil else {
            totalPayment.text = "-".ATPSuffix()
            return;
        }

        totalPayment.text = ticketPrice.multiplied(by: BigUInt(numOfTickets)!).convertToEnergon(round: 4).ATPSuffix()
    }


}
