//
//  PButton.swift
//  platonWallet
//
//  Created by matrixelement on 16/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit

enum PButtonStyle : Int {
    case common = 0,gray,alert,disable
}

class PButton: UIButton {

    var style: PButtonStyle = .common {
        didSet {
            
            layer.cornerRadius = 1.0
            layer.masksToBounds = true
            titleLabel?.font = UIFont .systemFont(ofSize: 14.0)
            setTitleColor(UIColor(rgb: 0x626980), for: .disabled)
            setBackgroundImage(UIImage(color: UIColor(rgb: 0x272E47)), for: .disabled)
            
            switch style {
            case .common:
                setTitleColor(UIColor(rgb: 0x1B2137), for: .normal)
                setTitleColor(UIColor(rgb: 0xC5CBDC), for: .highlighted)
                
                setBackgroundImage(UIImage(color: UIButton_backround_light_white), for: .normal)
                setBackgroundImage(UIImage(color: UIButton_backround_light_white), for: .highlighted)
                
            case .gray:
                setTitleColor(UIColor(rgb: 0xFFFFFF), for: .normal)
                setTitleColor(UIColor(rgb: 0x6B6F7D), for: .highlighted)
                
                setBackgroundImage(UIImage(color: UIColor(rgb: 0x373E51)), for: .normal)
                setBackgroundImage(UIImage(color: UIColor(rgb: 0x373E51)), for: .highlighted)
            case .alert:
                setTitleColor(UIColor(rgb: 0xFFFFFF), for: .normal)
                setTitleColor(UIColor(rgb: 0xE79292), for: .highlighted)
                
                setBackgroundImage(UIImage(color: UIColor(rgb: 0xDC5151)), for: .normal)
                setBackgroundImage(UIImage(color: UIColor(rgb: 0xDC5151)), for: .highlighted)
            
            case .disable:
                
                setTitleColor(UIColor(rgb: 0x626980), for: .normal)
                setTitleColor(UIColor(rgb: 0x626980), for: .highlighted)
                
                setBackgroundImage(UIImage(color: UIColor(rgb: 0x272E47)), for: .normal)
                setBackgroundImage(UIImage(color: UIColor(rgb: 0x272E47)), for: .highlighted)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.style = .common
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.style = .common
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.style = .common
    }
    
    convenience init(style: PButtonStyle) {
        self.init()
        self.style = style
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    

}
