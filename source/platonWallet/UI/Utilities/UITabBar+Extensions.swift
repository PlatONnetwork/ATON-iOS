//
//  UITabBar+Extensions.swift
//  platonWallet
//
//  Created by matrixelement on 5/12/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import UIKit

let unreadDotTag = 999

extension UITabBar{

    
    func isRedDotHidden(_ hidden: Bool){
        var unreadDot : UIView?
        let eview = self.viewWithTag(unreadDotTag)
        eview?.removeFromSuperview()
        if hidden{
            return
        }
        unreadDot = UIView()
        unreadDot?.tag = unreadDotTag
        self.addSubview(unreadDot!)
        unreadDot?.backgroundColor = .red
        unreadDot?.layer.masksToBounds = true
        unreadDot?.layer.cornerRadius = 3.0
        let tabFram = self.frame
        
        let tabNumber = Float(2)
        
        let percentX = (0.55)/tabNumber
        let x = ceilf(Float(percentX) * Float(tabFram.size.width));
        let y = ceilf(Float(0.1 * tabFram.size.height));
        unreadDot?.frame = CGRect(x: CGFloat(x), y: CGFloat(y), width: 6, height: 6)
        unreadDot?.isHidden = hidden
    }
    
}
