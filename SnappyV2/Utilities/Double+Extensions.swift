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
        return formatter.string(from: self as NSNumber)!
    }
}
