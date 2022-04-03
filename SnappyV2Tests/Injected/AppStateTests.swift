//
//  AppStateTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 03/11/2021.
//

import XCTest
@testable import SnappyV2

class AppStateTests: XCTestCase {
    
    func test_init() {
        let sut = AppState()
        
        // Routing
        XCTAssertTrue(sut.routing.showInitialView)
        XCTAssertEqual(sut.routing.selectedTab, 1)
        
        // UserData
        XCTAssertEqual(sut.userData.selectedFulfilmentMethod, .delivery)
        XCTAssertEqual(sut.userData.searchResult, .notRequested)
        XCTAssertEqual(sut.userData.selectedStore, .notRequested)
        XCTAssertNil(sut.userData.basket)
        XCTAssertNil(sut.userData.memberProfile)
        
        // System
        XCTAssertFalse(sut.system.isInForeground)
    }

}
