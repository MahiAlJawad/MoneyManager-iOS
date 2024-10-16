//
//  DateExtensions.swift
//  MoneyManager-iOS
//
//  Created by Mahi Al Jawad on 16/10/24.
//

import Foundation

extension Date {
    var resetTimeComponents: Date {
        var components = Calendar.current.dateComponents(in: TimeZone.gmt, from: self)
        components.hour = 0
        components.minute = 0
        components.second = 0
        components.nanosecond = 0
        
        guard let date = components.date else {
            print("Error resting date's time components")
            return self
        }
        
        return date
    }
}
