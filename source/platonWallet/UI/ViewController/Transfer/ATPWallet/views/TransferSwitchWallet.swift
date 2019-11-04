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

enum WalletListType {
    case ClassWallet, JointWallet, ALL
}

class TransferSwitchWallet: UIView, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var closeBtn: UIButton!

    var selectionCompletion : ((_ wallet: AnyObject?) -> Void)?

    var walletListType: WalletListType = .ClassWallet

    var selectedAddress: String?

    var checkSufficient: Bool = true

    let tableView = UITableView()

    var dataSourse: [AnyObject] = []

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
    }

    func refresh() {
        dataSourse.removeAll()
        if walletListType == .ClassWallet {
            var wallets = AssetVCSharedData.sharedData.walletList.filterClassicWallet
            wallets.userArrangementSort()
            if self.checkSufficient {
                for item in wallets {
                    if item.WalletBalanceStatus() == .Sufficient {
                        dataSourse.append(item)
                    }
                }
            } else {
                dataSourse.append(contentsOf: wallets)
            }

        }
        self.tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourse.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SwitchWalletTableViewCell.self)) as! SwitchWalletTableViewCell
        if walletListType == .ClassWallet {
            guard let wallet = dataSourse[indexPath.row] as? Wallet else {
                return SwitchWalletTableViewCell()
            }

            cell.walletName.text = wallet.name

            if (selectedAddress != nil) && (wallet.address.ishexStringEqual(other: selectedAddress!)) {
                cell.checkIcon.isHidden = false
            } else {
                cell.checkIcon.isHidden = true
            }

            let av = wallet.address.walletAddressLastCharacterAvatar()
            cell.walletIcon.image = UIImage(named: av )?.circleImage()
            cell.walletBalance.text = Localized("transferVC_transfer_balance")  + wallet.balanceDescription()

        } else {
            return SwitchWalletTableViewCell()
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if (selectionCompletion != nil) {
            if walletListType == .ClassWallet {
                let wallet = dataSourse[indexPath.row]
                selectionCompletion!(wallet)
            } else {
                let wallet = dataSourse[indexPath.row]
                selectionCompletion!(wallet)
            }
        }
    }

}
