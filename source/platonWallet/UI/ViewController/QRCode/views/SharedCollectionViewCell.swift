//
//  SharedCollectionViewCell.swift
//  platonWallet
//
//  Created by matrixelement on 6/11/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit

class SharedCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var descptionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        descptionLabel.font = .systemFont(ofSize: 12)
        descptionLabel.textColor = UIColor(rgb: 0x61646e)
        descptionLabel.adjustsFontSizeToFitWidth = true
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {

        self.setNeedsLayout()
        self.layoutIfNeeded()

        let size = self.contentView.systemLayoutSizeFitting(layoutAttributes.size)
        var cellFrame = layoutAttributes.frame
        cellFrame.size.height = size.height
        layoutAttributes.frame = cellFrame
        return layoutAttributes
    }

}
