//
//  OrderLineViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 12/09/2022.
//

import XCTest
@testable import SnappyV2

class OrderLineViewModelTests: XCTestCase {
    
    func test_whenMainOrderLineIsCalled_thenLineWithoutSubstituteOrderLineIdIsSet() {
        
        let orderLines = [PlacedOrderLine.mockedDataSubstituteLine,
                          PlacedOrderLine.mockedData,
                          PlacedOrderLine.mockedDataSubstituteLine]
        
        let sut = makeSUT(orderLines: orderLines)
        
        XCTAssertEqual(sut.mainOrderLine, PlacedOrderLine.mockedData)
        XCTAssertEqual(sut.substituteLines, [PlacedOrderLine.mockedDataSubstituteLine, PlacedOrderLine.mockedDataSubstituteLine])
    }
    
    // We should never hit this scenario as we should only pass items in where one line has
    // no substitutesOrderLineId but testing to ensure this scenario handled safely
    func test_whenNoOrderLineHasSubstitutesOrderLineIdAsNil_thenMainOrderLineNil() {
        let orderLines = [PlacedOrderLine.mockedDataSubstituteLine,
                          PlacedOrderLine.mockedDataSubstituteLine]
        
        let sut = makeSUT(orderLines: orderLines)
        
        XCTAssertNil(sut.mainOrderLine)
    }
    
    func test_whenSubOrderLinesPresentButNoneOfTheSubstitutesOrderLineIdMatchMainOrderLineId_thenSubOrderLinesNil() {
        let orderLines = [PlacedOrderLine.mockedDataSubstitutedLineNonMatchingSubstituteOrderLineId,
                          PlacedOrderLine.mockedData
        ]
        
        let sut = makeSUT(orderLines: orderLines)
        
        XCTAssertNil(sut.substituteLines)
    }
    
    func test_whenNoSublines_thenAllSameItemIsTrue() {
        let orderLines = [PlacedOrderLine.mockedData]
        
        let sut = makeSUT(orderLines: orderLines)
        
        XCTAssertTrue(sut.allSameItem)
    }
    
    func test_whenMainItemLineIsNil_thenAllSameItemIsTrue() {
        let orderLines = [PlacedOrderLine.mockedDataSubstituteLine]
        
        let sut = makeSUT(orderLines: orderLines)
        
        XCTAssertTrue(sut.allSameItem)
    }
    
    func test_whenAllSubLinesHaveSameItemIdAsMainItemLine_thenAllSameItemIsTrue() {
        let orderLines = [PlacedOrderLine.mockedDataSubstituteLine,
                          PlacedOrderLine.mockedData,
                          PlacedOrderLine.mockedDataSubstituteLine]
        
        let sut = makeSUT(orderLines: orderLines)
        
        XCTAssertTrue(sut.allSameItem)
    }
    
    func test_whenSubLinesContainAtLeast1ItemWithDifferentIdToMainOrderLine_thenAllSameItemIsFalse() {
        let orderLines = [PlacedOrderLine.mockedDataSubstituteLine,
                          PlacedOrderLine.mockedData,
                          PlacedOrderLine.mockedDataSubstitutedLineWithNonMatchingItem]
        
        let sut = makeSUT(orderLines: orderLines)
        
        XCTAssertFalse(sut.allSameItem)
    }
    
    func test_whenOrderLinesCountIs1_thenOrderLineDisplayTypeIsSingleItem() {
        let orderLines = [PlacedOrderLine.mockedData]
        
        let sut = makeSUT(orderLines: orderLines)
        XCTAssertEqual(sut.orderLineDisplayType, .singleItem)
    }
    
    func test_whenOrderLinesCountIsMoreThan1AndAllSameItemTrue_thenOrderLineDisplayTypeIsItemWithQuantityChange() {
        let orderLines = [PlacedOrderLine.mockedData, PlacedOrderLine.mockedDataSubstituteLine]
        
        let sut = makeSUT(orderLines: orderLines)
        XCTAssertEqual(sut.orderLineDisplayType, .itemWithQuantityChange)
    }
    
    func test_whenOrderLinesCountIsMoreThan1AndSameItemFalse_thenOrderLineDisplayTypeIsItemWithSubs() {
        let orderLines = [PlacedOrderLine.mockedData, PlacedOrderLine.mockedDataSubstitutedLineWithNonMatchingItem]
        
        let sut = makeSUT(orderLines: orderLines)
        XCTAssertEqual(sut.orderLineDisplayType, .itemWithSubs)
    }
    
    func test_whenOrderLinesCountIsMoreThan1AndLineRejectionReasonIsNil_givenSubstitutesOrderLineIdIsNil_thenShouldStrikeThroughIsTrue() {
        let orderLines = [PlacedOrderLine.mockedData, PlacedOrderLine.mockedDataSubstitutedLineWithNonMatchingItem]
        
        let sut = makeSUT(orderLines: orderLines)
        let testLine = PlacedOrderLine.mockedData
        
        XCTAssertTrue(sut.shouldStrikeThrough(testLine))
    }
    
    func test_whenOrderLinesCountIsNotGreaterThan1_givenRejectionReasonIsNotNil_thenShouldStrikeThroughIsTrue() {
        let orderLines = [PlacedOrderLine.mockedData]
        
        let sut = makeSUT(orderLines: orderLines)
        let testLine = PlacedOrderLine.mockedDataRejectedLine
        
        XCTAssertTrue(sut.shouldStrikeThrough(testLine))
    }
    
    func test_whenOrderLinesCountIsNotGreaterThan1_givenRejectionReasonIsNil_thenShouldStrikeThroughIsFalse() {
        let orderLines = [PlacedOrderLine.mockedData]
        
        let sut = makeSUT(orderLines: orderLines)
        let testLine = PlacedOrderLine.mockedData
        
        XCTAssertFalse(sut.shouldStrikeThrough(testLine))
    }
    
    func test_whenPricePaidCalled_thenCorrectPriceStringFormatReturned() {
        let orderLines = [PlacedOrderLine.mockedData]
        
        let sut = makeSUT(orderLines: orderLines)
        let testLine = PlacedOrderLine.mockedData
        
        XCTAssertEqual(sut.pricePaid(line: testLine), "£10.00")
    }
    
    func test_whenItemNameCalled_givenItemHasSize_thenCorrectItemNameStringFormatReturned() {
        let orderLines = [PlacedOrderLine.mockedData]
        
        let sut = makeSUT(orderLines: orderLines)
        let testItem = PastOrderLineItem.mockedDataWithSize
        
        XCTAssertEqual(sut.itemName(testItem), "Max basket quantity 10 (Large)")
    }
    
    func test_whenItemNameCalled_givenItemHasNoSize_thenCorrectItemNameStringFormatReturned() {
        let orderLines = [PlacedOrderLine.mockedData]
        
        let sut = makeSUT(orderLines: orderLines)
        let testItem = PastOrderLineItem.mockedData
        
        XCTAssertEqual(sut.itemName(testItem), "Max basket quantity 10")
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), orderLines: [PlacedOrderLine]) -> OrderLineViewModel {
        let sut = OrderLineViewModel(container: container, orderLines: orderLines)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
