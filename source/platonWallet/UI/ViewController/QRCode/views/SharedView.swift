//
//  SharedView.swift
//  platonWallet
//
//  Created by matrixelement on 6/11/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Foundation

let itemHorizontalCount = 4
let itemHorizontalSpacing = 20
let containerEdge = 25
let itemratio = 1.3

let itemWidth = (kUIScreenWidth - CGFloat(containerEdge) * 2 - CGFloat((itemHorizontalSpacing * (itemHorizontalCount - 1))))/CGFloat(itemHorizontalCount)

class SharedView: UIView ,UICollectionViewDelegate,UICollectionViewDataSource{

    let closeBtn = UIButton(type: .custom)
    
    var collectionView : UICollectionView?
    let Identifier       = "SharedCollectionViewCell"

    //let titles = ["SharedWechatFriend","SharedWechatMoment","SharedQQ","SharedWeibo","SharedFacebook","SharedTwitter","SharedMore"]

    var titles : [String] = []
    var imgs : [String] = []
    var urlschemes : [String] = []

    public class func getSharedViewHeight() -> CGFloat{
        return 44 + itemWidth * CGFloat(itemratio) * 2 + CGFloat(itemHorizontalSpacing * 2)
    }

    override init(frame: CGRect) {
        
        
        super.init(frame: frame)
        
        self.initData()
        
        let layout = UICollectionViewFlowLayout.init()

        layout.itemSize = CGSize(width: itemWidth, height: itemWidth * CGFloat(itemratio))
        layout.minimumLineSpacing = CGFloat(itemHorizontalSpacing)
        layout.minimumInteritemSpacing = CGFloat(itemHorizontalSpacing)
        layout.scrollDirection = .vertical
        //layout.sectionInset = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        
        collectionView = UICollectionView.init(frame: CGRect(x:0, y:0, width:0, height:0), collectionViewLayout: layout)
        collectionView?.backgroundColor = UIColor.white
        collectionView?.delegate = self
        collectionView?.dataSource = self
        self.addSubview(collectionView!)
        collectionView?.snp.makeConstraints({ (make) in
            make.top.equalTo(self).offset(44)
            make.leading.equalTo(self).offset(containerEdge)
            make.trailing.equalTo(self).offset(-containerEdge)
            make.bottom.equalTo((self))
        })
        
        let _ = self.headerView()
        
        // 注册cell
        collectionView?.register(UINib.init(nibName: "SharedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: Identifier)
        
        self.backgroundColor = UIColor(red: 246, green: 246, blue: 246, alpha: 1)
        collectionView!.backgroundColor = UIColor(red: 246, green: 246, blue: 246, alpha: 1)
    }
    
    func initData(){
        /*
        
        urlschemes = ["weixin://","weixin://","mqq://","sinaweibo://","fb://","twitter://",""]
        titles = ["SharedWechatFriend","SharedQQ","SharedWeibo","SharedFacebook","SharedTwitter"]
         imgs = ["imgwechat","imgmoment","imgQQ","imgBlog","imgFacebook","imgTwitter","imgmore"]
         */
        
        if UIApplication.shared.canOpenURL(URL(string: "weixin://")!){
            urlschemes.append("weixin://")
            titles.append("SharedWechatFriend")
            imgs.append("imgwechat")
        }
        
        if UIApplication.shared.canOpenURL(URL(string: "mqq://")!){
            urlschemes.append("mqq://")
            titles.append("SharedQQ")
            imgs.append("imgQQ")
        }
        if UIApplication.shared.canOpenURL(URL(string: "sinaweibo://")!){
            urlschemes.append("sinaweibo://")
            titles.append("SharedWeibo")
            imgs.append("imgBlog")
        }
        
        if UIApplication.shared.canOpenURL(URL(string: "fb://")!){
            urlschemes.append("fb://")
            titles.append("SharedFacebook")
            imgs.append("imgFacebook")
        }
        
        if UIApplication.shared.canOpenURL(URL(string: "twitter://")!){
            urlschemes.append("twitter://")
            titles.append("SharedTwitter")
            imgs.append("imgTwitter")
        }
        
    }
    
    func headerView() -> UIView {
        let header = UIView()
        header.backgroundColor = .white
        self.addSubview(header)
        header.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalTo(self)
            make.height.equalTo(44)
        }
        
        let label = UILabel()
        label.localizedText = "QRView_share_to_friend"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor(rgb: 0x292929)
        header.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.centerY.equalTo(header)
            make.leading.equalTo(header).offset(itemHorizontalSpacing)
            make.trailing.equalTo(header).offset(-50)
        }
        
        closeBtn.setImage(UIImage.init(named: "closeBtn"), for: .normal)
        header.addSubview(closeBtn)
        closeBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(header)
            make.trailing.equalTo(header).offset(-10)
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        header.addSubview(closeBtn)
        
        return header
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:SharedCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifier, for: indexPath) as! SharedCollectionViewCell
        cell.backgroundColor = .clear
        cell.imageIcon.image = UIImage(named: imgs[indexPath.row])
        cell.descptionLabel.localizedText = titles[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
        
        let urlString = urlschemes[indexPath.row]
        if let url = URL(string: urlString) {
            //根据iOS系统版本，分别处理
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:],
                                          completionHandler: {
                                            (success) in
                })
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    func armColor()->UIColor{
        let red = CGFloat(arc4random()%256)/255.0
        let green = CGFloat(arc4random()%256)/255.0
        let blue = CGFloat(arc4random()%256)/255.0
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }

    


}
