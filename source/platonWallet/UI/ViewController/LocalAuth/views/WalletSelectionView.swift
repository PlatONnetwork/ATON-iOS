//
//  WalletSelectionView.swift
//  platonWallet
//
//  Created by matrixelement on 2018/11/6.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit

class WalletSelectionView: UIView {

    @IBOutlet weak var tableView: UITableView!
    
    var wallets = WalletService.sharedInstance.wallets
    
    var currentSelectedWallet: Wallet!
    
    var onBackHandler: (()->Void)?
    
    var onSelectedHandler: ((Wallet)->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = UIColor(rgb: 0xEAEAEA)
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.register(UINib(nibName: "WalletSelectionTableViewCell", bundle: nil), forCellReuseIdentifier: "WalletSelectionTableViewCell")
        tableView.tableFooterView = UIView()
    }
    
    @IBAction func back(_ sender: Any) {
        onBackHandler?()
    }
    
    public static func show(inViewController vc: UIViewController, lastSelectedWallet: Wallet, selectedHandler:@escaping (Wallet) -> Void) {
        
        let popVC = PopUpViewController()
        let height:CGFloat = (44 + CGFloat(60 * min(WalletService.sharedInstance.wallets.count, 4)))
        let view = UIView.viewFromXib(theClass: WalletSelectionView.self) as! WalletSelectionView
        view.currentSelectedWallet = lastSelectedWallet
        view.onBackHandler = {[weak popVC] in
            popVC?.onDismissViewController()
        }
        view.onSelectedHandler = selectedHandler
        popVC.setUpContentView(view: view, size: CGSize(width: kUIScreenWidth, height: height))
        popVC.show(inViewController: vc)
    }
    
}


extension WalletSelectionView : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wallets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WalletSelectionTableViewCell", for: indexPath) as! WalletSelectionTableViewCell
        let wallet = wallets[indexPath.row]
        let isSelected = wallet.key?.address == currentSelectedWallet.key?.address
        cell.feedData(wallet, isSelected: isSelected)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onSelectedHandler?(wallets[indexPath.row])
        onBackHandler?()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
