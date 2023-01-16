//
//  OptionValueCardViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 20/08/2021.
//

import XCTest
import Combine
@testable import SnappyV2

@MainActor
class OptionValueCardViewModelTests: XCTestCase {
    
    func test_initOptionValue() {
        let sut = makeSUT(currency: RetailStoreCurrency.mockedGBPData, optionValue: initValue, optionID: 123, optionType: .checkbox)
        
        XCTAssertTrue(sut.title.isEmpty)
        XCTAssertEqual(sut.optionValueID, 12)
        XCTAssertNil(sut.sizeID)
        XCTAssertEqual(sut.optionID, 123)
        XCTAssertTrue(sut.price.isEmpty)
        XCTAssertNotNil(sut.optionController)
        XCTAssertEqual(sut.optionsType, .checkbox)
        XCTAssertEqual(sut.quantity, 0)
        XCTAssertFalse(sut.isSelected)
        XCTAssertNil(sut.sizeExtraCosts)
        XCTAssertEqual(sut.extraCost, 0)
        XCTAssertFalse(sut.showDeleteButton)
    }
    
    func test_initSize() {
        let sut = makeSUT(currency: RetailStoreCurrency.mockedGBPData, size: initSize)
        
        XCTAssertEqual(sut.title, "AnySize")
        XCTAssertEqual(sut.optionValueID, 0)
        XCTAssertEqual(sut.sizeID, 123)
        XCTAssertEqual(sut.optionID, 0)
        XCTAssertTrue(sut.price.isEmpty)
        XCTAssertNotNil(sut.optionController)
        XCTAssertEqual(sut.optionsType, .radio)
        XCTAssertEqual(sut.quantity, 0)
        XCTAssertFalse(sut.isSelected)
        XCTAssertNil(sut.sizeExtraCosts)
        XCTAssertEqual(sut.extraCost, 0)
    }
    
