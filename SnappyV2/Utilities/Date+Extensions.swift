//
//  Date+Extensions.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 17/02/2022.
//

import Foundation

// From: https://stackoverflow.com/questions/13324633/nsdate-beginning-of-day-and-end-of-day
extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
    
    var isToday: Bool { Calendar.current.isDateInToday(self) }

	func hourMinutesString(timeZone: TimeZone?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = AppV2Constants.Business.hourAndMinutesStringFormat
        dateFormatter.timeZone = timeZone
        return dateFormatter.string(from: self)
    }
    
    func hourMinutesSecondsString(timeZone: TimeZone?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = AppV2Constants.Business.hourAndMinutesAndSecondsStringFormat
        dateFormatter.timeZone = timeZone
        return dateFormatter.string(from: self)
    }

	func dateOnlyString(storeTimeZone: TimeZone?) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = AppV2Constants.Business.standardDateOnlyStringFormat
        if let storeTimeZone = storeTimeZone {
            formatter.timeZone = storeTimeZone
        }
        
        return formatter.string(from: self)
    }
    
    func dateShortString(storeTimeZone: TimeZone?) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd-MMM"
        if let storeTimeZone = storeTimeZone {
            formatter.timeZone = storeTimeZone
        }
        
        return formatter.string(from: self)
    }
    
    func timeString(storeTimeZone: TimeZone?) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        if let storeTimeZone = storeTimeZone {
            formatter.timeZone = storeTimeZone
        }
        return formatter.string(from: self)
    }
}
