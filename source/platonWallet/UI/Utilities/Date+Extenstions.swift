//
//  Date+Extenstions.swift
//  platonWallet
//
//  Created by matrixelement on 25/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation

let dateFormatterInExtension = DateFormatter()
let dateFormatterMutable = DateFormatter()
extension Date {

    var millisecondsSince1970:Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }

    init(milliseconds:UInt64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }

    public static func toStanderTimeDescrition(millionSecondsTimeStamp : Int) -> String? {
        let date = Date(timeIntervalSince1970: TimeInterval(millionSecondsTimeStamp/1000))
        let localZone = NSTimeZone.local
        /*
        let systemZone = NSTimeZone.system
        let defaultZone = NSTimeZone.default
         */
        dateFormatterInExtension.timeZone = localZone
        dateFormatterInExtension.locale = NSLocale.current
        dateFormatterInExtension.dateFormat = "yyyy-MM-dd HH:mm"
        let strDate = dateFormatterInExtension.string(from: date)
        return strDate
    }

    public func toFormatter(_ formatter: String) -> String {

        let localZone = NSTimeZone.local
        dateFormatterMutable.timeZone = localZone
        dateFormatterMutable.locale = NSLocale.current
        dateFormatterMutable.dateFormat = formatter
        let strDate = dateFormatterMutable.string(from: self)
        return strDate
    }
}
