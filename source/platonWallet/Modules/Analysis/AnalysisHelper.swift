//
//  AnalysisHelper.swift
//  platonWallet
//
//  Created by Ned on 2019/8/17.
//  Copyright © 2019 ju. All rights reserved.
//

import Foundation

let event_launch = "event_launch"
let event_send = "event_send"
let event_delegate = "event_entrust"
let event_redeem = "event_redeem"
let event_newWallet = "event_newWallet"

enum EventOperation {
    case begin, cancel, end
}

var eventTime: [String: Date] = [:]

class AnalysisHelper {

    static func handleEvent(id: String, operation: EventOperation, attributes: [AnyHashable: Any]? = nil) {
        switch operation {

        case .begin:
            eventTime[id] = Date()
        case .cancel:
            eventTime.removeValue(forKey: id)
        case .end:
            guard let beginTime = eventTime[id] else {
                return
            }
            let durationSec = Date().timeIntervalSince(beginTime)
            let durationMillion = Int32(durationSec * 1000)
            var allAtt : [AnyHashable: Any] = [:]
            if let att = attributes {
                for (k,v) in att.enumerated() {
                    allAtt[k] = v
                }
            }

            allAtt["durationTime"] = String(format: "%ds", Int(durationSec))
            MobClick.event(id, attributes: allAtt, durations: durationMillion)

        }
    }

    static func handleEvent(id: String) {
        MobClick.event(id)
    }
}
