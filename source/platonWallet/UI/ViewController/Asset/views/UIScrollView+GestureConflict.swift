//
//  UIScrollView+GestureConflict.swift
//  platonWallet
//
//  Created by Admin on 19/10/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation

extension UIScrollView {
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view is UISlider {
            isScrollEnabled = false
        } else {
            isScrollEnabled = true
        }
        return view
    }
}
