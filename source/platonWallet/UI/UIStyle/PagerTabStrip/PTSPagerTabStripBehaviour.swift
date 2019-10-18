//
//  PTSPagerTabStripBehaviour.swift
//  platonWallet
//
//  Created by Admin on 24/7/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation

public enum PagerTabStripBehaviour {

    case common(skipIntermediateViewControllers: Bool)
    case progressive(skipIntermediateViewControllers: Bool, elasticIndicatorLimit: Bool)

    public var skipIntermediateViewControllers: Bool {
        switch self {
        case .common(let skipIntermediateViewControllers):
            return skipIntermediateViewControllers
        case .progressive(let skipIntermediateViewControllers, _):
            return skipIntermediateViewControllers
        }
    }

    public var isProgressiveIndicator: Bool {
        switch self {
        case .common:
            return false
        case .progressive:
            return true
        }
    }

    public var isElasticIndicatorLimit: Bool {
        switch self {
        case .common:
            return false
        case .progressive(_, let elasticIndicatorLimit):
            return elasticIndicatorLimit
        }
    }
}
