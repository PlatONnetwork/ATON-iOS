//
//  UIView+Extenstions.swift
//  platonWallet
//
//  Created by matrixelement on 19/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import UIKit

public extension UIView {
    func addMaskView(corners: UIRectCorner,cornerRadiiV : CGFloat){
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: cornerRadiiV, height: cornerRadiiV))
            let maskLayer = CAShapeLayer()
            maskLayer.frame = self.bounds
            maskLayer.path = maskPath.cgPath
            self.layer.mask = maskLayer
        }
    }
    
    func rotate() {
        if self.layer.animation(forKey: "rotationAnimation") == nil {
            let rotation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
            rotation.toValue = NSNumber(value: Double.pi * 2)
            rotation.duration = 1
            rotation.isCumulative = true
            rotation.repeatCount = Float.greatestFiniteMagnitude
            self.layer.add(rotation, forKey: "rotationAnimation")
        }
    }
    
    func stopRotate() {
        self.layer.removeAllAnimations()
    }
}

extension UIView {
    
    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
    func asImage() -> UIImage {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        } else {
            UIGraphicsBeginImageContext(self.frame.size)
            self.layer.render(in:UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return UIImage(cgImage: image!.cgImage!)
        }
    }
}

extension UIView {
    func addBottomSepline(offset: CGFloat = 0) {
        let view = UIView()
        view.backgroundColor = UIColor(rgb: 0xEBEEF4)
        self.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(offset)
            make.trailing.equalToSuperview().offset(-offset)
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    func addTopSepline(offset: CGFloat = 0) {
        let view = UIView()
        view.backgroundColor = UIColor(rgb: 0xEBEEF4)
        self.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(offset)
            make.trailing.equalToSuperview().offset(-offset)
            make.top.equalToSuperview()
            make.height.equalTo(1)
        }
    }
}
