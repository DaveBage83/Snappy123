//
//  Dictionary+Extensions.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 20/02/2022.
//

import XCTest

// 3rd Party
import FBSDKCoreKit

@testable import SnappyV2

class Dictionary_ExtensionsTests: XCTestCase {

    func test_dictionayWithAnyisEqual_whenValuesDoNotMatch_returnFalse() {
        let dict1: [String: Any] = ["id": 12345, "name": "Rahul Katariya", "weight": 70.7]
        let dict2: [String: Any] = ["id": 12346, "name": "Aar Kay", "weight": 83.1]
        XCTAssertEqual(dict1.isEqual(to: dict2), false)
    }
    
    func test_dictionayWithAnyisEqual_whenValuesMatch_returnTrue() {
        let facebookParams: [AppEvents.ParameterName: Any] = [
            .description: "test"
        ]
        let anyHashable: [AnyHashable: Any] = [
            "cafe\u{301}": "test"
        ]
        let dict1: [String: Any] = ["id": 12345, "name": "Rahul Katariya", "weight": 70.7, "facebookParams": facebookParams, "anyHashableParams": anyHashable]
        let dict2: [String: Any] = ["id": 12345, "name": "Rahul Katariya", "weight": 70.7, "facebookParams": facebookParams, "anyHashableParams": anyHashable]
        XCTAssertEqual(dict1.isEqual(to: dict2), true)
    }
    
    func test_dictionayWithAnyisEqual_whenValuesMatchWithUnhandledType_returnFalse() {
        class Foo {}
        let dict1: [String: Any] = ["id": Foo(), "name": "Rahul Katariya", "weight": 70.7]
        let dict2: [String: Any] = ["id": Foo(), "name": "Rahul Katariya", "weight": 70.7]
        XCTAssertEqual(dict1.isEqual(to: dict2), false)
    }

}
