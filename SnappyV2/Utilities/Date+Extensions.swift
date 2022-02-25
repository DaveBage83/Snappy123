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
}
