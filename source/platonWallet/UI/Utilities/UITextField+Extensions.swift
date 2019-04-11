//
//  UITextField+Extensions.swift
//  platonWallet
//
//  Created by matrixelement on 2018/10/22.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import UIKit
import Localize_Swift

private var AssociatedKey: UInt8 = 1
private var AssociatedKey_Placeholder: UInt8 = 1
private var unTruncateTextAssociatedKey: UInt8 = 3


extension UITextField {
    @IBInspectable
    public var LocalizedText: String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey) as? String
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            localizationSetup();
            updateLocalization()
        }
    }
    
    @IBInspectable
    public var LocalizePlaceholder: String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey_Placeholder) as? String
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKey_Placeholder, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            localizationSetup();
            updateLocalization()
        }
    }
    
    func localizationSetup(){
        NotificationCenter.default.addObserver(self, selector: #selector(updateLocalization), name: Notification.Name(LCLLanguageChangeNotification), object: nil)
    }
    
    @objc public func updateLocalization() {
        if let LocalizedText = LocalizedText, !LocalizedText.isEmpty {
            text = Localized(LocalizedText)
        }
        
        if let LocalizePlaceholder = LocalizePlaceholder, !LocalizePlaceholder.isEmpty{
            placeholder = Localized(LocalizePlaceholder)
        }
    }
    
}

extension UITextView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var LocalizePlaceholder: String {
        get {
            return placeholder ?? ""
        }
        set(key) {
            placeholder = Localized(key)
        }
    }
    
    @IBInspectable var LocalizeText: String {
        get {
            return text ?? ""
        }
        set(key) {
            text = Localized(key)
        }
    }
    
}

extension UITextField{
    public var unTruncateText: String? {
        get {
            if let ret = objc_getAssociatedObject(self, &unTruncateTextAssociatedKey) as? String{
                return ret
            }
            return text
        }
        set(newValue) {
            objc_setAssociatedObject(self, &unTruncateTextAssociatedKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}
