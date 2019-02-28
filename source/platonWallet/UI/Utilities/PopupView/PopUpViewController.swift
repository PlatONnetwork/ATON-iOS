//
//  PopUpViewController.swift
//  platonWallet
//
//  Created by matrixelement on 27/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit
import Spring

class PopUpViewController: UIViewController {
    
    var contentView : UIView?
    
    let bgView = UIView()
    
    let dismissView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        view.addSubview(bgView)
        bgView.backgroundColor = UIColor(rgb: 0x111111, alpha: 0.5)
        bgView.snp.makeConstraints { (make) in
            make.leading.trailing.top.bottom.equalTo(view)
        }
        
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(onDismissViewController))
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
            make.height.equalTo(size.height)
        })
        
        bgView.addSubview(dismissView)
        dismissView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalTo(bgView)
            make.bottom.equalTo((contentView?.snp_topMargin)!)
        }
    }
    
    func setCloseEvent(button : UIButton){
        button.addTarget(self, action: #selector(onDismissViewController), for: .touchUpInside)
    }
    
    
    
    @objc func onDismissViewController() {
        
        UIView.animate(withDuration: 0.35,
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
            self.presentingViewController?.dismiss(animated: false
                , completion: nil)
        })
        
        
    }
    
    open func show(inViewController vc: UIViewController, animated: Bool = false){
        
        self.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        vc.present(self, animated: animated) {
            
            UIView.animate(withDuration: 0.35,
                           delay: 0,
                           usingSpringWithDamping: CGFloat(0.75),
                           initialSpringVelocity: CGFloat(3.0),
                           options: UIView.AnimationOptions.allowUserInteraction,
                           animations: {
                            
                            self.contentView?.snp.updateConstraints({ (make) in
                                make.bottom.equalTo(self.bgView.snp.bottom)
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
