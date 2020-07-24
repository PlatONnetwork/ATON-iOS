//
//  SelectWalletTypeButton.swift
//  platonWallet
//
//  Created by juzix on 2020/7/20.
//  Copyright © 2020 ju. All rights reserved.
//

import UIKit

class SelectWalletTypeButton: UIButton {

    override var isSelected: Bool {
        didSet {
            if isSelected == true {
                layer.borderColor = UIColor.clear.cgColor
                layer.borderWidth = 0
            } else {
                layer.borderColor = UIColor(hex: "105CFE").cgColor
                layer.borderWidth = 1.0
            }
        }
    }
    
    override var frame: CGRect {
        didSet {
            layer.cornerRadius = frame.size.height / 2.0
            layer.masksToBounds = true
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        adjustsImageWhenHighlighted = false
        setTitleColor(UIColor(hex: "105CFE"), for: .normal)
        setTitleColor(.white, for: .selected)
        setBackgroundImage(UIImage(color: .white), for: .normal)
        setBackgroundImage(UIImage(color: UIColor(hex: "105CFE")), for: .selected)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
