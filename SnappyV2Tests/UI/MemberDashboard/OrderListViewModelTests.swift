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
    
    func test_whenInit_givenSubLinesExist_thenPopulatePairedLinesAccordingly() {
        let orderLines = [
            PlacedOrderLine.mockedData,
            PlacedOrderLine.mockedDataSubstituteLine
        ]
        
        let sut = makeSUT(orderLines: orderLines)
        
        XCTAssertEqual(sut.groupedOrderLines.count, 1)
        XCTAssertEqual(sut.groupedOrderLines, [[
            PlacedOrderLine.mockedDataSubstituteLine,
            PlacedOrderLine.mockedData]])
    }
    
    func test_whenInit_givenNoMatchingSublines_thenPopulatePairedLinesAccordingly() {
        let orderLines = [
            PlacedOrderLine.mockedData,
            PlacedOrderLine.mockedData
        ]
        
        let sut = makeSUT(orderLines: orderLines)
        
        XCTAssertEqual(sut.groupedOrderLines.count, 2)
        XCTAssertEqual(sut.groupedOrderLines, [[
            PlacedOrderLine.mockedData], [PlacedOrderLine.mockedData]])
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), orderLines: [PlacedOrderLine]) -> OrderListViewModel {
        let sut = OrderListViewModel(container: container, orderLines: orderLines)
        
        trackForMemoryLeaks(sut)
        return sut
    }
}
