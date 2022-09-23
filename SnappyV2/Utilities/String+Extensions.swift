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
    
    // For use with non mutatable constants
    var firstLetterCapitalized: String {
        return self.capitalizingFirstLetter()
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
    
    /// Unlike capitalizingFirstLetter(), this method first transforms the string to lowercase and then capitalizes
    /// the first letter ensuring strings which have multiple words capitalized will only have the first letter of the
    /// first word capitalized after transformation
    func capitalizingFirstLetterOnly() -> String {
        return self.lowercased().capitalizingFirstLetter()
    }
}

extension String {
    var isEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }
}

// Adapted from https://stackoverflow.com/questions/34454532/how-add-separator-to-string-at-every-n-characters-in-swift
// Allows us to divide card string into batches of 4
extension String {
    var cardNumberFormat: String {
        let numberOfCharacters = self.count
        
        guard numberOfCharacters > 4 else {
            return self
        }
        
        let newString = String(repeating: "∗", count: numberOfCharacters - 4)
        let last4 = self.suffix(4)
        return newString.appending(last4).unfoldSubSequences(limitedTo: 4).joined(separator: " ")
    }
}

extension String {
    var telephoneNumber: String {
        return "tel://\(self)"
    }
}
