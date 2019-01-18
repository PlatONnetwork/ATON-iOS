//
//  PTextFieldWithPadding.swift
//  platonWallet
//
//  Created by matrixelement on 16/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit

class PTextFieldWithPadding: UITextField {
    
    let padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    
    private var _placeholder : String?
    
    override func awakeFromNib() {
        restyle()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        restyle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        restyle()
    }
    
    override var placeholder: String?{
        get{
            return self._placeholder
        }
        set{
            self._placeholder = newValue
            if _placeholder != nil {
                self.attributedPlaceholder = NSAttributedString(string: _placeholder!,
                                                                attributes: [NSAttributedString.Key.foregroundColor: transfer_placeholder_color])
            }
        }
    }
    
    func restyle() {
        backgroundColor = UITextField_backround
        textColor = transfer_input_color
        tintColor = textColor

    }
  
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        if let rigth = rightView {
            
            return bounds.inset(by: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: rigth.frame.width))
        }
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        if let rigth = rightView {

            return bounds.inset(by: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: rigth.frame.width))
        }
        return bounds.inset(by: padding)
    }

}
