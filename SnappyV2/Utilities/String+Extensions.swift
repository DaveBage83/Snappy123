//
//  String+Extensions.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 02/12/2021.
//

import Foundation

// Copied from https://www.hackingwithswift.com/example-code/strings/how-to-capitalize-the-first-letter-of-a-string
extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    var trueDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = AppV2Constants.Business.standardDateOnlyStringFormat
        return formatter.date(from: self)?.trueDate
    }
    
    var stringToDateOnly: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = AppV2Constants.Business.standardDateOnlyStringFormat
        return dateFormatter.date(from: self)
    }
    
    var stringToHoursMinsAndSecondsOnly: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = AppV2Constants.Business.hourAndMinutesAndSecondsStringFormat
        return dateFormatter.date(from: self)
    }
    
    func toTelephoneString() -> String? {
        let digits = Set("0123456789")
        let telephone = self.filter { digits.contains($0) }
        
        guard telephone.isEmpty == false else { return nil }
        return telephone
    }
}
