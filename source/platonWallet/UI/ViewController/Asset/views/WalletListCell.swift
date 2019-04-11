//
//  WalletListCell.swift
//  platonWallet
//
//  Created by matrixelement on 2018/10/27.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit

class WalletListCell: UITableViewCell {

    @IBOutlet weak var walletName: UILabel!
    
    @IBOutlet weak var coinIcon: UIImageView!
    
    @IBOutlet weak var coinName: UILabel!
    
    @IBOutlet weak var count: UILabel!
    
    @IBOutlet weak var unreadDot: UIView!
    
    @IBOutlet weak var progressView: UIView!
    
    var wallet: AnyObject?
    
    var address : String?
    
    @IBOutlet weak var progressTailing: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        unreadDot.layer.masksToBounds = true
        unreadDot.layer.cornerRadius = 3
        unreadDot.isHidden = true
        
        self.progressView.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateAllAsset), name: Notification.Name(DidUpdateAllAssetNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUnreadDot), name: Notification.Name(WillUpdateUnreadDot_Notification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdatejointWalletProgress), name: NSNotification.Name(DidJointWalletUpdateProgress_Notification), object: nil)
    }
    
    func feedData(_ wallet: AnyObject, count:String) {
        
        self.wallet = wallet
        if let aptWallet = wallet as? Wallet{
            walletName.text = aptWallet.name
            coinName.text = "Energon";
            address = aptWallet.key?.address
            coinIcon.image = UIImage(named: (aptWallet.key?.address.walletAddressLastCharacterAvatar())!)
            unreadDot.isHidden = true
            
        }else if let swallet = wallet as? SWallet{
            walletName.text = swallet.name
            coinName.text = "Energon"; 
            coinIcon.image = UIImage(named: swallet.contractAddress.walletAddressLastCharacterAvatar())
            address = swallet.contractAddress
            unreadDot.isHidden = !STransferPersistence.unreadMessageExistedWithContractAddress((swallet.contractAddress))
        }
        didUpdateAllAsset()
        didUpdatejointWalletProgress()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.progressView.isHidden = true
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Notification
    
    @objc func didUpdateAllAsset() {
        guard address != nil else {
            return
        }
        if let balance = AssetService.sharedInstace.assets[address!]{
            count.text = balance!.descriptionString!.balanceFixToDisplay(maxRound: 8).ATPSuffix()
        }else{
            count.text = "-- Energon"
        }
    }
    
    @objc func updateUnreadDot(){
        if address != nil{
            unreadDot.isHidden = !STransferPersistence.unreadMessageExistedWithContractAddress(address!)
        }
        
    }
    
    @objc func didUpdatejointWalletProgress(){
        
        if let swallet = self.wallet as? SWallet{
            guard swallet.privateKey != nil,(swallet.privateKey?.count)! > 0 else{
                return
            }
            self.progressView.isHidden = false
            UIView.animate(withDuration: 0.2) {
                self.progressTailing.constant = (kUIScreenWidth - CGFloat(24 - 3)) * CGFloat((1.0 - Float(swallet.progress) * Float(0.01)))
                self.layoutIfNeeded()
            }
        }
    }
    
    
    
}
