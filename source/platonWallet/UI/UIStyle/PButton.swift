//
//  PButton.swift
//  platonWallet
//
//  Created by matrixelement on 16/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import UIKit

enum PButtonStyle: Int {
    case plain = 0, blue, gray, alert, disable, delete
}

enum GradientDirection: Int {
    case vertical, horizontal
}

let blueNormalGradient = [UIColor(rgb: 0x3B92F1).cgColor, UIColor(rgb: 0x1B60F3).cgColor]
let blueHighlightedGradient = [UIColor(rgb: 0x2C7AD1).cgColor, UIColor(rgb: 0x104DCF).cgColor]
let grayNormalGradient = [UIColor(rgb: 0xFFFFFF).cgColor, UIColor(rgb: 0xEAEAEA).cgColor]
let grayHighlightedGradient = [UIColor(rgb: 0xEEF0F3).cgColor, UIColor(rgb: 0xDADADA ).cgColor]
let disableNormalGradient = [UIColor(rgb: 0xFFFFFF).cgColor, UIColor(rgb: 0xEAEAEA).cgColor]
let disableHighlightedGradient = [UIColor(rgb: 0xFFFFFF).cgColor, UIColor(rgb: 0xEAEAEA).cgColor]

//let deleteNormalGradient = [UIColor(rgb: 0xDE1B42).cgColor, UIColor(rgb: 0xD40F0B).cgColor]
//let deleteHighlightedGradient = [UIColor(rgb: 0xE4E6EF).cgColor, UIColor(rgb: 0xB6BBD0).cgColor]

let deleteNormalGradient = [UIColor(rgb: 0xffffff).cgColor, UIColor(rgb: 0xffffff).cgColor]
let deleteHighlightedGradient = [UIColor(rgb: 0xffffff).cgColor, UIColor(rgb: 0xffffff).cgColor]

class PButton: UIButton {

    func gradientLayer(color: [CGColor], _ direction: GradientDirection = .vertical) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        gradientLayer.colors = color
//        gradientLayer.cornerRadius = self.bounds.size.height * 0.5

        if direction == .horizontal {
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
        }

        return gradientLayer
    }

    func setHorizontalLinerTitleAndImage(image: UIImage) {
        self.setImage(image, for: .normal)
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: -self.imageView!.bounds.size.width - 18, bottom: 0, right: self.imageView!.bounds.size.width)
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: self.titleLabel!.bounds.size.width, bottom: 0, right: -self.titleLabel!.bounds.size.width)
    }

    func layerToImage(layer: CALayer) -> UIImage? {
        if layer.frame.size.width == 0.0 {
            return UIImage()
        }
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, 0)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return outputImage
    }

    var style: PButtonStyle = .plain {
        didSet {
            self.backgroundColor = .clear

            switch style {
            case .plain:
                do {}
                isUserInteractionEnabled = true
            case .blue:
                //shadow
                self.layer.shadowColor = UIColor(rgb: 0x0051ff).cgColor
                self.layer.shadowOpacity = 0.4
                self.layer.shadowOffset = CGSize(width: 0, height: 0)

                //title
                setTitleColor(UIColor(rgb: 0xF6F6F6 ), for: .normal)
                setTitleColor(UIColor(rgb: 0xA2C1F2), for: .highlighted)

                setBackgroundImage(layerToImage(layer: gradientLayer(color: blueNormalGradient))?.resizableImage(withCapInsets: UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3), resizingMode: .stretch), for: .normal)
                setBackgroundImage(layerToImage(layer: gradientLayer(color: blueHighlightedGradient))?.resizableImage(withCapInsets: UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3), resizingMode: .stretch), for: .highlighted)
                isUserInteractionEnabled = true
            case .gray:
                //shadow
                layer.shadowColor = UIColor(rgb: 0x969696).cgColor
                layer.shadowOpacity = 0.4
                layer.shadowOffset = CGSize(width: 0, height: 0)

                //title
                setTitleColor(UIColor(rgb: 0x000000), for: .normal)
                setTitleColor(UIColor(rgb: 0x979797), for: .highlighted)

                setBackgroundImage(layerToImage(layer: gradientLayer(color: grayNormalGradient))?.resizableImage(withCapInsets: UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3), resizingMode: .stretch), for: .normal)
                setBackgroundImage(layerToImage(layer: gradientLayer(color: grayHighlightedGradient))?.resizableImage(withCapInsets: UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3), resizingMode: .stretch), for: .highlighted)
                isUserInteractionEnabled = true
            case .delete:
                self.layer.shadowColor = UIColor.clear.cgColor
                setTitleColor(UIColor(rgb: 0xF5302C), for: .normal)
                setTitleColor(UIColor(rgb: 0xDC5E5B), for: .highlighted)
                self.layer.borderColor = UIColor(rgb: 0xF5302C).cgColor
                self.layer.borderWidth = 1
                self.layer.cornerRadius = 22
                isUserInteractionEnabled = true
            case .alert:
                setTitleColor(UIColor(rgb: 0xF5302C), for: .normal)
                setTitleColor(UIColor(rgb: 0xDC5E5B), for: .highlighted)

                setBackgroundImage(UIImage(color: UIColor(rgb: 0xDC5151)), for: .normal)
                setBackgroundImage(UIImage(color: UIColor(rgb: 0xDC5151)), for: .highlighted)
                isUserInteractionEnabled = true
            case .disable:

                layer.shadowColor = UIColor(rgb: 0x969696).cgColor
                layer.shadowOpacity = 0.4
                layer.shadowOffset = CGSize(width: 0, height: 0)

                setTitleColor(UIColor(rgb: 0xD8D8D8), for: .normal)
                setTitleColor(UIColor(rgb: 0xD8D8D8), for: .highlighted)

                setBackgroundImage(layerToImage(layer: gradientLayer(color: disableNormalGradient))?.resizableImage(withCapInsets: UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3), resizingMode: .stretch), for: .normal)
                setBackgroundImage(layerToImage(layer: gradientLayer(color: disableHighlightedGradient))?.resizableImage(withCapInsets: UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3), resizingMode: .stretch), for: .highlighted)
                isUserInteractionEnabled = false
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.style = .plain
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.style = .plain
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.style = .plain
    }

    convenience init(style: PButtonStyle) {
        self.init()
        self.style = style
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.size.height * 0.5
        layer.masksToBounds = true
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
