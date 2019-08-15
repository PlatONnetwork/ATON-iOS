//
//  PTSIndicatorInfo.swift
//  platonWallet
//
//  Created by Admin on 24/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation
import UIKit

public struct IndicatorInfo {
    
    public var title: String?
    public var image: UIImage?
    public var highlightedImage: UIImage?
    public var accessibilityLabel: String?
    public var userInfo: Any?
    
    public init(title: String?) {
        self.title = title
        self.accessibilityLabel = title
    }
    
    public init(image: UIImage?, highlightedImage: UIImage? = nil, userInfo: Any? = nil) {
        self.image = image
        self.highlightedImage = highlightedImage
        self.userInfo = userInfo
    }
    
    public init(title: String?, image: UIImage?, highlightedImage: UIImage? = nil, userInfo: Any? = nil) {
        self.title = title
        self.accessibilityLabel = title
        self.image = image
        self.highlightedImage = highlightedImage
        self.userInfo = userInfo
    }
    
    public init(title: String?, accessibilityLabel:String?, image: UIImage?, highlightedImage: UIImage? = nil, userInfo: Any? = nil) {
        self.title = title
        self.accessibilityLabel = accessibilityLabel
        self.image = image
        self.highlightedImage = highlightedImage
        self.userInfo = userInfo
    }
    
}

extension IndicatorInfo : ExpressibleByStringLiteral {
    
    public init(stringLiteral value: String) {
        title = value
        accessibilityLabel = value
    }
    
    public init(extendedGraphemeClusterLiteral value: String) {
        title = value
        accessibilityLabel = value
    }
    
    public init(unicodeScalarLiteral value: String) {
        title = value
        accessibilityLabel = value
    }
}
