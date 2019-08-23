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
        descriptionLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handlerTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        descriptionLabel.addGestureRecognizer(tapGesture)
    }
    
    @objc func handlerTap(_ recognizer: UITapGestureRecognizer) {
        textTapHandler?()
    }
}
