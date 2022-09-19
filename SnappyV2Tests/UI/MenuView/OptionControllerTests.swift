//
//  OptionControllerTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 31/08/2021.
//

import XCTest
@testable import SnappyV2

@MainActor
class OptionControllerTests: XCTestCase {

    func test_init() {
        let sut = makeSUT()
        
        XCTAssertTrue(sut.selectedOptionAndValueIDs.isEmpty)
        XCTAssertTrue(sut.actualSelectedOptionsAndValueIDs.isEmpty)
    }
    
    func makeSUT() -> OptionController {
        let sut = OptionController()
        
        return sut
    }

}
