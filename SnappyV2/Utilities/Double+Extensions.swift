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
}

// Rounds double to nearest specified decimal
extension Double {
    func round(nearest: Double) -> Double {
        let n = 1/nearest
        let numberToRound = self * n
        return numberToRound.rounded() / n
    }
}
