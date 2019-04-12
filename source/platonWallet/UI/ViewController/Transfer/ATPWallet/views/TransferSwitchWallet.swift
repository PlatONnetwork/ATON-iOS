//
//  TransferSwitchWallet.swift
//  platonWallet
//
//  Created by matrixelement on 27/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift

let TransferSwitchWalletHeight = kUIScreenHeight * 0.4

class TransferSwitchWallet: UIView,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var closeBtn: UIButton!
    
    var selectionCompletion : ((_ wallet : AnyObject?) -> ())?
    
    var switchType = 0
    
    var selectedAddress : String?
    
    var checkBalance: Bool = true

    let tableView = UITableView()
    
    var dataSourse : [AnyObject] = []
    
    override func awakeFromNib() {
        initSubViews()
        self.closeBtn.isHidden = true
    }
    
    func initSubViews() {
        addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(51)
            make.leading.trailing.bottom.equalTo(self)
        }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.registerCell(cellTypes: [SwitchWalletTableViewCell.self])
        self.refresh()
    } 
    
    func refresh(){
        dataSourse.removeAll()
        if switchType == 0{ 
            var wallets = AssetVCSharedData.sharedData.walletList.filterClassicWallet
            wallets.userArrangementSort()
            for item in wallets{
                if item.WalletBalanceStatus() == .Sufficient{
                    dataSourse.append(item)
                }
            }
        }else{
            for item in SWalletService.sharedInstance.wallets{
                if item.WalletBalanceStatus() == .Sufficient{
                    dataSourse.append(item)
                }
            }
        }
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourse.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SwitchWalletTableViewCell.self)) as! SwitchWalletTableViewCell
        if switchType == 0{
            guard let wallet = dataSourse[indexPath.row] as? Wallet else{
                return SwitchWalletTableViewCell()
            }
        
            cell.walletName.text = wallet.name
            
            if (selectedAddress != nil) && (wallet.key?.address.ishexStringEqual(other: selectedAddress!))!{
                cell.checkIcon.isHidden = false
            }else{
                cell.checkIcon.isHidden = true
            }
            
            let av = wallet.key?.address.walletAddressLastCharacterAvatar()
            cell.walletIcon.image = UIImage(named: av ?? "" )?.circleImage()
            cell.walletBalance.text = Localized("transferVC_transfer_balance")  + wallet.balanceDescription()
            
        }else{
            guard let wallet = dataSourse[indexPath.row] as? SWallet else{
                return SwitchWalletTableViewCell()
            }
            cell.walletName.text = wallet.name
            
            if (selectedAddress != nil) && (wallet.contractAddress.ishexStringEqual(other: selectedAddress!)){
                cell.checkIcon.isHidden = false
            }else{
                cell.checkIcon.isHidden = true
            }
            let av = wallet.contractAddress.walletAddressLastCharacterAvatar()
            cell.walletIcon.image = UIImage(named: av )?.circleImage()
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (selectionCompletion != nil) {
            if switchType == 0{
                let wallet = dataSourse[indexPath.row]
                selectionCompletion!(wallet)
            }else{
                let wallet = dataSourse[indexPath.row]
                selectionCompletion!(wallet)
            }
        }
    }

}
