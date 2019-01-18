//
//  Date+Extenstions.swift
//  platonWallet
//
//  Created by matrixelement on 25/10/2018.
//  Copyright © 2018 ju. All rights reserved.
//

import Foundation

extension Date {
    var millisecondsSince1970:Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
    
    public static func toStanderTimeDescrition(millionSecondsTimeStamp : Int) -> String?{
        let date = Date(timeIntervalSince1970: (Double(millionSecondsTimeStamp) * 0.001))
        let dateFormatter = DateFormatter()
        
        let localZone = NSTimeZone.local
        /*
        let systemZone = NSTimeZone.system
        let defaultZone = NSTimeZone.default
         */
        dateFormatter.timeZone = localZone
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let strDate = dateFormatter.string(from: date)
        return strDate
    }
}
