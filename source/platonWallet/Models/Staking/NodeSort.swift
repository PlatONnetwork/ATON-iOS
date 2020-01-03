//
//  NodeSort.swift
//  platonWallet
//
//  Created by Admin on 2/1/2020.
//  Copyright © 2020 ju. All rights reserved.
//

import Foundation
import Localize_Swift

enum NodeSort {
    case rank // 排名
    case delegated //接收委托量
    case delegator // 委托者数
    case yield // 预计年化率

    var text: String {
        switch self {
        case .rank:
            return Localized("node_sort_rank")
        case .delegated:
            return Localized("node_sort_delegated")
        case .delegator:
            return Localized("node_sort_delegator")
        case .yield:
            return Localized("node_sort_yield")
        }
    }
}

