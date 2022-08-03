//
//  RetailStoreCurrency+Extensions.swift
//  SnappyV2
//
//  Created by Kevin Palser on 03/08/2022.
//

import Foundation

extension RetailStoreCurrency {
    func toCurrencyString(forValue value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.currencyCode = AppV2Constants.Business.currencyCode
        formatter.numberStyle = .currency
        return formatter.string(from: value as NSNumber) ?? "\(self)"
    }
}
