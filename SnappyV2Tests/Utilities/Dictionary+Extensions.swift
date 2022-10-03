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
        XCTAssertFalse(dict1.isEqual(to: dict2))
    }
    
    func test_dictionayWithAnyisEqual_whenValuesMatch_returnTrue() {
        let facebookParamsKeySubDictionary: [AppEvents.ParameterName: Any] = [
            .description: "test"
        ]
        let anyHashableKeySubDictionary: [AnyHashable: Any] = [
            "cafe\u{301}": "test"
        ]
        let stringKeySubDictionary: [String: Any] = [
            "key": "test"
        ]
        let dict1: [String: Any] = [
            "id": 12345,
            "name": "Rahul Katariya",
            "weight": 70.7,
            "facebookParams": facebookParamsKeySubDictionary,
            "anyHashableParams": anyHashableKeySubDictionary,
            "stringParams": stringKeySubDictionary,
            "facebookParamsArray": [facebookParamsKeySubDictionary],
            "anyHashableParamsArray": [anyHashableKeySubDictionary],
            "stringParamsArray": [stringKeySubDictionary]
        ]
        let dict2: [String: Any] = [
            "id": 12345,
            "name": "Rahul Katariya",
            "weight": 70.7,
            "facebookParams": facebookParamsKeySubDictionary,
            "anyHashableParams": anyHashableKeySubDictionary,
            "stringParams": stringKeySubDictionary,
            "facebookParamsArray": [facebookParamsKeySubDictionary],
            "anyHashableParamsArray": [anyHashableKeySubDictionary],
            "stringParamsArray": [stringKeySubDictionary]
        ]
        XCTAssertTrue(dict1.isEqual(to: dict2))
    }
    
    func test_dictionayWithAnyisEqual_whenValuesMatchWithUnhandledType_returnFalse() {
        class Foo {}
        let dict1: [String: Any] = ["id": Foo(), "name": "Rahul Katariya", "weight": 70.7]
        let dict2: [String: Any] = ["id": Foo(), "name": "Rahul Katariya", "weight": 70.7]
        XCTAssertFalse(dict1.isEqual(to: dict2))
    }

}
