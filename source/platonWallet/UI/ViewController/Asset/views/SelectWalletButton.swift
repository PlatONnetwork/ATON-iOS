//
//  SelectWalletButton.swift
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

    override init(frame: CGRect) {
        super.init(frame: frame)
        setTitleColor(UIColor(hex: "105CFE"), for: .normal)
        setTitleColor(.white, for: .selected)
        setBackgroundImage(UIImage(color: .white), for: .normal)
        setBackgroundImage(UIImage(color: UIColor(hex: "105CFE")), for: .selected)
        layer.cornerRadius = frame.size.height / 2.0
        layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
