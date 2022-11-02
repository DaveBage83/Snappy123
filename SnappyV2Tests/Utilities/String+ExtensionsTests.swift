//
//  String+ExtensionsTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 22/06/2022.
//

import XCTest
import Combine
@testable import SnappyV2

class String_ExtensionsTests: XCTestCase {
    func test_whenToTelephoneStringCalled_thenStringFiltersOutNonDigitCharacters() {
        
        let testString = "fg019fjd345xxc45"
        let telephoneString = testString.toTelephoneString()
        
        XCTAssertEqual(telephoneString, "01934545")
    }
    
    func test_whenToTelephoneStringCalled_givenNoDigitsAreInString_thenReturnNil() {
        
        let testString = "fdghskslsls"
        let telephoneString = testString.toTelephoneString()
        
        XCTAssertNil(telephoneString)
    }
    
    func test_whenIsPostcodeCalled_givenEmptyRuleArray_thenReturnTrue() {
        let testString = "NOT_A_POSTCODE"
        XCTAssertTrue(testString.isPostcode(rules: []))
    }
    
    func test_whenIsPostcodeCalled_givenRuleArrayAndInvalidPostcode_thenReturnFalse() {
        let testString = "NOT_A_POSTCODE"
        XCTAssertFalse(testString.isPostcode(rules: PostcodeRule.mockedDataArray))
    }
    
    func test_whenIsPostcodeCalled_givenValidPostcodes_thenReturnTrue() {
        let gbTestString1 = "DD2 1RW"
        let gbTestString2 = " DD21RW "
        XCTAssertTrue(gbTestString1.isPostcode(rules: PostcodeRule.mockedDataArray))
        XCTAssertTrue(gbTestString2.isPostcode(rules: PostcodeRule.mockedDataArray))
        let ieTestString1 = "V95 Y9T4"
        let ieTestString2 = " V95Y9T4 "
        XCTAssertTrue(ieTestString1.isPostcode(rules: PostcodeRule.mockedDataArray))
        XCTAssertTrue(ieTestString2.isPostcode(rules: PostcodeRule.mockedDataArray))
    }
}
