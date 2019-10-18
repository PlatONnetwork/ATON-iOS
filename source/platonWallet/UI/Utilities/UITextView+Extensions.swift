//
//  UITextView+Extensions.swift
//  platonWallet
//
//  Created by matrixelement on 5/11/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import Localize_Swift
import UITextView_Placeholder

private var AssociatedKey: UInt8 = 1
private var AssociatedKey_Placeholder: UInt8 = 1

extension UITextView {
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
    public var localizedText_Placeholder: String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey_Placeholder) as? String
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKey_Placeholder, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            localizationSetup()
            updateLocalization()
        }
    }

    public var localizedAttributedTexts: [NSAttributedString]? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey) as? [NSAttributedString]
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
            text = Localized(localizedText)
        }

        if let localizedText_Placeholder = localizedText_Placeholder, !localizedText_Placeholder.isEmpty {
            //pod 'UITextView+Placeholder'
            placeholder = Localized(localizedText_Placeholder)
        }

        // 增加富文本国际化语言
        if let attributedTexts = localizedAttributedTexts, attributedTexts.count > 0 {
            let newAttributedText = attributedTexts.map { return NSAttributedString(string: Localized($0.string), attributes: $0.attributes(at: 0, effectiveRange: nil)) }

            let localizeAttributedText = newAttributedText.reduce(NSMutableAttributedString()) { (r, e) -> NSMutableAttributedString in
                r.append(e)
                return r
            }

            attributedText = localizeAttributedText
        }
    }

}
