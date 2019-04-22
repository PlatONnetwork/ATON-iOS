//
//  PopUpViewController.swift
//  platonWallet
//
//  Created by matrixelement on 27/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Spring

let PopUpContentWidth = kUIScreenWidth - 24 * 2

class PopUpViewController: UIViewController {
    
    var contentView : UIView?
    
    let bgView = UIView()
    
    let dismissView = UIView()
    
    var dismissCompletion: (() -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        view.addSubview(bgView)
        bgView.backgroundColor = UIColor(rgb: 0x111111, alpha: 0.5)
        bgView.snp.makeConstraints { (make) in
            make.leading.trailing.top.bottom.equalTo(view)
        }
        
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(touchClose))
        dismissView.addGestureRecognizer(tapGes)
        dismissView.backgroundColor = UIColor(rgb: 0xff0000, alpha: 0)
        
    }
    
    
    func setUpContentView(view : UIView, size : CGSize) {

        contentView = view
        bgView.addSubview(contentView!)
        contentView?.snp.makeConstraints({ (make) in
            make.centerX.equalTo(bgView)
            make.bottom.equalTo(bgView.snp.bottom).offset(size.height)
            make.width.equalTo(size.width)
            make.height.equalTo(size.height + (ScreenDesignRatio == 1 ? 0 : 10))
        })
        
        bgView.addSubview(dismissView)
        dismissView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalTo(bgView)
            make.bottom.equalTo((contentView?.snp_topMargin)!)
        }
        contentView?.layer.cornerRadius = 8
        contentView?.layer.masksToBounds = true
    }
    
    func setCloseEvent(button : UIButton){
        button.addTarget(self, action: #selector(touchClose), for: .touchUpInside)
    }
    
    @objc func touchClose(){
        self.onDismissViewController()
    }
    
    
    @objc func onDismissViewController(animated: Bool = true, completion: (() -> ())? = nil) {
        if self.dismissCompletion != nil{
            self.dismissCompletion!()
        }
        if animated{
            UIView.animate(withDuration: 0.15,
                           delay: 0,
                           usingSpringWithDamping: CGFloat(0.75),
                           initialSpringVelocity: CGFloat(3.0),
                           options: UIView.AnimationOptions.allowUserInteraction,
                           animations: {
                            
                            self.contentView?.snp.updateConstraints({ (make) in
                                make.bottom.equalTo(self.bgView.snp.bottom).offset(kUIScreenHeight)
                            })
                            self.contentView!.superview!.layoutIfNeeded()
                            self.bgView.alpha = 0
                            
            },completion: { Void in()
                self.presentingViewController?.dismiss(animated: false, completion: completion)
            })
        }else{
            self.presentingViewController?.dismiss(animated: false, completion: completion)
        } 
        
    }
    
    open func show(inViewController vc: UIViewController, animated: Bool = false){
        
        self.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        vc.present(self, animated: animated) {
            
            UIView.animate(withDuration: 0.35,
                           delay: 0,
                           usingSpringWithDamping: CGFloat(0.75),
                           initialSpringVelocity: CGFloat(3.0),
                           options: UIView.AnimationOptions.allowUserInteraction,
                           animations: {
                            
                            self.contentView?.snp.updateConstraints({ (make) in
                                make.bottom.equalTo(self.bgView.snp.bottom).offset(-16)
                            })
                            self.contentView!.superview!.layoutIfNeeded()
                            
            },completion: { Void in()
            })
            
          
        }
      
        
    }
    
    deinit {
        print("PopupViewController deinit")
    }

}

