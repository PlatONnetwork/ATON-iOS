//
//  HDPath.swift
//  platonWallet
//
//  Created by matrixelement on 2018/10/17.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation

struct HDPath {

    var pathStr : String

    var indices : [UInt32]? {

        let components = pathStr.split(separator: "/")
        var indices:[UInt32] = []
        for component in components {
            if component == "m" {
                continue
            }
            if component.hasSuffix("'") {
                guard let index = Int(component.dropLast()) else {
                    return nil
                }
                indices.append((UInt32(index) | 0x80000000))
            } else {
                guard let index = Int(component) else {
                    return nil
                }
                indices.append(UInt32(index))
            }
        }
        guard indices.count == 5 else {
            return nil
        }

        return indices

    }

}
