//
//  String+Extensions.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 02/12/2021.
//

// Copied from https://www.hackingwithswift.com/example-code/strings/how-to-capitalize-the-first-letter-of-a-string
extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
