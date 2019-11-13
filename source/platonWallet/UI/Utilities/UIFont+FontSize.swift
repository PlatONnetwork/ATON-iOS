//
//  UIFont+FontSize.swift
//  platonWallet
//
//  Created by Admin on 11/11/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation

import UIKit

fileprivate extension Selector {
    static let sysFunc1 = #selector(UIFont.systemFont(ofSize:))
    static let myFunc1 = #selector(UIFont.systemFontX(ofSize:))
    static let sysFunc2 = #selector(UIFont.systemFont(ofSize:weight:))
    static let myFunc2 = #selector(UIFont.systemFontX(ofSize:weight:))
}

extension UIFont {

    static let AppUseFonts: [CGFloat] = [
        8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 17.0, 18.0,
        19.0, 20.0, 21.0, 22.0, 23.0, 24.0, 25.0, 26.0, 27.0, 28.0, 29.0,
        30.0, 31.0, 32.0, 33.0, 34.0, 35.0, 36.0, 37.0, 38.0, 39.0, 40.0
    ]

    public static func methodExchange() {
        DispatchQueue.once(token: "UIFont") {
            let originalSelector1 = Selector.sysFunc1
            let swizzledSelector1 = Selector.myFunc1
            let originalSelector2 = Selector.sysFunc2
            let swizzledSelector2 = Selector.myFunc2
            changeMethod(originalSelector1, swizzledSelector1, self)
            changeMethod(originalSelector2, swizzledSelector2, self)
        }
    }

    private static func changeMethod(_ original: Selector, _ swizzled: Selector, _ object: AnyClass) {
        guard let originalMethod = class_getClassMethod(object, original),
            let swizzledMethod = class_getClassMethod(object, swizzled) else {
                return
        }

        method_exchangeImplementations(originalMethod, swizzledMethod)
    }

    @objc fileprivate class func systemFontX(ofSize fontSize: CGFloat) -> UIFont {
        guard AppUseFonts.contains(fontSize) else {
            return UIFont.systemFontX(ofSize: fontSize)
        }

        let ratio = UIScreen.main.bounds.width/375
        let font = UIFont.systemFontX(ofSize: fontSize*ratio)
        return font
    }

    @objc fileprivate class func systemFontX(ofSize fontSize: CGFloat, weight: UIFont.Weight) -> UIFont {
        guard AppUseFonts.contains(fontSize) else {
            return UIFont.systemFontX(ofSize: fontSize, weight: weight)
        }

        let ratio = UIScreen.main.bounds.width/375
        let font = UIFont.systemFontX(ofSize: fontSize*ratio, weight: weight)
        return font
    }
}

extension UIFont {
    func getFontWeight() -> UIFont.Weight {
        let fontAttributeKey = UIFontDescriptor.AttributeName.init(rawValue: "NSCTFontUIUsageAttribute")
        if let fontWeight = self.fontDescriptor.fontAttributes[fontAttributeKey] as? String {
            switch fontWeight {

            case "CTFontBoldUsage":
                return UIFont.Weight.bold

            case "CTFontBlackUsage":
                return UIFont.Weight.black

            case "CTFontHeavyUsage":
                return UIFont.Weight.heavy

            case "CTFontUltraLightUsage":
                return UIFont.Weight.ultraLight

            case "CTFontThinUsage":
                return UIFont.Weight.thin

            case "CTFontLightUsage":
                return UIFont.Weight.light

            case "CTFontMediumUsage":
                return UIFont.Weight.medium

            case "CTFontDemiUsage":
                return UIFont.Weight.semibold

            case "CTFontRegularUsage":
                return UIFont.Weight.regular

            default:
                return UIFont.Weight.regular
            }
        }

        return UIFont.Weight.regular
    }
}
