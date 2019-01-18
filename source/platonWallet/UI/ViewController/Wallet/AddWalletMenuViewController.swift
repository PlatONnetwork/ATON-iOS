//
//  AddWalletMenuViewController.swift
//  platonWallet
//
//  Created by matrixelement on 2018/10/30.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Localize_Swift
import SnapKit

protocol AddWalletMenuDelegate: AnyObject {
    
    func createIndividualWallet()
    
    func createSharedWallet()
    
    func importIndividualWallet()
    
    func addSharedWallet()
    
}

class AddWalletMenuViewController: UIViewController {
    
    var contentView: UIView!
    
    weak var delegate: AddWalletMenuDelegate?
    
    override func loadView() {

        let blurEffect = UIBlurEffect(style: .dark)
        
        let view = UIVisualEffectView(effect: blurEffect)
        self.view = view
        self.contentView = view.contentView
        
    }
    
    lazy var menuItemContents: [(title: String, imageName: String, handler: Selector)] = {

        return [
            (title: Localized("AddWalletMenuVC_createIndividualWallet_title"), imageName: "icon_createIndividualWallet", handler: #selector(createIndividualWallet)),
            (title: Localized("AddWalletMenuVC_createSharedWallet_title"), imageName: "icon_createShareWallet", handler: #selector(createSharedWallet)),
            (title: Localized("AddWalletMenuVC_importIndividualWallet_title"), imageName: "icon_importIndividualWallet", handler: #selector(importIndividualWallet)),
            (title: Localized("AddWalletMenuVC_addSharedWallet_title"), imageName: "icon_addShareWallet", handler: #selector(addSharedWallet))
        ]
    }()
    
    lazy var menuItemViews: [UIView] = {
        
        var views: [UIView] = []
        for item in menuItemContents {
            
            let view = UIView()
            
            let imgV = UIImageView(image: UIImage(named: item.imageName))
            imgV.contentMode = .center
            imgV.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: item.handler)
            imgV.addGestureRecognizer(tap)
            
            view.addSubview(imgV)
            imgV.snp.makeConstraints { (maker) in
                maker.width.height.equalTo(70)
                maker.centerX.top.equalToSuperview()
            }
            let label = UILabel()
            label.text = item.title
            label.textColor = UIColor.white
            label.font = UIFont.systemFont(ofSize: 11)
            label.textAlignment = .center
            view.addSubview(label)
            label.snp.makeConstraints { (maker) in
                maker.bottom.left.right.equalToSuperview()
            }
            views.append(view)
        }

        return views
        
    }()
    
    lazy var closeBtn: UIButton = {
        
        let btn = UIButton()
        btn.setImage(UIImage(named: "icon_close_white"), for: .normal)
        btn.addTarget(self, action: #selector(close), for: .touchUpInside)
        return btn
    }()
    
    let delayTimes = [0,0.1,0.1,0.2]
    
    var viewBottomConstraints: [Constraint] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initSubViews()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        for i in 0..<menuItemViews.count {
            menuItemViews[i].alpha = 0.0
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(delayTimes[i])) { 
                self.viewBottomConstraints[i].update(priority: .high)
                UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 35, options: UIView.AnimationOptions.curveEaseOut, animations: {
                    self.menuItemViews[i].alpha = 1
                    self.contentView.layoutIfNeeded()
                }, completion: nil)
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    func initSubViews() {
        
        for i in 0..<menuItemViews.count {
            
            let itemView = menuItemViews[i]
            
            contentView.addSubview(itemView)
            itemView.snp.makeConstraints { (maker) in
                maker.height.equalTo(100)
                maker.width.equalTo(152)
                if i % 2 == 0 {
                    maker.right.equalTo(contentView.snp.centerX)
                }else {
                    maker.left.equalTo(contentView.snp.centerX)
                }
                if i < 2 {
                    
                    maker.bottom.equalTo(contentView.snp.centerY).offset(-20-36+200).priority(500)
                    self.viewBottomConstraints.append(maker.bottom.equalTo(contentView.snp.centerY).offset(-20-36).priority(.low).constraint)
                }else {
                   
                    maker.bottom.equalTo(contentView.snp.centerY).offset(120-36+200).priority(500)
                    self.viewBottomConstraints.append(maker.bottom.equalTo(contentView.snp.centerY).offset(120-36).priority(.low).constraint)
                    
                }
            }
        }
        
        contentView.addSubview(closeBtn)
        closeBtn.snp.makeConstraints { (maker) in
            maker.width.height.equalTo(37)
            maker.bottom.equalToSuperview().offset(-36)
            maker.centerX.equalToSuperview()
        }
        
    }
    
    
    @objc func close() {
        self.dismiss(animated: false, completion: nil)
        /*
        for i in (0..<menuItemViews.count).reversed() {
    
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(i) * 0.1) { 
                self.viewBottomConstraints[self.menuItemViews.count - 1 - i].update(priority: .low)
                UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 25, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                    self.menuItemViews[self.menuItemViews.count - 1 - i].alpha = 0.0
                    self.contentView.layoutIfNeeded()
                }, completion: nil)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.6) { 
            self.dismiss(animated: false, completion: nil)
        }
         */
    }
    
    @objc func createIndividualWallet() {
        delegate?.createIndividualWallet()
    }
    
    @objc func createSharedWallet() {
        delegate?.createSharedWallet()
    }
    
    @objc func importIndividualWallet() {
        delegate?.importIndividualWallet()
    }
    
    @objc func addSharedWallet() {
        delegate?.addSharedWallet()
    }

}
