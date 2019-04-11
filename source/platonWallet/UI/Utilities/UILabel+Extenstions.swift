//
//  UILabel+Extenstions.swift
//  platonWallet
//
//  Created by matrixelement on 2018/10/22.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import UIKit
import Localize_Swift

private var AssociatedKey: UInt8 = 1
private var unTruncateTextAssociatedKey: UInt8 = 2

extension UILabel {
    
    @IBInspectable
    public var localizedText: String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey) as? String
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            localizationSetup()
            updateLocalization()
        }
    }
    
    func localizationSetup(){
        NotificationCenter.default.addObserver(self, selector: #selector(updateLocalization), name: Notification.Name(LCLLanguageChangeNotification), object: nil)
    }
    
    @objc public func updateLocalization() {
        if let localizedText = localizedText, !localizedText.isEmpty {
            text = Localized(localizedText)
        }
    }
    
}

extension UILabel{
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
