//
//  String+Extensions.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 02/12/2021.
//

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
