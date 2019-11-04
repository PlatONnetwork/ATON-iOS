//
//  AssetHeaderViewV060.swift
//  platonWallet
//
//  Created by juzix on 2019/3/5.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit
import BigInt

let AssetHidingStatus = "AssetHidingStatus"

class AssetHeaderViewV060: UIView {

    @IBOutlet weak var assetTipLabel: UILabel!
    @IBOutlet weak var assetLabel: UILabel!

    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var hideAssetButton: UIButton!

    @IBOutlet weak var menuButton: UIButton!

    @IBOutlet weak var scanButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        initSubviews()

        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateAllAsset), name: Notification.Name.ATON.DidUpdateAllAsset, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(shouldUpdateWalletList), name: Notification.Name.ATON.updateWalletList, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func initSubviews() {

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(WalletCollectionViewCell.self, forCellWithReuseIdentifier: "WalletCollectionViewCell")
        collectionView.register(CreateImportCollectionViewCell.self, forCellWithReuseIdentifier: "CreateImportCollectionViewCell")

        assetTipLabel.font = UIFont.boldSystemFont(ofSize: 18)
        assetLabel.font = UIFont.boldSystemFont(ofSize: 14)

        if let isHide = UserDefaults.standard.object(forKey: AssetHidingStatus) as? Bool {
            updateAssetHiddingStatus(isHide: isHide, syncTopersist: false)
        } else {
            updateAssetHiddingStatus(isHide: false, syncTopersist: false)
        }
    }

    // 余额是否可见
    func updateAssetHiddingStatus(isHide: Bool, syncTopersist: Bool) {
        if syncTopersist {
            UserDefaults.standard.set(isHide, forKey: AssetHidingStatus)
            UserDefaults.standard.synchronize()
        }
        if isHide {
            hideAssetButton.setImage(UIImage(named: "pwdInvisable"), for: .normal)
            assetLabel.text = "--"
            didUpdateAllAsset()
        } else {
            hideAssetButton.setImage(UIImage(named: "pwdvisable"), for: .normal)
            didUpdateAllAsset()
        }
    }

    func updateWalletStatus() {
        collectionView.reloadData()
    }

    var dataSource : [AnyObject] {
        var allWallets : [AnyObject] = []
        allWallets.append(contentsOf: AssetVCSharedData.sharedData.walletList as [AnyObject])
        allWallets.append(Int(0) as AnyObject)
        allWallets.append(Int(1) as AnyObject)
        return allWallets
    }

    @IBAction func OnHideAssets(_ sender: Any) {
        if let isHide = UserDefaults.standard.object(forKey: AssetHidingStatus) as? Bool {
            self.updateAssetHiddingStatus(isHide: !isHide, syncTopersist: true)
        } else {
            self.updateAssetHiddingStatus(isHide: true, syncTopersist: true)
        }
        NotificationCenter.default.post(name: Notification.Name.ATON.DidAssetBalanceVisiableChange, object: nil)
    }
}

extension AssetHeaderViewV060: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let obj = dataSource[indexPath.row]
        if let cwallet = obj as? Wallet {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WalletCollectionViewCell", for: indexPath) as! WalletCollectionViewCell
            cell.wallet = cwallet
            return cell
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CreateImportCollectionViewCell", for: indexPath) as! CreateImportCollectionViewCell
        if let index = obj as? Int {
            cell.index = index
        }

        return cell

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 108, height: 52)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let obj = dataSource[indexPath.row]

        if let i = obj as? Int {
            if i == 0 {
                AssetViewControllerV060.gotoCreateClassicWallet()
            } else {
                AssetViewControllerV060.gotoImportClassicWallet()
            }
            return
        }

        AssetVCSharedData.sharedData.selectedWallet = obj
        collectionView.reloadData()
    }

    // MARK: - Notification

    @objc func didUpdateAllAsset() {

        if let assetIsHide = UserDefaults.standard.object(forKey: AssetHidingStatus) as? Bool {
            if assetIsHide {
                assetLabel.text = "--"
                return
            }
        }

        let total = AssetService.sharedInstace.balances.reduce(BigUInt(0)) { (result, balance) -> BigUInt in
            let freeString = balance.free ?? "0"
            return result + (BigUInt(freeString) ?? BigUInt.zero)
        }

        var totalDes = total.divide(by: ETHToWeiMultiplier, round: 8)
        totalDes = totalDes.balanceFixToDisplay(maxRound: 8)
        assetLabel.text = totalDes
    }

    @objc func shouldUpdateWalletList() {
        didUpdateAllAsset()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }

}
