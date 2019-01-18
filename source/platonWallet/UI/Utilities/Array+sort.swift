//
//  Array+sort.swift
//  platonWallet
//
//  Created by Ned on 11/12/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation

extension Array{
    mutating func txSort(){
        self.sort(by: { (obj1, obj2) -> Bool in
            if let obj1 = obj1 as? Transaction, let obj2 = obj2 as? Transaction{
                return obj1.createTime > obj2.createTime
            }else if let obj1 = obj1 as? STransaction , let obj2 = obj2 as? Transaction{
                return Int(obj1.createTime) > obj2.createTime
            }else if let obj1 = obj1 as? Transaction , let obj2 = obj2 as? STransaction{
                return obj1.createTime > Int(obj2.createTime)
            }else if let obj1 = obj1 as? STransaction , let obj2 = obj2 as? STransaction{
                return obj1.createTime > obj2.createTime
            }
            return false
        })
    }
}
