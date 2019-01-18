//
//  NodeInfo.swift
//  platonWallet
//
//  Created by matrixelement on 2018/11/2.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation
import RealmSwift

class NodeInfo: Object {
    
    static var realm: Realm!
    
    @objc dynamic private(set) var id: Int = 0
    @objc dynamic var nodeURLStr: String = ""
    @objc dynamic var isDefault: Bool = false 
    @objc dynamic var isSelected: Bool = false
    @objc dynamic var desc: String = ""
    
    override public static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(nodeURLStr: String = "", desc: String = "", isSelected: Bool = false, isDefault: Bool = false) {
        
        self.init()
        self.id = NodeInfo.autoIncrementId()
        self.nodeURLStr = nodeURLStr
        self.desc = desc
        self.isSelected = isSelected
        self.isDefault = isDefault
    }
    
    private static func autoIncrementId() -> Int {
        
        let res = realm.objects(self).sorted(byKeyPath: "id")
        if res.count > 0 {
            return res.last!.id + 1
        }else {
            return 1
        }
        
    }
    
    override func copy() -> Any {
        let newOne = NodeInfo()
        newOne.id = self.id
        newOne.nodeURLStr = self.nodeURLStr
        newOne.desc = self.desc
        newOne.isDefault = self.isDefault
        newOne.isSelected = self.isSelected
        
        return newOne
    }
    
//    public static func == (lhs: NodeInfo, rhs: NodeInfo) -> Bool {
//        return lhs.id == rhs.id
//    }
}
