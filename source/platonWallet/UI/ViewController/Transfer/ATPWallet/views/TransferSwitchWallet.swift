//
//  TransferSwitchWallet.swift
//  platonWallet
//
//  Created by matrixelement on 27/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit

let TransferSwitchWalletHeight = kUIScreenHeight * 0.4

class TransferSwitchWallet: UIView,UITableViewDataSource,UITableViewDelegate {
    
    
    @IBOutlet weak var closeBtn: UIButton!
    
    var selectionCompletion : ((_ wallet : AnyObject?) -> ())?
    
    var type = 0
    
    var selectedAddress : String?
    
    var checkBalance: Bool = true

    let tableView = UITableView()
    override func awakeFromNib() {
        initSubViews()
    }
    
    func initSubViews() {
        addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(40)
            make.leading.trailing.bottom.equalTo(self)
        }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.registerCell(cellTypes: [SwitchWalletTableViewCell.self])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if type == 0{
            return WalletService.sharedInstance.wallets.count
        }
        return SWalletService.sharedInstance.wallets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SwitchWalletTableViewCell.self)) as! SwitchWalletTableViewCell
        if type == 0{
            let wallet = WalletService.sharedInstance.wallets[indexPath.row]
            let balance = AssetService.sharedInstace.assets[(wallet.key?.address)!]
            
            if balance != nil{
                cell.walletBalance.text = (balance?!.displayValueWithRound(round: 8)?.balanceFixToDisplay(maxRound: 8))!.ATPSuffix()
            }
            cell.walletName.text = wallet.name
            
            if (selectedAddress != nil) && (wallet.key?.address.ishexStringEqual(other: selectedAddress!))!{
                cell.checkIcon.isHidden = false
            }else{
                cell.checkIcon.isHidden = true
            }
            
            let av = wallet.key?.address.walletRandomAvatar()
            cell.walletIcon.image = UIImage(named: av ?? "" )?.circleImage()
            if self.checkBalance{
                cell.updateBalanceStyle(balance: balance ?? nil)
            }else{
                cell.contentView.backgroundColor = SwitchWalletCellEnableBG
            }
            
            
        }else{
            let wallet = SWalletService.sharedInstance.wallets[indexPath.row]
            let balance = AssetService.sharedInstace.assets[(wallet.contractAddress)]
            
            if balance != nil{
                cell.walletBalance.text = (balance?!.displayValueWithRound(round: 8)?.balanceFixToDisplay(maxRound: 8))!.ATPSuffix()
            }
            cell.walletName.text = wallet.name
            
            if (selectedAddress != nil) && (wallet.contractAddress.ishexStringEqual(other: selectedAddress!)){
                cell.checkIcon.isHidden = false
            }else{
                cell.checkIcon.isHidden = true
            }
            let av = wallet.contractAddress.walletRandomAvatar()
            cell.walletIcon.image = UIImage(named: av )?.circleImage()
            
            if self.checkBalance{
                cell.updateBalanceStyle(balance: balance ?? nil)
            }else{
                cell.contentView.backgroundColor = SwitchWalletCellEnableBG
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (TransferSwitchWalletHeight - 40) * 0.25
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.checkBalance{
            if type == 0{
                let wallet = WalletService.sharedInstance.wallets[indexPath.row]
                let balance = AssetService.sharedInstace.assets[(wallet.key?.address)!]
                if balance == nil || balance?!.balance == nil || String((balance?!.balance)!) == "0"{
                    return
                }
                
            }else{
                let wallet = SWalletService.sharedInstance.wallets[indexPath.row]
                let balance = AssetService.sharedInstace.assets[(wallet.contractAddress)]
                if balance == nil || balance?!.balance == nil || String((balance?!.balance)!) == "0"{
                    return
                }
            }
        }
        
        if (selectionCompletion != nil) {
            if type == 0{
                let wallet = WalletService.sharedInstance.wallets[indexPath.row]
                selectionCompletion!(wallet)
            }else{
                let wallet = SWalletService.sharedInstance.wallets[indexPath.row]
                selectionCompletion!(wallet)
            }
        }
    }

}
