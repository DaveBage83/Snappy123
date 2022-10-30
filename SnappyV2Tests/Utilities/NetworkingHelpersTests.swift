//
//  NetworkingHelpersTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 21/02/2022.
//

import XCTest
@testable import SnappyV2

func encodeToAnyRemovingNSCFStrings(parameters: [String: Any]) -> [String: Any]? {
    return parameters.reduce(nil, { (dict, arg1) -> [String: Any]? in
        
        let (key, value) = arg1
        var dict = dict ?? [:]
        
        // to cope with types like __NSCFString
        if let stringValue = value as? String {
            dict[key] = stringValue
        } else if
            // to cope with nested dictionaries
            let subDictionary = value as? [String: Any],
            let anyEncodedDictionary = encodeToAnyRemovingNSCFStrings(parameters: subDictionary)
        {
            dict[key] = anyEncodedDictionary
        } else {
            dict[key] = value
        }

        return dict
    })
}

class NetworkingHelpers: XCTestCase {
    
    func test_requestBodyFrom_givenParamtersWithNestedArray_encodeNestedArray() throws {
        
        let subData: [String: Any] = [
            "SRD": "TmhxaUw1QkV0dmlsNDlGMQ==",
        ]

        let data: [String: Any] = [
            "orderId": 456556465,
            "subData": subData
        ]
        
        if let testResult = try requestBodyFrom(parameters: data) {
            // Need to convert this back into a dictionary because the JSON string
            // from the testResult will have the fields encoded in an arbitrary
            // incomparable string sequence
            if
                let jsonArray = try JSONSerialization.jsonObject(with: testResult, options: []) as? [String: Any],
                let recastArray = encodeToAnyRemovingNSCFStrings(parameters: jsonArray)
            {
                if recastArray.isEqual(to: data) {
                    XCTAssertTrue(true)
                } else {
                    XCTFail("Unexpected encodeToAny result: \(String(decoding: testResult, as: UTF8.self)) expected: \(data)", file: #file, line: #line)
                }
            } else {
                XCTFail("Expected json serializable Array from requestBodyFrom", file: #file, line: #line)
            }
        } else {
            XCTFail("Unexpected nil from requestBodyFrom", file: #file, line: #line)
        }
        
    }
    
}
