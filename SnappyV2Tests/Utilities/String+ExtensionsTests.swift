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
}
