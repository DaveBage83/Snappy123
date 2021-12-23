//
//  Double+ExtensionsTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 23/12/2021.
//

import XCTest
@testable import SnappyV2

class Double_ExtensionsTests: XCTestCase {

    func test_doubleToCurrencyString() {
        let doubleValue = 2.24
        
        let stringCurrencyValue = doubleValue.toCurrencyString()
        
        XCTAssertEqual(stringCurrencyValue, "£2.24")
    }

}
