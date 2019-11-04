//
//  NodeInfo.swift
//  platonWallet
//
//  Created by matrixelement on 2018/11/2.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import RealmSwift

enum NodeActionStatus {
    case none
    case create
    case edit
    case delete
}

class NodeInfo: Object {

    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var nodeURLStr: String = ""
    @objc dynamic var isDefault: Bool = false
    @objc dynamic var isSelected: Bool = false
    @objc dynamic var desc: String = ""
    @objc dynamic var chainId: String = ""

    var status: NodeActionStatus = .none

    override public static func primaryKey() -> String? {
        return "id"
    }

    override public static func ignoredProperties() -> [String] {
        return ["status"]
    }

    convenience init(nodeURLStr: String = "", desc: String = "", chainId: String?, isSelected: Bool = false, isDefault: Bool = false) {

        self.init()
        self.id = UUID().uuidString
        self.nodeURLStr = nodeURLStr
        self.desc = desc
        self.isSelected = isSelected
        self.isDefault = isDefault
        self.chainId = chainId ?? nodeURLStr.chainid
    }

    override func copy() -> Any {
        let newOne = NodeInfo()
        newOne.id = self.id
        newOne.nodeURLStr = self.nodeURLStr
        newOne.desc = self.desc
        newOne.isDefault = self.isDefault
        newOne.isSelected = self.isSelected
        newOne.chainId = self.chainId

        return newOne
    }
}

extension Sequence where Iterator.Element: NodeInfo {
    var notDeleteArray: [Element] {
        return self.filter { $0.status != .delete }
    }
}
