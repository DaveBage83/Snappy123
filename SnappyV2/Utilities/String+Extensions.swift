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
        formatter.dateFormat = AppV2Constants.Business.standardDateStringFormat
        return formatter.date(from: self)?.trueDate
    }
}
