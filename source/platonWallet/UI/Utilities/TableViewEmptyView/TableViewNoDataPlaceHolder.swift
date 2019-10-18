//
//  TableViewNoDataPlaceHolder.swift
//  platonWallet
//
//  Created by matrixelement on 2/11/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit

class TableViewNoDataPlaceHolder: UIView {
    var textTapHandler: (() -> Void)?

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var ImageTopToSuper: NSLayoutConstraint!
    override func awakeFromNib() {
        imageView.isUserInteractionEnabled = true

        descriptionLabel.isUserInteractionEnabled = true
        descriptionLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlerTap(_:))))
    }

    @objc func handlerTap(_ recognizer: UITapGestureRecognizer) {
        textTapHandler?()
    }
}
