//
//  UIImage+Extensions.swift
//  platonWallet
//
//  Created by matrixelement on 17/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import UIKit

public extension UIImage {
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 1.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let thecgImage = image?.cgImage else { return nil }
        self.init(cgImage: thecgImage)
    }

    class func gradientImage(colors:[UIColor], size: CGSize, startPoint: CGPoint? = CGPoint(x: 0, y: 0), endPoint: CGPoint? = CGPoint(x: 1, y: 1)) -> UIImage? {
        if colors.count == 0 || size == .zero {
            return nil
        }
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        gradientLayer.startPoint = startPoint!
        gradientLayer.endPoint = endPoint!
        let cgColors = colors.map { (color) -> CGColor in
            return color.cgColor
        }
        gradientLayer.colors = cgColors
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    class func geneQRCodeImageFor(_ content: String, size: CGFloat) -> UIImage? {

        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setDefaults()

        filter?.setValue(content.data(using: .utf8), forKey: "inputMessage")

        guard let ciImage = filter?.outputImage else {
            return nil

        }

        let extent = ciImage.extent.integral
        let scale = min(size / extent.width, size / extent.height)
        let w = extent.width * scale
        let h = extent.height * scale
        let cs = CGColorSpaceCreateDeviceCMYK()
        let bitmapRef = CGContext(data: nil, width: Int(w), height: Int(h), bitsPerComponent: 8, bytesPerRow: 0, space: cs, bitmapInfo: 0)!
        let context = CIContext(options: nil)

        guard let bitmapImage = context.createCGImage(ciImage, from: extent) else {
            return nil
        }

        bitmapRef.interpolationQuality = .none
        bitmapRef.scaleBy(x: scale, y: scale)
        bitmapRef.draw(bitmapImage, in: extent)

        guard let scaledImage = bitmapRef.makeImage() else {
            return nil
        }

        return UIImage(cgImage: scaledImage)

    }

    func circleImage() -> UIImage {

        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let path = UIBezierPath(arcCenter: CGPoint(x: size.width/2, y: size.height/2), radius: size.width/2, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
        path.addClip()
        draw(at: .zero)
        let newImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImg!

    }

    func generatePendingImage(_ size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()!

        let replicatorLayer = CAReplicatorLayer()
        replicatorLayer.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        replicatorLayer.instanceCount = 3
        replicatorLayer.instanceTransform = CATransform3DMakeTranslation((replicatorLayer.frame.size.width-4)/2, 0, 0)
        replicatorLayer.instanceDelay = 1/3.0

        let dotLayer = CAShapeLayer()
        dotLayer.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 10, width: 4, height: 4)).cgPath
        dotLayer.fillColor = UIColor(rgb: 0x2a5ffe).cgColor
        replicatorLayer.addSublayer(dotLayer)

        let keyAnimation = CAKeyframeAnimation(keyPath: "opacity")
        keyAnimation.duration = 1.0
        keyAnimation.keyTimes = [NSNumber(value: 0.0), NSNumber(0.5), NSNumber(1.0)]
        keyAnimation.values = [1.0, 0.5, 0.2]
        keyAnimation.repeatCount = Float.infinity
        dotLayer.add(keyAnimation, forKey: nil)

        replicatorLayer.render(in: context)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    func resizeImage(image: UIImage, newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(newSize)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}
