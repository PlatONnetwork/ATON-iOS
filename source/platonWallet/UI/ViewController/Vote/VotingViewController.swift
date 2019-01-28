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
            }

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSubView()
        endEditingWhileTapBackgroundView = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func initSubView(){
        
        self.navigationItem.localizedText = Localized("VotingViewController_nav_title")
        
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
        popUpVC.setUpContentView(view: view, size: CGSize(width: kUIScreenWidth, height: 289))
        popUpVC.setCloseEvent(button: view.closeBtn)
        view.selectionCompletion = { [weak self] wallet in
            
            guard let self = self else { return }
            
            guard let selectedWallet = wallet as? Wallet else {
                return
            }
            
            guard let asset = AssetService.sharedInstace.assets[selectedWallet.key?.address ?? ""] else {
                return
            }
            
            if asset?.balance ?? BigUIntZero == BigUIntZero {
                self.showMessage(text: "只能选择余额不等于0的钱包", delay: 2)
                popUpVC.onDismissViewController()
                return
            }
            
            self.selectedWallet = selectedWallet
            popUpVC.onDismissViewController()
        }
        popUpVC.show(inViewController: self)
    }
    
    @objc func onVote(){
        
        view.endEditing(true)
        
        showLoading()
        VoteManager.sharedInstance.GetTicketPrice { [weak self] (res, _) in
            
            guard let self = self else {return}
            
            self.hideLoading()
            
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
                guard Int(VoteManager.sharedInstance.ticketPoolRemainder ?? "0")! >= Int(self.votingView.voteNumber.text!)! else {
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
                self.confirmPopUpView.setUpContentView(view: confirmView, size: CGSize(width: kUIScreenWidth, height: 240))
                self.confirmPopUpView.setCloseEvent(button: confirmView.closeBtn)
                confirmView.submitBtn.style = .gray
                confirmView.totalLabel.text = VoteManager.sharedInstance.ticketPrice!.multiplied(by: numOfTickets).convertToEnergon(round: 8).ATPSuffix()
                confirmView.feeLabel.text = TransactionService.service.ethGasPrice!.multiplied(by: BigUInt(deploy_UseStipulatedGas)).convertToEnergon(round: 8).ATPSuffix()
                self.confirmPopUpView.show(inViewController: self)

            case .fail(_, let msg):
                self.showMessage(text: msg ?? "", delay: 2)
            }
 
        }

    }
    
    func showInputPswAlert() {
        
        let alertC = PAlertController(title: Localized("alert_input_psw_title"), message: nil)
        alertC.addTextField(text: "", placeholder: "", isSecureTextEntry: true)
        
        alertC.addAction(title: Localized("alert_cancelBtn_title")) {
        }
        
        alertC.addAction(title: Localized("alert_confirmBtn_title")) { [weak self] in
            self?.showLoading()
            
            WalletService.sharedInstance.exportPrivateKey(wallet: (self!.selectedWallet)!, password: (alertC.textField?.text)!, completion: { (pri, err) in
                if (err == nil && (pri?.length)! > 0) {
                    self?.doVote(pri!)
                }else{
                    self?.hideLoading()
                    self?.showMessage(text: (err?.errorDescription)!, delay: 2)
                }
            })
            
        }
        alertC.show(inViewController: self, animated: false)
        
        alertC.textField?.becomeFirstResponder()
        
    }
    
    func doVote(_ pri: String){
        
        VoteManager.sharedInstance.VoteTicket(count: UInt64(self.votingView.voteNumber!.text!)!, price: VoteManager.sharedInstance.ticketPrice!, nodeId: (self.candidate?.candidateId)!, nodeName: self.candidate?.extra?.nodeName ?? "", sender: (self.selectedWallet?.key?.address)!, privateKey: pri, gasPrice: TransactionService.service.ethGasPrice!, gas: deploy_UseStipulatedGas) { (result, data) in
            self.hideLoading()
            switch result{
            case .success:
                self.navigationController?.popViewController(animated: true)
                UIApplication.rootViewController().showMessage(text: "success", delay: 2)
            case .fail(_, let errMsg):
                self.showMessage(text: errMsg!, delay: 2)
            }
        }
        
    }
    
    @objc func onSubmit() {
        
        confirmPopUpView.onDismissViewController()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.showInputPswAlert()
        }
        
    }
    
}

