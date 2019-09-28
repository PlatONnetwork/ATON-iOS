//
//  UITextFieldWithSearch.swift
//  platonWallet
//
//  Created by Ned on 21/3/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit

class UITextFieldWithSearch: UITextField {

    let searchTextFieldTextPadding = UIEdgeInsets(top: 0, left: 27, bottom: 0, right: 30)
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    open override func leftViewRect(forBounds bounds: CGRect) -> CGRect{
        let iconHight : CGFloat = 11
        let y = (self.frame.height - iconHight) * 0.5
        return CGRect(x: y, y: y, width: iconHight, height: iconHight)
    }
    
    open override func rightViewRect(forBounds bounds: CGRect) -> CGRect{
        let iconHight : CGFloat = 11
        let y = (self.frame.height - iconHight) * 0.5
        let frame = self.frame
        let x = frame.size.width - iconHight - 10
        return CGRect(x: x, y: y, width: iconHight, height: iconHight)
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: searchTextFieldTextPadding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: searchTextFieldTextPadding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: searchTextFieldTextPadding)
    }
}
