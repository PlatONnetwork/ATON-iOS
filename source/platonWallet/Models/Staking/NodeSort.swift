//
//  NodeSort.swift
//  platonWallet
//
//  Created by Admin on 2/1/2020.
//  Copyright © 2020 ju. All rights reserved.
//

import Foundation
import Localize_Swift
import RealmSwift

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

extension NodeSort {
    var sortArray: [SortDescriptor] {
        switch self {
        case .rank:
            let sortPropertis = [
                SortDescriptor(keyPath: "ranking", ascending: true),
                SortDescriptor(keyPath: "delegateSum", ascending: false),
                SortDescriptor(keyPath: "delegate", ascending: false),
                SortDescriptor(keyPath: "delegatedRatePA", ascending: false)
            ]
            return sortPropertis
        case .delegated:
            let sortPropertis = [
                SortDescriptor(keyPath: "delegateSum", ascending: false),
                SortDescriptor(keyPath: "ranking", ascending: true),
                SortDescriptor(keyPath: "delegate", ascending: false),
                SortDescriptor(keyPath: "delegatedRatePA", ascending: false)
            ]
            return sortPropertis
        case .delegator:
            let sortPropertis = [
                SortDescriptor(keyPath: "delegate", ascending: false),
                SortDescriptor(keyPath: "delegateSum", ascending: false),
                SortDescriptor(keyPath: "ranking", ascending: true),
                SortDescriptor(keyPath: "delegatedRatePA", ascending: false)
            ]
            return sortPropertis
        case .yield:
            let sortPropertis = [
                SortDescriptor(keyPath: "delegatedRatePA", ascending: false),
                SortDescriptor(keyPath: "ranking", ascending: true),
                SortDescriptor(keyPath: "delegateSum", ascending: false),
                SortDescriptor(keyPath: "delegate", ascending: false)
            ]
            return sortPropertis
        }
    }
}

