//
//  Date+Extensions.swift
//  SnappyV2
//
//  Created by David Bage on 25/02/2022.
//
import Foundation

extension Date {
    var isToday: Bool { Calendar.current.isDateInToday(self) }
    
    func dateOnlyString(storeTimeZone: TimeZone?) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = AppV2Constants.Business.standardDateStringFormat
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
