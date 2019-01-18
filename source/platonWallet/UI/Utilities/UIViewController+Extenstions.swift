//
//  UIViewController+Extenstions.swift
//  platonWallet
//
//  Created by matrixelement on 2018/10/23.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import MBProgressHUD
import Localize_Swift

extension UIViewController {
    
    func showLoading(text: String = Localized("loading") ,animated: Bool = true) {
        DispatchQueue.main.async {
            let hud = MBProgressHUD.showAdded(to: self.view, animated: animated)
            hud.label.text = text
        }

    }
    
    func hideLoading(animated: Bool = true) {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: animated)
        }
    }
    
    func showMessage(text: String, delay: TimeInterval = 0.8) {
        
        DispatchQueue.main.async {
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.mode = .text
            //hud.label.text = text
            hud.detailsLabel.text = text
            hud.hide(animated: true, afterDelay: delay)
        }
        
    }
    
    func showMessageWithCodeAndMsg(code: Int, text: String, delay:TimeInterval = 1.2) {
        
        DispatchQueue.main.async {
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.mode = .text
            //hud.label.text = text
            
            if let msg = self.messageWithCode(code: code){
                hud.detailsLabel.text = msg
            }else{
                hud.detailsLabel.text = text
            }
            
            hud.hide(animated: true, afterDelay: delay)
        }
        
    }

    
    func messageWithCode(code: Int) -> String?{
        if code == -111{
            return Localized("transferVC_Insufficient_balance")
        }
        return nil
    }
    
}
