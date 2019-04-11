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
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 1.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let thecgImage = image?.cgImage else { return nil }
        self.init(cgImage: thecgImage)
    }
    
    public class func gradientImage(colors:[UIColor], size: CGSize) -> UIImage? {
        if colors.count == 0 || size == .zero {
            return nil
        }
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
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

    
    public class func geneQRCodeImageFor(_ content: String, size: CGFloat) -> UIImage? {
        
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
    
    public func circleImage() -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let path = UIBezierPath(arcCenter: CGPoint(x: size.width/2, y: size.height/2), radius: size.width/2, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
        path.addClip()
        draw(at: .zero)
        let newImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImg!


    }
}
