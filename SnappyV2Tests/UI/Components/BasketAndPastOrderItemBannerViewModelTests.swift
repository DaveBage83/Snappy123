//
//  BasketAndPastOrderItemBannerViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 12/09/2022.
//

import XCTest
@testable import SnappyV2

class BasketAndPastOrderItemBannerViewModelTests: XCTestCase {
    func test_whenActionIsNil_thenShowBannerActionButtonIsFalse() {
        let details = BannerDetails(type: .substitutedItem, text: "Test", action: nil)
        let sut = makeSUT(details: details, isBottomBanner: false)
        XCTAssertFalse(sut.showBannerActionButton)
    }
    
    func test_whenActionIsNotNil_thenShowBannerActionButtonIsTrueAndActionPassedIn() {
        var test = "Testing"
        let details = BannerDetails(type: .substitutedItem, text: "Test", action: { test = "Test successful" })
        let sut = makeSUT(details: details, isBottomBanner: false)
        XCTAssertTrue(sut.showBannerActionButton)
        if let tapAction = sut.tapAction {
            tapAction()
            XCTAssertEqual(test, "Test successful")
        } else {
            XCTFail("Tap action not present")
        }
    }
    
    func test_whenIsBottomBanner_thenCurveBottomCornersIsTrue() {
        let details = BannerDetails(type: .substitutedItem, text: "Test", action: nil)
        let sut = makeSUT(details: details, isBottomBanner: true)
        XCTAssertTrue(sut.curveBottomCorners)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), details: BannerDetails, isBottomBanner: Bool) -> BasketAndPastOrderItemBannerViewModel {
        let sut = BasketAndPastOrderItemBannerViewModel(container: container, banner: details, isBottomBanner: isBottomBanner)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
    
}
