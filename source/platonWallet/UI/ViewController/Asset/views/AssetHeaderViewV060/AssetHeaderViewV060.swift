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
    
    
    
    func initSubviews() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ClassicWalletCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ClassicWalletCollectionViewCell")
        collectionView.register(UINib(nibName: "CreateAndInputWalletCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CreateAndInputWalletCollectionViewCell")
        
        
        if let isHide = UserDefaults.standard.object(forKey: AssetHidingStatus) as? Bool{
            self.updateAssetHiddingStatus(isHide: isHide, syncTopersist: false)
        }else{
            self.updateAssetHiddingStatus(isHide: false, syncTopersist: false)
        }
    }
    
    func updateAssetHiddingStatus(isHide: Bool, syncTopersist: Bool){
        if syncTopersist{
            UserDefaults.standard.set(isHide, forKey: AssetHidingStatus)
            UserDefaults.standard.synchronize()
        }
        if isHide{
            hideAssetButton.setImage(UIImage(named: "pwdInvisable"), for: .normal)
            assetLabel.text = "--"
            self.didUpdateAllAsset()
        }else{
            hideAssetButton.setImage(UIImage(named: "pwdvisable"), for: .normal)
            self.didUpdateAllAsset()
        }

        
    }
    
    var dataSource : [AnyObject]{
        var allWallets : [AnyObject] = []
        allWallets.append(contentsOf: AssetVCSharedData.sharedData.walletList as [AnyObject])
        allWallets.append(Int(0) as AnyObject)
        allWallets.append(Int(1) as AnyObject)
        return allWallets
    }
    
    @IBAction func OnHideAssets(_ sender: Any) {
        if let isHide = UserDefaults.standard.object(forKey: AssetHidingStatus) as? Bool{
            self.updateAssetHiddingStatus(isHide: !isHide, syncTopersist: true)
        }else{
            self.updateAssetHiddingStatus(isHide: true, syncTopersist: true)
        }
    }
    

}

extension AssetHeaderViewV060: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let obj = dataSource[indexPath.row]
        if let cwallet = obj as? Wallet{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ClassicWalletCollectionViewCell", for: indexPath) as! ClassicWalletCollectionViewCell
            cell.updateWallet(walletObj: cwallet)
            return cell
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CreateAndInputWalletCollectionViewCell", for: indexPath) as! CreateAndInputWalletCollectionViewCell
        if let obj = obj as? Int{
            cell.updateCell(index: obj)
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
        
        if let i = obj as? Int{
            if i == 0{
                AssetViewControllerV060.gotoCreateClassicWallet()
            }else{
                AssetViewControllerV060.gotoImportClassicWallet()
            }
            return
        }

        AssetVCSharedData.sharedData.selectedWallet = obj
        collectionView.reloadData()
    }
 
    
    
    
    // MARK: - Notification
    
    @objc func didUpdateAllAsset(){
    
        if let assetIsHide = UserDefaults.standard.object(forKey: AssetHidingStatus) as? Bool{
            if assetIsHide{
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
    
    @objc func shouldUpdateWalletList(){
        didUpdateAllAsset()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }

}
