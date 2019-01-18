//
//  UIApplication+Extensions.swift
//  platonWallet
//
//  Created by matrixelement on 3/12/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import UIKit


extension UIApplication{
    class func rootViewController() -> UIViewController{
        return (UIApplication.shared.keyWindow?.rootViewController!)!
    }
}
