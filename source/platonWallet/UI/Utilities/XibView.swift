//
//  XibView.swift
//  platonWallet
//
//  Created by matrixelement on 17/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit

extension UIView{
    static func viewFromXib(theClass : AnyClass?) -> UIView?{
        let fullClass = String(NSStringFromClass(theClass!))
        let subfixClass = fullClass.components(separatedBy: ".")[1]
        let nibView = Bundle.main.loadNibNamed(subfixClass, owner: nil, options: nil)?[0]
        return nibView as? UIView
    }
}

