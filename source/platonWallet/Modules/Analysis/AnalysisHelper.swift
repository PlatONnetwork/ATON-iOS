//
//  AnalysisHelper.swift
//  platonWallet
//
//  Created by Ned on 2019/8/17.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation

let event_send = "event_send"
let event_delegate = "event_delegate"
let event_redeem = "event_redeem"
let event_newWallet = "event_newWallet"

enum EventOperation {
    case begin, cancel, end
}

var eventTime: [String: Date] = [:]

class AnalysisHelper {
    
    static func handleEvent(id: String, operation: EventOperation, attributes: [AnyHashable: Any]? = nil){
        switch operation {
        
        case .begin:
            eventTime[id] = Date()
        case .cancel:
            eventTime.removeValue(forKey: id)
        case .end:
            guard let beginTime = eventTime[id] else{
                return
            }
            let duration = Int32(Date().timeIntervalSince(beginTime) * 1000)
            if let att = attributes{
                MobClick.event(id, attributes: att, durations: duration)
            }else{
                MobClick.event(id, durations: duration)
            }
            
        }
    }
    
}
