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
    
    func test_whenInit_thenCurrencyCorrectlyPopulated() {
        let sut = makeSUT(order: .mockedData)
        let currency = RetailStoreCurrency(currencyCode: "GBP", symbol: "&pound;", ratio: 0, symbolChar: "£", name: "Great British Pound")
        XCTAssertEqual(sut.currency, currency)
    }
    
    func test_whenInit_thenPlacedOrderLinesPopulated() {
        let sut = makeSUT(order: .mockedData)

        XCTAssertEqual(sut.placedOrderLines, PlacedOrderLine.mockedArrayData)
    }
    
    func test_whenSubstitutedLinesExist_thenPopulateLinesWithSubstitutesAndSetShowSubbedLinesToTrue() {
        let sut = makeSUT(order: .mockedDataWithSub)
        
        let linesWithSubs = [
            PlacedOrderLineWithSubstitute(originalLine: .mockedData, substitutedLine: .mockedDataSubstituteLine)
        ]
        
        XCTAssertEqual(sut.linesWithSubstitutes, linesWithSubs)
        XCTAssertTrue(sut.showSubbedLines)
    }
    
    func test_whenNoSubstitutedLinesExist_thenLinesWithSubstitutesIsNilAndSetShowSubbedLinesToFalse() {
        let sut = makeSUT(order: .mockedDataNoSubs)
        
        XCTAssertNil(sut.linesWithSubstitutes)
        XCTAssertFalse(sut.showSubbedLines)
    }
    
    func test_whenRefundedLinesExist_thenPopulateRefundedLinesAndSetShowRefundedLinesToTrue() {
        let sut = makeSUT(order: .mockedDataWithRefundedLine)
        
        XCTAssertEqual(sut.refundedLines, [PlacedOrderLine.mockedDataRefundedLine])
        XCTAssertTrue(sut.showRefundedLines)
    }
    
    func test_whenNoRefundedLinesExist_thenRefundedLinesIsNilAndSetShowRefundedLinesToFalse() {
        let sut = makeSUT(order: .mockedData)
        
        XCTAssertNil(sut.refundedLines)
        XCTAssertFalse(sut.showRefundedLines)
    }
    
    func test_whenStandardLinesExist_thenPopulateStandardLinesAndSetShowStandardLinesToTrue() {
        let sut = makeSUT(order: .mockedData)
        XCTAssertEqual(sut.standardLines, [PlacedOrderLine.mockedData])
        XCTAssertTrue(sut.showStandardLines)
    }
    
    func test_whenPricePaidCalled_thenPricePaidCorrectlyFormatted() {
        let sut = makeSUT(order: .mockedData)
        XCTAssertEqual(sut.pricePaid(line: .mockedData), "£10.00")
    }
    
    func test_whenItemNameCalled_givenNoSizeValue_thenItemNameCorrectlyFormatted() {
        let sut = makeSUT(order: .mockedData)
        let itemName = sut.itemName(.mockedData)
        XCTAssertEqual(itemName, "Max basket quantity 10")
    }
    
    func test_whenItemNameCalled_givenSizeValuePresent_thenItemNameCorrectlyFormatted() {
        let sut = makeSUT(order: .mockedData)
        let itemName = sut.itemName(.mockedDataWithSize)
        XCTAssertEqual(itemName, "Max basket quantity 10 (large)")
    }
    
    func test_whenIsRefundedItemCalled_givenRejectionReasonIsNotNilAndSubstituteLineIDISNil_thenReturnTrue() {
        let sut = makeSUT(order: .mockedData)
        let isRefunded = sut.isRefundedItem(originalLine: .mockedDataRefundedLine, substituteLine: nil)
        XCTAssertTrue(isRefunded)
    }
    
    func test_whenIsRefundedItemCalled_givenRejectionReasonIsNil_thenReturnFalse() {
        let sut = makeSUT(order: .mockedData)
        let isRefunded = sut.isRefundedItem(originalLine: .mockedData, substituteLine: nil)
        XCTAssertFalse(isRefunded)
    }
    
    func test_whenIsRefundedItemCalled_givenRejectionReasonIsNotNilAndSubstituteLineIDIsNotNil_thenReturnFalse() {
        let sut = makeSUT(order: .mockedData)
        let isRefunded = sut.isRefundedItem(originalLine: .mockedDataRefundedLine, substituteLine: .mockedData)
        XCTAssertFalse(isRefunded)
    }
    
    func test_whenGroupOptionsCalled_thenOptionsGroupedCorrectly() {
        let sut = makeSUT(order: .mockedData)
        let options = [
            PastOrderLineOption(
                id: 123,
                optionName: "Toppings",
                optionId: 345,
                name: "Cheese"),
            PastOrderLineOption(
                id: 444,
                optionName: "Toppings",
                optionId: 345,
                name: "Pineapple"),
            PastOrderLineOption(
                id: 555,
                optionName: "Toppings",
                optionId: 345,
                name: "Tomato"),
            PastOrderLineOption(
                id: 555,
                optionName: "Dip",
                optionId: 678,
                name: "Garlic")]
        
        let expectedGroupedOptions = [
            GroupedItemOption(optionName: "Toppings", selectedOptions: ["Cheese", "Pineapple", "Tomato"]),
            GroupedItemOption(optionName: "Dip", selectedOptions: ["Garlic"])
        ]
        
        let groupedOptions = sut.groupedOptions(options: options)
        XCTAssertEqual(groupedOptions, expectedGroupedOptions)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), order: PlacedOrder) -> OrderListViewModel {
        let sut = OrderListViewModel(container: container, order: order)
        
        trackForMemoryLeaks(sut)
        return sut
    }
}
