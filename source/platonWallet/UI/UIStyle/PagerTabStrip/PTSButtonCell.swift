//
//  PTSButtonCell.swift
//  platonWallet
//
//  Created by Admin on 24/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import UIKit

class PTSButtonCell: UICollectionViewCell {

    @IBOutlet open var imageView: UIImageView!
    @IBOutlet open var label: UILabel!

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        isAccessibilityElement = true
        accessibilityTraits.insert([.button, .header])
    }

    open override var isSelected: Bool {
        get {
            return super.isSelected
        }
        set {
            super.isSelected = newValue
            if (newValue) {
                accessibilityTraits.insert(.selected)
            } else {
                accessibilityTraits.remove(.selected)
            }
        }
    }

}
