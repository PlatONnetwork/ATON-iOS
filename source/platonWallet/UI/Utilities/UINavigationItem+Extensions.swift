//
//  UINavigationItem+Extensions.swift
//  platonWallet
//
//  Created by matrixelement on 5/11/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import Localize_Swift

private var AssociatedKey: UInt8 = 1

extension UINavigationItem {
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

    func localizationSetup() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateLocalization), name: Notification.Name(LCLLanguageChangeNotification), object: nil)
    }

    @objc public func updateLocalization() {
        if let localizedText = localizedText, !localizedText.isEmpty {
            self.title = Localized(localizedText)
        }
    }
}
