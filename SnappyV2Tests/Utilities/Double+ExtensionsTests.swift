//
//  Double+ExtensionsTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 23/12/2021.
//

import XCTest
@testable import SnappyV2

class Double_ExtensionsTests: XCTestCase {    
    func test_doubleToCurrencyStringWithRetailStoreCurrency() {
        let doubleValue = 2.24
        let currency = RetailStoreCurrency.mockedGBPData
        
        let stringCurrencyValue = doubleValue.toCurrencyString(using: currency)
        
        XCTAssertEqual(stringCurrencyValue, "£2.24")
    }
}
