//
//  Array+ExtensionsTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 15/06/2022.
//

import XCTest
@testable import SnappyV2

class Array_ExtensionsTests: XCTestCase {
    func test_whenArraySplitWithChunked_thenEmbeddedArrayReturned() {
        let testArray = ["Test1", "Test2", "Test3", "Test4", "Test5", "Test6", "Test7"]
        
        let chunkedArray = testArray.chunked(into: 3)
        
        XCTAssertEqual(chunkedArray, [
            ["Test1", "Test2", "Test3"],
            ["Test4", "Test5", "Test6"],
            ["Test7"]
        ])
    }
}
