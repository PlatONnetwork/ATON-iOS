//
//  SharedView.swift
//  platonWallet
//
//  Created by matrixelement on 6/11/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Foundation
import Localize_Swift

let itemHorizontalCount = 4
let itemHorizontalSpacing = 5
let containerEdge = 16
let itemratio = 1.2

let itemWidth = (kUIScreenWidth - CGFloat(containerEdge) * 2 - CGFloat((itemHorizontalSpacing * (itemHorizontalCount - 1))))/CGFloat(itemHorizontalCount)
//let itemWidth = CGFloat(54)

struct UrlsSchemes {
    static let weixin = "weixin://"
    static let qq = "mqq://"
    static let sina = "sinaweibo://"
    static let facebook = "fb://"
    static let twitter = "twitter://"
}

class SharedView: UIView ,UICollectionViewDelegate,UICollectionViewDataSource {

    lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "1.icon_shut down"), for: .normal)
        return button
    }()

    var collectionView : UICollectionView?
    let Identifier       = "SharedCollectionViewCell"

    var titles : [String] = []
    var imgs : [String] = []
    var urlschemes : [String] = []
    var shareObject: UIImage?

    public class func getSharedViewHeight() -> CGFloat {
        return 51 + 51 + itemWidth * CGFloat(itemratio) * 2 + CGFloat(itemHorizontalSpacing * 2) + 10
    }

    override init(frame: CGRect) {

        super.init(frame: frame)

        self.initData()

        let layout = UICollectionViewFlowLayout.init()
        layout.estimatedItemSize = CGSize(width: 65, height: 100)
//        layout.itemSize = CGSize(width: itemWidth, height: itemWidth * CGFloat(itemratio))
        layout.minimumLineSpacing = CGFloat(itemHorizontalSpacing)
        layout.minimumInteritemSpacing = CGFloat(itemHorizontalSpacing)
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets.init(top: 5, left: 2, bottom: 5, right: 2)

        collectionView =  UICollectionView(frame: .zero, collectionViewLayout: layout)
//        collectionView = UICollectionView.init(frame: CGRect(x:0, y:0, width:0, height:0), collectionViewLayout: layout)
        collectionView?.backgroundColor = .white
        collectionView?.isScrollEnabled = false
        collectionView?.delegate = self
        collectionView?.dataSource = self
        addSubview(collectionView!)
        collectionView?.snp.makeConstraints({ (make) in
            make.top.equalTo(self).offset(51)
            make.leading.equalTo(self).offset(containerEdge)
            make.trailing.equalTo(self).offset(-containerEdge)
            make.bottom.equalToSuperview().offset(-56)
        })

        _ = self.headerAndFooterView()

        // 注册cell
        collectionView?.register(UINib.init(nibName: "SharedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: Identifier)

        backgroundColor = .white
        collectionView?.addBottomSepline()
    }

    func initData() {
        /*
        
        urlschemes = ["weixin://","weixin://","mqq://","sinaweibo://","fb://","twitter://",""]
        titles = ["SharedWechatFriend","SharedQQ","SharedWeibo","SharedFacebook","SharedTwitter"]
         imgs = ["imgwechat","imgmoment","imgQQ","imgBlog","imgFacebook","imgTwitter","imgmore"]
         */

//        if UIApplication.shared.canOpenURL(URL(string: UrlsSchemes.weixin)!) {
            urlschemes.append(UrlsSchemes.weixin)
            titles.append("SharedWechatFriend")
            imgs.append("imgwechat")
//        }

//        if UIApplication.shared.canOpenURL(URL(string: UrlsSchemes.qq)!) {
            urlschemes.append(UrlsSchemes.qq)
            titles.append("SharedQQ")
            imgs.append("imgQQ")
//        }
//        if UIApplication.shared.canOpenURL(URL(string: UrlsSchemes.sina)!) {
            urlschemes.append(UrlsSchemes.sina)
            titles.append("SharedWeibo")
            imgs.append("imgBlog")
//        }

//        if UIApplication.shared.canOpenURL(URL(string: UrlsSchemes.facebook)!) {
            urlschemes.append(UrlsSchemes.facebook)
            titles.append("SharedFacebook")
            imgs.append("imgFacebook")
//        }

//        if UIApplication.shared.canOpenURL(URL(string: UrlsSchemes.twitter)!) {
            urlschemes.append(UrlsSchemes.twitter)
            titles.append("SharedTwitter")
            imgs.append("imgTwitter")
//        }

    }

    func headerAndFooterView() -> UIView {
        let header = UIView()
        header.backgroundColor = .white
        self.addSubview(header)
        header.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalTo(self)
            make.height.equalTo(51)
        }
        header.addBottomSepline(offset: 16)

        let label = UILabel()
        label.localizedText = "QRView_share_to_friend"
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
        label.textColor = UIColor(rgb: 0x292929)
        label.textAlignment = .center
        header.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        //closeBtn.setImage(UIImage.init(named: "closeBtn"), for: .normal)
//        closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalTo(label)
            make.height.width.equalTo(32)
        }

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
        guard UIApplication.shared.canOpenURL(URL(string: urlString)!) else {
            UIApplication.shared.keyWindow?.rootViewController?.showMessage(text: Localized("social_share_error_uninstall_app"), delay: 1.5)
            return
        }

        guard
            let shareImage = shareObject,
            (urlString == UrlsSchemes.facebook || urlString == UrlsSchemes.sina),
            let controller = UIApplication.shared.keyWindow?.rootViewController
        else {
            if let url = URL(string: urlString) {
                //根据iOS系统版本，分别处理
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url, options: [:],
                                              completionHandler: {
                                                (_) in
                    })
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
            return
        }

        let shareObject = UMShareImageObject()
        shareObject.shareImage = shareImage
        let messageObject = UMSocialMessageObject()
        messageObject.shareObject = shareObject

        if urlString == UrlsSchemes.facebook {
            UMSocialManager.default()?.share(to: .facebook, messageObject: messageObject, currentViewController: controller, completion: { (data, error) in

            })
        } else if urlString == UrlsSchemes.sina {
            UMSocialManager.default()?.share(to: .sina, messageObject: messageObject, currentViewController: controller, completion: { (data, error) in

            })
        }
    }

    func armColor() -> UIColor {
        let red = CGFloat(arc4random()%256)/255.0
        let green = CGFloat(arc4random()%256)/255.0
        let blue = CGFloat(arc4random()%256)/255.0
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }

}
