//
//  OrderListViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 12/04/2022.
//

import XCTest
import Combine
@testable import SnappyV2

class OrderListViewModelTests: XCTestCase {
    
    func test_init() {
        let orderLines = [PlacedOrderLine.mockedData]
        let sut = makeSUT(orderLines: orderLines)
        XCTAssertEqual(sut.orderLines, orderLines)
    }
    
    func test_whenDiscountPresent_thenItemDiscountedTrue() {
        let orderLines = [PlacedOrderLine.mockedDataDiscounted]
        let sut = makeSUT(orderLines: orderLines)
        
        XCTAssertTrue(sut.itemDiscounted(orderLines[0]))
    }
    
    func test_whenDiscountNotPresent_thenItemDiscountedFalse() {
        let orderLines = [PlacedOrderLine.mockedData]
        let sut = makeSUT(orderLines: orderLines)
        
        XCTAssertFalse(sut.itemDiscounted(orderLines[0]))
    }
    
    func test_rejectionReasonPresent_thenStrikethroughTrue() {
        let orderLines = [PlacedOrderLine.mockedDataRejectedLine]
        let sut = makeSUT(orderLines: orderLines)
        
        XCTAssertTrue(sut.strikeItem(orderLines[0]))
    }
    
    func test_discountPresent_thenStrikethroughTrue() {
        let orderLines = [PlacedOrderLine.mockedDataDiscounted]
        let sut = makeSUT(orderLines: orderLines)
        
        XCTAssertTrue(sut.strikeItem(orderLines[0]))
    }
    
    func test_discountNotPresentAndRejectionNotPresent_thenStrikethroughFalse() {
        let orderLines = [PlacedOrderLine.mockedData]
        let sut = makeSUT(orderLines: orderLines)
        
        XCTAssertFalse(sut.strikeItem(orderLines[0]))
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), services: .mocked()), orderLines: [PlacedOrderLine]) -> OrderListViewModel {
        let sut = OrderListViewModel(container: container, orderLines: orderLines)
        
        trackForMemoryLeaks(sut)
        return sut
    }
}
