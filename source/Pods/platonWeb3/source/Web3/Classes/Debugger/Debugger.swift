//
//  Debugger.swift
//  platonWeb3
//
//  Created by Ned on 10/1/2019.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation

public class Debugger{
    
    public static let instance = Debugger()
    
    public var debugMode = false
    
    public static func enableDebug(_ enable: Bool){
        Debugger.instance.debugMode = enable
    }
    
    public static func debugPrint(_ items: Any...){
        if Debugger.instance.debugMode{
            print(items)
        }
    }
}
