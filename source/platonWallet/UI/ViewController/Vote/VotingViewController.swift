//
//  VotingViewController.swift
//  platonWallet
//
//  Created by Ned on 27/12/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift
import BigInt

class VotingViewController0 : BaseViewController {
    
    let votingView = UIView.viewFromXib(theClass: VotingView.self) as! VotingView
    
    var confirmPopUpView:PopUpViewController!
    
    var candidate : Candidate?
    
    var selectedWallet : Wallet?{
        didSet{
            votingView.walletName.text = selectedWallet?.name
            if let balance = AssetService.sharedInstace.assets[(selectedWallet!.key?.address)!] {
                votingView.walletAddress.text = Localized("walletDetailVC_balance") +  (balance!.displayValueWithRound(round: 8)?.balanceFixToDisplay(maxRound: 8))!.ATPSuffix()
                
                let av = selectedWallet?.key?.address.walletAddressLastCharacterAvatar()
                votingView.walletAvatar.image = UIImage(named: av!)?.circleImage()
            }

        }
    }
    
//    var voteCompletion: (() -> Void)?
    var votedCompletion: ((_ ticketPrice: BigUInt?, _ voteNumber: UInt64?) -> ())?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSubView()
        endEditingWhileTapBackgroundView = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func initSubView(){
        
        super.leftNavigationTitle = "VotingViewController_nav_title"
        
        self.view.addSubview(votingView)
        votingView.snp.makeConstraints({ (make) in
            make.edges.equalTo(self.view)
        })
        
        votingView.switchWalletBtn.addTarget(self, action: #selector(onSwitchWallet), for: .touchUpInside)
        votingView.confirmBtn.addTarget(self, action: #selector(onVote), for: .touchUpInside)
        
        for wallet in WalletService.sharedInstance.wallets {
            if let balance = AssetService.sharedInstace.assets[wallet.key!.address] {
                if balance!.balance ?? BigUIntZero > BigUIntZero {
                    selectedWallet = wallet
                    break;
                }
            }
        }
        
        if candidate != nil{
            votingView.updateWithCandidate(candidate: candidate!)
        }
        
    }
    
    @objc func onSwitchWallet(){
        
        let popUpVC = PopUpViewController()
        let view = UIView.viewFromXib(theClass: TransferSwitchWallet.self) as! TransferSwitchWallet
        view.selectedAddress = selectedWallet?.key?.address
        view.refresh()
        popUpVC.setUpContentView(view: view, size: CGSize(width: PopUpContentWidth, height: 289))
        popUpVC.setCloseEvent(button: view.closeBtn)
        view.selectionCompletion = { [weak self] wallet in
            
            guard let self = self else { return }
            
            guard let selectedWallet = wallet as? Wallet else {
                return
            }
            self.selectedWallet = selectedWallet
            popUpVC.onDismissViewController()
        }
        popUpVC.show(inViewController: self)
    }
     
    @objc func onVote(){
        
        view.endEditing(true)
        
        showLoadingHUD()
        VoteManager.sharedInstance.GetTicketPrice { [weak self] (res, _) in
            
            guard let self = self else {return}
            
            self.hideLoadingHUD()
            
            switch res{
            case .success:
                
                guard let wallet = self.selectedWallet else {
                    return
                }
                guard let asset = AssetService.sharedInstace.assets[wallet.key?.address ?? ""] else {
                    return
                }
                guard let ticketPrice = VoteManager.sharedInstance.ticketPrice else {
                    return
                }
                guard let numOfTickets = BigUInt(self.votingView.voteNumber!.text!) else {
                    return
                }
                
                guard ticketPrice.multiplied(by: numOfTickets) <= (asset?.balance)! else {
                    self.showMessage(text: Localized("VotingViewController_insufficient_balance_tips"), delay: 3)
                    return
                }
                
                guard VoteManager.sharedInstance.ticketPoolRemainder ?? 0 >= Int(self.votingView.voteNumber.text!)! else {
                    self.showMessage(text: Localized("VotingViewController_exceed_limit_tips"), delay: 3)
                    return
                }
                
                guard TransactionService.service.ethGasPrice != nil else{
                    self.showMessage(text: Localized("RPC_Response_serverError"), delay: 3)
                    TransactionService.service.getEthGasPrice(completion: nil)
                    return
                } 
                 
                self.confirmPopUpView = PopUpViewController()
                let confirmView = UIView.viewFromXib(theClass: VoteConfirmView.self) as! VoteConfirmView
                confirmView.submitBtn.addTarget(self, action: #selector(self.onSubmit), for: .touchUpInside)
                self.confirmPopUpView.setUpContentView(view: confirmView, size: CGSize(width: PopUpContentWidth, height: 325))
                self.confirmPopUpView.setCloseEvent(button: confirmView.closeBtn)
                confirmView.totalLabel.text = VoteManager.sharedInstance.ticketPrice!.multiplied(by: numOfTickets).convertToEnergon(round: 8)
                confirmView.walletName.text = self.selectedWallet?.name
                confirmView.feeLabel.text = TransactionService.service.ethGasPrice!.multiplied(by: BigUInt(deploy_UseStipulatedGas)).convertToEnergon(round: 8).ATPSuffix()
                self.confirmPopUpView.show(inViewController: self)

            case .fail(_, let msg):
                self.showMessage(text: msg ?? "", delay: 2)
            }
 
        }

    }
    
    
    func showPasswordInputPswAlert() {
        
        let alertVC = AlertStylePopViewController.initFromNib()
        self.passwordInputAlert = alertVC
        let style = PAlertStyle.passwordInput(walletName: self.selectedWallet?.name) 
        alertVC.onAction(confirm: {[weak self] (text, _) -> (Bool)  in
            let valid = CommonService.isValidWalletPassword(text ?? "")
            if !valid.0{ 
                alertVC.showInputErrorTip(string: valid.1)
                return false
            }
            alertVC.showLoadingHUD()
            WalletService.sharedInstance.exportPrivateKey(wallet: self!.selectedWallet!, password: (alertVC.textFieldInput?.text)!, completion: { (pri, err) in
                if (err == nil && (pri?.length)! > 0) {
                    self?.doVote(pri!)
                    alertVC.dismissWithCompletion()
                }else{
                    alertVC.hideLoadingHUD()
                    alertVC.showInputErrorTip(string: (err?.errorDescription)!)
                    //self?.showMessage(text: (err?.errorDescription)!)
                }
            })
            return false
            
        }) { (_, _) -> (Bool) in
            return true
        }
        alertVC.style = style
        alertVC.showInViewController(viewController: self)
        return
    }
    
    func doVote(_ pri: String){

        self.showLoadingHUD()
        VoteManager.sharedInstance.VoteTicket(count: UInt64(self.votingView.voteNumber!.text!)!, price: VoteManager.sharedInstance.ticketPrice!, nodeId: (self.candidate?.candidateId)!, sender: (self.selectedWallet?.key?.address)!, privateKey: pri, gasPrice: TransactionService.service.ethGasPrice!, gas: deploy_UseStipulatedGas) {[weak self] (result, data) in
            self?.hideLoadingHUD()
            
            DispatchQueue.main.async {
                self?.votedCompletion?(VoteManager.sharedInstance.ticketPrice, UInt64(self!.votingView.voteNumber!.text!)!)
//                self?.voteCompletion?()
            }
            
            switch result{
            case .success:
                self?.navigationController?.popViewController(animated: true)
                UIApplication.rootViewController().showMessage(text: Localized("VotingViewController_success_tips"), delay: 2)
            case .fail(_, let errMsg):
                self?.showMessage(text: errMsg!, delay: 2)
            }
        }
        
    }
    
    @objc func onSubmit() {
        
        confirmPopUpView.onDismissViewController()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.showPasswordInputPswAlert()
        }
        
    }
    
}

