//
//  Double+Extensions.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 23/12/2021.
//

import Foundation

extension Double {
    func toCurrencyString() -> String {
        let formatter = NumberFormatter()
        formatter.currencyCode = AppV2Constants.Business.currencyCode
        formatter.numberStyle = .currency
        return formatter.string(from: self as NSNumber) ?? "\(self)"
    }
    
    // reason we are not passing currencyCode instead of RetailStoreCurrency
    // is because in the future RetailStoreCurrency might have more formatting
    // settings
    func toCurrencyString(using currency: RetailStoreCurrency) -> String {
        let formatter = NumberFormatter()
        formatter.currencyCode = currency.currencyCode
        formatter.numberStyle = .currency
        // Possible future extension, e.g.:
        // formatter.locale = Locale(identifier: "es_ES")
        // formatter.groupingSeparator = ","
        // formatter.decimalSeparator = "."
        // formatter.minimumFractionDigits = 2
        // formatter.maximumFractionDigits = 2
        // formatter.numberStyle = .decimal
        return formatter.string(from: self as NSNumber) ?? "\(self)"
    }

    // Rounds double to nearest specified decimal
    func round(nearest: Double) -> Double {
        let n = 1/nearest
        let numberToRound = self * n
        return numberToRound.rounded() / n
    }
}
