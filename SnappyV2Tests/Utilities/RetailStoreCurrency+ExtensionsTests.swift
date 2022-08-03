//
//  RetailStoreCurrency+ExtensionsTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 03/08/2022.
//

import Foundation

import XCTest
@testable import SnappyV2

class RetailStoreCurrency_ExtensionsTests: XCTestCase {

    func test_toCurrencyString() {
        let currency = RetailStoreCurrency.mockedGBPData
        
        let stringCurrencyValue = currency.toCurrencyString(forValue: 2.24)
        
        XCTAssertEqual(stringCurrencyValue, "£2.24")
    }

}
