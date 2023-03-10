//
//  Double+Extensions.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 23/12/2021.
//

import Foundation

extension Double {
    // reason we are not passing currencyCode instead of RetailStoreCurrency
    // is because in the future RetailStoreCurrency might have more formatting
    // settings
    func toCurrencyString(using currency: RetailStoreCurrency, roundWholeNumbers: Bool = false) -> String {
        let formatter = NumberFormatter()
        formatter.currencyCode = currency.currencyCode
        formatter.numberStyle = .currency
        
        if roundWholeNumbers, self.truncatingRemainder(dividingBy: 1) == 0 {
            formatter.maximumFractionDigits = 0
        }

        // Possible future extension, e.g.:
        // formatter.locale = Locale(identifier: "es_ES")
        // formatter.groupingSeparator = ","
        // formatter.decimalSeparator = "."
        // formatter.minimumFractionDigits = 2
        // formatter.maximumFractionDigits = 2
        // formatter.numberStyle = .decimal
        return formatter.string(from: self as NSNumber) ?? "NaN"
    }

    // Rounds double to nearest specified decimal
    func round(nearest: Double) -> Double {
        let n = 1/nearest
        let numberToRound = self * n
        return numberToRound.rounded() / n
    }
}