    func test_givenOptionControllerWithInitDict_thenQuantityIs0() {
        let sut = makeSUT(currency: RetailStoreCurrency.mockedGBPData, optionValue: initValue, optionID: 123, optionType: .checkbox)
        
        let expectation = expectation(description: "setupQuantity")
        var cancellables = Set<AnyCancellable>()
        
        sut.$quantity
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.quantity, 0)
    }
    
    func test_givenOptionControllerWithDict_whenAddKeyValue_thenQuantityIs1() {
        let sut = makeSUT(currency: RetailStoreCurrency.mockedGBPData, optionValue: initValue, optionID: 123, optionType: .checkbox)
        
        let expectation = expectation(description: "setupQuantity")
        var cancellables = Set<AnyCancellable>()
        
        sut.$quantity
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.optionController.selectedOptionAndValueIDs[123] = [12]
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.quantity, 1)
    }
    
    func test_givenOptionControllerWithDict_whenAdd2IdenticalKeyValues_thenQuantityIs2() {
        let sut = makeSUT(currency: RetailStoreCurrency.mockedGBPData, optionValue: initValue, optionID: 123, optionType: .checkbox)
        
        let expectation = expectation(description: "setupQuantity")
        var cancellables = Set<AnyCancellable>()
        
        sut.$quantity
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.optionController.selectedOptionAndValueIDs[123] = [12, 43, 21, 12]
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.quantity, 2)
    }
    
    func test_givenOptionControllerWithDict_whenAddNoMatchingValue_thenQuantityIs0() {
        let sut = makeSUT(currency: RetailStoreCurrency.mockedGBPData, optionValue: initValue, optionID: 123, optionType: .checkbox)
        
        let expectation = expectation(description: "setupQuantity")
        var cancellables = Set<AnyCancellable>()
        
        sut.$quantity
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.optionController.selectedOptionAndValueIDs[123] = [34, 43, 21, 45]
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.quantity, 0)
    }
    
    func test_givenOptionControllerWithDict_whenAdd2IdenticalKeyValuesAndAddingThird_thenQuantityIs3() {
        let sut = makeSUT(currency: RetailStoreCurrency.mockedGBPData, optionValue: initValue, optionID: 123, optionType: .checkbox)
        
        let expectation = expectation(description: "setupQuantity")
        var cancellables = Set<AnyCancellable>()
        
        sut.$quantity
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.optionController.selectedOptionAndValueIDs[123] = [12, 43, 21, 12]
        
        sut.optionController.selectedOptionAndValueIDs[123]?.append(12)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.quantity, 3)
    }
    
    func test_givenOptionControllerWithDict_whenAdd2IdenticalKeyValuesAndRemoving1_thenQuantityIs1() {
        let sut = makeSUT(currency: RetailStoreCurrency.mockedGBPData, optionValue: initValue, optionID: 123, optionType: .checkbox)
        
        let expectation = expectation(description: "setupQuantity")
        var cancellables = Set<AnyCancellable>()
        
        sut.$quantity
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.optionController.selectedOptionAndValueIDs[123] = [12, 43, 21, 12]
        
        if let index = sut.optionController.selectedOptionAndValueIDs[123]?.firstIndex(of: 12) {
            sut.optionController.selectedOptionAndValueIDs[123]?.remove(at: index)
        }
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.quantity, 1)
    }
    
    func test_givenOptionControllerWithDict_whenAddKeyValue_thenIsSelectedIsTrue() {
        let sut = makeSUT(currency: RetailStoreCurrency.mockedGBPData, optionValue: initValue, optionID: 123, optionType: .checkbox)
        
        let expectationQuantity = expectation(description: "setupQuantity")
        let expectationIsSelected = expectation(description: "setupIsSelected")
        var cancellables = Set<AnyCancellable>()
        
        sut.$quantity
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectationQuantity.fulfill()
            }
            .store(in: &cancellables)
        
        sut.$isSelected
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectationIsSelected.fulfill()
            }
            .store(in: &cancellables)
        
        sut.optionController.selectedOptionAndValueIDs[123] = [12]
        
        wait(for: [expectationQuantity, expectationIsSelected], timeout: 2)
        
        XCTAssertTrue(sut.isSelected)
        XCTAssertEqual(sut.quantity, 1)
    }
    
    func test_givenInit_whenAddValueTapped_thenQuantity1AndIsSelectedTrue() {
        let sut = makeSUT(currency: RetailStoreCurrency.mockedGBPData, optionValue: initValue, optionID: 123, optionType: .checkbox)
        
        let expectationQuantity = expectation(description: "setupQuantity")
        let expectationIsSelected = expectation(description: "setupIsSelected")
        var cancellables = Set<AnyCancellable>()
        
        sut.$quantity
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectationQuantity.fulfill()
            }
            .store(in: &cancellables)
        
        sut.$isSelected
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectationIsSelected.fulfill()
            }
            .store(in: &cancellables)
        
        sut.addValue(maxReached: .constant(false))
        
        wait(for: [expectationQuantity, expectationIsSelected], timeout: 2)
        
        XCTAssertTrue(sut.isSelected)
        XCTAssertEqual(sut.quantity, 1)
    }
    
    func test_givenInitWithValue_whenAddValueTapped_thenQuantity2AndIsSelectedTrue() {
        let sut = makeSUT(currency: RetailStoreCurrency.mockedGBPData, optionValue: initValue, optionID: 123, optionType: .stepper)
        
        let expectationQuantity = expectation(description: "setupQuantity")
        let expectationIsSelected = expectation(description: "setupIsSelected")
        var cancellables = Set<AnyCancellable>()
        
        sut.$quantity
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectationQuantity.fulfill()
            }
            .store(in: &cancellables)
        
        sut.$isSelected
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectationIsSelected.fulfill()
            }
            .store(in: &cancellables)
        
        sut.optionController.selectedOptionAndValueIDs[123] = [12]
        
        sut.addValue(maxReached: .constant(false))
        
        wait(for: [expectationQuantity, expectationIsSelected], timeout: 2)
        
        XCTAssertTrue(sut.isSelected)
        XCTAssertEqual(sut.quantity, 2)
    }
    
    func test_givenInitWithValueAndMaxReached_whenAddValueTapped_thenQuantity1AndIsSelectedTrue() {
        let sut = makeSUT(currency: RetailStoreCurrency.mockedGBPData, optionValue: initValue, optionID: 123, optionType: .stepper)
        
        let expectationQuantity = expectation(description: "setupQuantity")
        let expectationIsSelected = expectation(description: "setupIsSelected")
        var cancellables = Set<AnyCancellable>()
        
        sut.$quantity
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectationQuantity.fulfill()
            }
            .store(in: &cancellables)
        
        sut.$isSelected
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectationIsSelected.fulfill()
            }
            .store(in: &cancellables)
        
        sut.optionController.selectedOptionAndValueIDs[123] = [12]
        
        sut.addValue(maxReached: .constant(true))
        
        wait(for: [expectationQuantity, expectationIsSelected], timeout: 2)
        
        XCTAssertTrue(sut.isSelected)
        XCTAssertEqual(sut.quantity, 1)
    }
    
    func test_givenInitWith1Value_whenRemoveValueTapped_thenQuantity0AndIsSelectedFalse() {
        let sut = makeSUT(currency: RetailStoreCurrency.mockedGBPData, optionValue: initValue, optionID: 123, optionType: .checkbox)
        
        let expectationQuantity = expectation(description: "setupQuantity")
        let expectationIsSelected = expectation(description: "setupIsSelected")
        var cancellables = Set<AnyCancellable>()
        
        sut.$quantity
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectationQuantity.fulfill()
            }
            .store(in: &cancellables)
        
        sut.$isSelected
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectationIsSelected.fulfill()
            }
            .store(in: &cancellables)
        
        sut.optionController.selectedOptionAndValueIDs[123] = [12]
        
        sut.removeValue()
        
        wait(for: [expectationQuantity, expectationIsSelected], timeout: 2)
        
        XCTAssertFalse(sut.isSelected)
        XCTAssertEqual(sut.quantity, 0)
    }
    
    func test_givenInitWith3ValuesOfWhich2AreRelevant_whenRemoveValueTapped_thenQuantity1AndIsSelectedTrue() {
        let sut = makeSUT(currency: RetailStoreCurrency.mockedGBPData, optionValue: initValue, optionID: 123, optionType: .stepper)
        
        let expectationQuantity = expectation(description: "setupQuantity")
        let expectationIsSelected = expectation(description: "setupIsSelected")
        var cancellables = Set<AnyCancellable>()
        
        sut.$quantity
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectationQuantity.fulfill()
            }
            .store(in: &cancellables)
        
        sut.$isSelected
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectationIsSelected.fulfill()
            }
            .store(in: &cancellables)
        
        sut.optionController.selectedOptionAndValueIDs[123] = [12, 45, 12]
        
        sut.removeValue()
        
        wait(for: [expectationQuantity, expectationIsSelected], timeout: 2)
        
        XCTAssertTrue(sut.isSelected)
        XCTAssertEqual(sut.quantity, 1)
    }
    
    func test_givenInitOptionWithNoValue_whenToggleValueTapped_thenQuantity1AndIsSelectedTrue() {
        let sut = makeSUT(currency: RetailStoreCurrency.mockedGBPData, optionValue: initValue, optionID: 123, optionType: .checkbox)
        
        let expectationQuantity = expectation(description: "setupQuantity")
        let expectationIsSelected = expectation(description: "setupIsSelected")
        var cancellables = Set<AnyCancellable>()
        
        sut.$quantity
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectationQuantity.fulfill()
            }
            .store(in: &cancellables)
        
        sut.$isSelected
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectationIsSelected.fulfill()
            }
            .store(in: &cancellables)
        
        sut.toggleValue(maxReached: .constant(false))
        
        wait(for: [expectationQuantity, expectationIsSelected], timeout: 2)
        
        XCTAssertTrue(sut.isSelected)
        XCTAssertEqual(sut.quantity, 1)
    }
    
    func test_givenInitSizeWithNoValue_whenToggleValueTapped_thenIsSelectedTrue() {
        let sut = makeSUT(currency: RetailStoreCurrency.mockedGBPData, size: initSize)
        
        let expectation = expectation(description: "setupIsSelected")
        var cancellables = Set<AnyCancellable>()
        
        sut.$isSelected
            .collect(2)
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.toggleValue(maxReached: .constant(false))
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertTrue(sut.isSelected)
    }
    
    func test_givenInitSizeWithSameValue_whenToggleValueTapped_thenIsSelectedIsStillTrue() {
        let sut = makeSUT(currency: RetailStoreCurrency.mockedGBPData, size: initSize)
        
        let expectation1 = expectation(description: "setupIsSelected")
        let expectation2 = expectation(description: "setupIsSelected")
        var cancellables = Set<AnyCancellable>()
        
        sut.$isSelected
            .collect(2)
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation1.fulfill()
            }
            .store(in: &cancellables)
        
        sut.optionController.selectedSizeID = 123
        
        wait(for: [expectation1], timeout: 2)
        
        XCTAssertTrue(sut.isSelected)
        
        sut.$isSelected
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation2.fulfill()
            }
            .store(in: &cancellables)
        
        sut.toggleValue(maxReached: .constant(false))
        
        wait(for: [expectation2], timeout: 2)
        
        XCTAssertTrue(sut.isSelected)
    }
    
    func test_givenInitSizeWithOtherValue_whenToggleValueTapped_thenIsSelectedTrue() {
        let sut = makeSUT(currency: RetailStoreCurrency.mockedGBPData, size: initSize)
        
        let expectation1 = expectation(description: "setupIsSelected")
        let expectation2 = expectation(description: "setupIsSelected")
        var cancellables = Set<AnyCancellable>()
        
        sut.optionController.selectedSizeID = 321
        
        sut.$isSelected
            .collect(2)
            .sink { _ in
                expectation1.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation1], timeout: 5)
        
        XCTAssertFalse(sut.isSelected)
        
        sut.$isSelected
            .collect(2)
            .sink { _ in
                expectation2.fulfill()
            }
            .store(in: &cancellables)
        
        sut.toggleValue(maxReached: .constant(false))
        
        wait(for: [expectation2], timeout: 2)
        
        XCTAssertTrue(sut.isSelected)
    }
    
    func test_givenInitWith1Value_whenToggleValueTapped_thenQuantity0AndIsSelectedFalse() {
        let sut = makeSUT(currency: RetailStoreCurrency.mockedGBPData, optionValue: initValue, optionID: 123, optionType: .checkbox)
        
        sut.optionController.selectedOptionAndValueIDs[123] = [12]
        
        sut.toggleValue(maxReached: .constant(false))
        
        let expectationQuantity = expectation(description: "setupQuantity")
        let expectationIsSelected = expectation(description: "setupIsSelected")
        var cancellables = Set<AnyCancellable>()
        
        sut.$quantity
            .sink { _ in
                expectationQuantity.fulfill()
            }
            .store(in: &cancellables)
        
        sut.$isSelected
            .sink { _ in
                expectationIsSelected.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectationQuantity, expectationIsSelected], timeout: 2)
        
        XCTAssertFalse(sut.isSelected)
        XCTAssertEqual(sut.quantity, 0)
    }
    
    func test_givenInitWithOtherValue_whenAddValueTapped_thenQuantity1AndCorrectValue() {
        let sut = makeSUT(currency: RetailStoreCurrency.mockedGBPData, optionValue: initValue, optionID: 123, optionType: .radio)
        
        sut.optionController.selectedOptionAndValueIDs[123] = [23]
        
        let expectationQuantity = expectation(description: "setupQuantity")
        let expectationIsSelected = expectation(description: "setupIsSelected")
        var cancellables = Set<AnyCancellable>()
        
        sut.$quantity
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectationQuantity.fulfill()
            }
            .store(in: &cancellables)
        
        sut.$isSelected
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectationIsSelected.fulfill()
            }
            .store(in: &cancellables)
        
        sut.addValue(maxReached: .constant(false))
        
        wait(for: [expectationQuantity, expectationIsSelected], timeout: 2)
        
        XCTAssertEqual(sut.quantity, 1)
        XCTAssertEqual(sut.optionController.selectedOptionAndValueIDs[123], [12])
    }
    
    func test_givenInitWithSameValue_whenAddValueTapped_thenQuantity0AndSelectedOptionAndValueIDsIsEmpty() {
        let sut = makeSUT(currency: RetailStoreCurrency.mockedGBPData, optionValue: initValue, optionID: 123, optionType: .radio)
        
        let expectationIsSelected1 = expectation(description: #function)
        let expectationIsSelected2 = expectation(description: #function)
        var cancellables = Set<AnyCancellable>()
        
        sut.$isSelected
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectationIsSelected1.fulfill()
            }
            .store(in: &cancellables)
        
        sut.optionController.selectedOptionAndValueIDs[123] = [12]
        
        wait(for: [expectationIsSelected1], timeout: 2)
        
        sut.$isSelected
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectationIsSelected2.fulfill()
            }
            .store(in: &cancellables)
        
        sut.toggleValue(maxReached: .constant(false))
        
        wait(for: [expectationIsSelected2], timeout: 2)
        
        XCTAssertEqual(sut.quantity, 0)
        XCTAssertEqual(sut.optionController.selectedOptionAndValueIDs[123], [])
    }
    
    func test_givenInitWithNoValueAndAsManyMoreOptionType_whenToggleValueTapped_thenQuantityIs0() {
        let sut = makeSUT(currency: RetailStoreCurrency.mockedGBPData, optionValue: initValue, optionID: 123, optionType: .manyMore)
        
        let expectationQuantity = expectation(description: "setupQuantity")
        let expectationIsSelected = expectation(description: "setupIsSelected")
        var cancellables = Set<AnyCancellable>()
        
        sut.$quantity
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectationQuantity.fulfill()
            }
            .store(in: &cancellables)
        
        sut.$isSelected
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectationIsSelected.fulfill()
            }
            .store(in: &cancellables)
        
        sut.toggleValue(maxReached: .constant(false))
        
        wait(for: [expectationQuantity, expectationIsSelected], timeout: 2)
        
        XCTAssertFalse(sut.isSelected)
        XCTAssertEqual(sut.quantity, 0)
    }
    
    func test_givenInitWithNoValueAndAsStepperOptionType_whenToggleValueTapped_thenQuantityIs1() {
        let sut = makeSUT(currency: RetailStoreCurrency.mockedGBPData, optionValue: initValue, optionID: 123, optionType: .stepper)
        
        let expectationQuantity = expectation(description: "setupQuantity")
        let expectationIsSelected = expectation(description: "setupIsSelected")
        var cancellables = Set<AnyCancellable>()
        
        sut.$quantity
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectationQuantity.fulfill()
            }
            .store(in: &cancellables)
        
        sut.$isSelected
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectationIsSelected.fulfill()
            }
            .store(in: &cancellables)
        
        sut.toggleValue(maxReached: .constant(false))
        
        wait(for: [expectationQuantity, expectationIsSelected], timeout: 2)
        
        XCTAssertTrue(sut.isSelected)
        XCTAssertEqual(sut.quantity, 1)
    }
    
    func test_givenInitWithOneValueAndAsStepperOptionType_whenToggleValueTapped_thenQuantityRemains1() {
        let sut = makeSUT(currency: RetailStoreCurrency.mockedGBPData, optionValue: initValue, optionID: 123, optionType: .stepper)
        
        let expectationQuantity = expectation(description: "setupQuantity")
        let expectationQuantity2 = expectation(description: "setupQuantity")
        var cancellables = Set<AnyCancellable>()
        
        sut.$quantity
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectationQuantity.fulfill()
            }
            .store(in: &cancellables)
        
        sut.optionController.selectedOptionAndValueIDs[123] = [12]
        
        wait(for: [expectationQuantity], timeout: 2)
        
        XCTAssertEqual(sut.quantity, 1)
        
        sut.$quantity
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectationQuantity2.fulfill()
            }
            .store(in: &cancellables)
        
        sut.toggleValue(maxReached: .constant(false))

        wait(for: [expectationQuantity2], timeout: 2)
        
        XCTAssertTrue(sut.isSelected)
        XCTAssertEqual(sut.quantity, 1)
    }
    
    func test_givenInitWithOptionValueWithPrice_thenPriceMatchesCurrency() {
        let sut = makeSUT(currency: RetailStoreCurrency.mockedGBPData, optionValue: initValueWithPrice, optionID: 123, optionType: .radio)
        sut.setupPrice() // triggered by .onAppear from previous view
        
        let expectation = expectation(description: "selectedOptionAndValueIDs")
        var cancellables = Set<AnyCancellable>()
        
        sut.optionController.$selectedOptionAndValueIDs
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.optionController.selectedSizeID = 91
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.price, " + £0.50")
    }
    
    func test_givenInitWithSizeValueWithPrice_thenPriceMatchesCurrency() {
        let sut = makeSUT(currency: RetailStoreCurrency.mockedGBPData, size: initSizeWithPrice)
        
        XCTAssertEqual(sut.price, "£1.50")
    }
    
    func test_givenInitWithValueWithLargeSizePrice_thenPriceMatchesSizeExtraCost() {
        let sut = makeSUT(currency: RetailStoreCurrency.mockedGBPData, optionValue: initValueWithSizePrices, optionID: 123, optionType: .checkbox)
        sut.setupPrice() // triggered by .onAppear from previous view
        
        sut.optionController.selectedSizeID = 91
        
        let expectation = expectation(description: "selectedOptionAndValueIDs")
        var cancellables = Set<AnyCancellable>()
        
        sut.optionController.$selectedOptionAndValueIDs
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.optionController.selectedSizeID = 92
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.price, " + £2.00")
    }
    
    func test_givenInitWithValueWithLargeSizePrice_whenChangeSize_thenPriceMatchesSizeExtraCost() {
        let sut = makeSUT(currency: RetailStoreCurrency.mockedGBPData, optionValue: initValueWithSizePrices, optionID: 123, optionType: .radio)
        sut.setupPrice() // triggered by .onAppear from previous view
        
        sut.optionController.selectedSizeID = 92

        let expectation = expectation(description: "selectedOptionAndValueIDs")
        var cancellables = Set<AnyCancellable>()
        
        sut.optionController.$selectedOptionAndValueIDs
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.optionController.selectedSizeID = 91
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.price, " + £1.50")
    }
    
    func test_givenInit_whenMaximumReachedIsTrueAndValueIsSelected_thenIsDisabledIsTrue() {
        let sut = makeSUT(currency: RetailStoreCurrency.mockedGBPData, optionValue: initValue, optionID: 123, optionType: .checkbox)
        
        let expectation = expectation(description: "setupQuantity")
        var cancellables = Set<AnyCancellable>()
        
        sut.$isSelected
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.optionController.selectedOptionAndValueIDs[123] = [12]
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertFalse(sut.isDisabled(.constant(true)))
    }
    
    func test_givenInit_whenMaximumReachedIsFalseAndValueIsSelected_thenIsDisabledIsFalse() {
        let sut = makeSUT(currency: RetailStoreCurrency.mockedGBPData, optionValue: initValue, optionID: 123, optionType: .checkbox)
        
        sut.optionController.selectedOptionAndValueIDs[123] = [12]
        
        XCTAssertFalse(sut.isDisabled(.constant(false)))
    }
    
    func test_givenInitWithRadioType_whenMaximumReachedIsTrueAndValueNotIsSelected_thenIsDisabledIsFalse() {
        let sut = makeSUT(currency: RetailStoreCurrency.mockedGBPData, optionValue: initValue, optionID: 123, optionType: .radio)
        
        sut.optionController.selectedOptionAndValueIDs[123] = [13]
        
        XCTAssertFalse(sut.isDisabled(.constant(true)))
    }
    
    func test_givenInitWithStepperType_whenMaximumReachedIsTrueAndValueIsSelected_thenIsDisabledIsTrue() {
        let sut = makeSUT(currency: RetailStoreCurrency.mockedGBPData, optionValue: initValue, optionID: 123, optionType: .stepper)
        
        sut.optionController.selectedOptionAndValueIDs[123] = [12, 12]
        
        XCTAssertTrue(sut.isDisabled(.constant(true)))
    }

    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), currency: RetailStoreCurrency, optionValue: RetailStoreMenuItemOptionValue, optionID: Int, optionType: OptionValueType, optionController: OptionController = OptionController()) -> OptionValueCardViewModel {
        let sut = OptionValueCardViewModel(container: container, currency: currency, optionValue: optionValue, optionID: optionID, optionsType: optionType, optionController: OptionController())
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), currency: RetailStoreCurrency, size: RetailStoreMenuItemSize, optionController: OptionController = OptionController()) -> OptionValueCardViewModel {
        let sut = OptionValueCardViewModel(container: container, currency: currency, size: size, optionController: optionController)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
    
    let initValue = RetailStoreMenuItemOptionValue(id: 12, name: "", extraCost: 0, defaultSelection: 0, sizeExtraCost: nil)
    
    let initValueWithPrice = RetailStoreMenuItemOptionValue(id: 12, name: "", extraCost: 0.5, defaultSelection: 0, sizeExtraCost: nil)
    
    let initValueWithSizePrices = RetailStoreMenuItemOptionValue(id: 12, name: "", extraCost: 0.5, defaultSelection: 0, sizeExtraCost: [sizeS, sizeM, sizeL])
    
    private static let sizeS = RetailStoreMenuItemOptionValueSizeCost(id: 45, sizeId: 90, extraCost: 1)
    private static let sizeM = RetailStoreMenuItemOptionValueSizeCost(id: 46, sizeId: 91, extraCost: 1.5)
    private static let sizeL = RetailStoreMenuItemOptionValueSizeCost(id: 47, sizeId: 92, extraCost: 2)
    
    let initSize = RetailStoreMenuItemSize(id: 123, name: "AnySize", price: MenuItemSizePrice(price: 0))
    
    let initSizeWithPrice = RetailStoreMenuItemSize(id: 123, name: "AnySize", price: MenuItemSizePrice(price: 1.5))
}
