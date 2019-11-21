//
//  UILabel+FontSize.swift
//  platonWallet
//
//  Created by Admin on 11/11/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation

extension UILabel {

    /// 由于UIFont使用了runtime机制，当每次构造UIFont的时候，会进行放大，因为这里的font就不需要乘以缩放比
    open override func awakeFromNib() {
        super.awakeFromNib()
        self.font = UIFont.systemFont(ofSize: font.pointSize, weight: font.getFontWeight())
    }
}
