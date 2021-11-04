//
//  OptionValueCardViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 20/08/2021.
//

import XCTest
import Combine
@testable import SnappyV2

class OptionValueCardViewModelTests: XCTestCase {
    
    func test_initOptionValue() {
        let sut = makeSUT(optionValue: initValue, optionID: 123, optionType: .checkbox)
        
        XCTAssertEqual(sut.title, "Unnamed option")
        XCTAssertEqual(sut.valueID, 12)
        XCTAssertEqual(sut.optionID, 123)
        XCTAssertTrue(sut.price.isEmpty)
        XCTAssertNotNil(sut.optionController)
        XCTAssertEqual(sut.optionsType, .checkbox)
        XCTAssertEqual(sut.quantity, 0)
        XCTAssertFalse(sut.isSelected)
        XCTAssertFalse(sut.showPrice)
        XCTAssertNil(sut.sizeExtraCosts)
    }
    
    func test_initSize() {
        let sut = makeSUT(size: initSize)
        
        XCTAssertEqual(sut.title, "AnySize")
        XCTAssertEqual(sut.valueID, 123)
        XCTAssertEqual(sut.optionID, 0)
        XCTAssertTrue(sut.price.isEmpty)
        XCTAssertNotNil(sut.optionController)
        XCTAssertEqual(sut.optionsType, .radio)
        XCTAssertEqual(sut.quantity, 0)
        XCTAssertFalse(sut.isSelected)
        XCTAssertFalse(sut.showPrice)
        XCTAssertNil(sut.sizeExtraCosts)
    }
    
    func test_givenOptionControllerWithInitDict_thenQuantityIs0() {
        let sut = makeSUT(optionValue: initValue, optionID: 123, optionType: .checkbox)
        
        let expectation = expectation(description: "setupQuantity")
        var cancellables = Set<AnyCancellable>()
        
        sut.$quantity
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(sut.quantity, 0)
    }
    
    func test_givenOptionControllerWithDict_whenAddKeyValue_thenQuantityIs1() {
        let sut = makeSUT(optionValue: initValue, optionID: 123, optionType: .checkbox)
        
        sut.optionController.selectedOptionAndValueIDs[123] = [12]
        
        let expectation = expectation(description: "setupQuantity")
        var cancellables = Set<AnyCancellable>()
        
        sut.$quantity
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(sut.quantity, 1)
    }
    
    func test_givenOptionControllerWithDict_whenAdd2IdenticalKeyValues_thenQuantityIs2() {
        let sut = makeSUT(optionValue: initValue, optionID: 123, optionType: .checkbox)
        
        sut.optionController.selectedOptionAndValueIDs[123] = [12, 43, 21, 12]
        
        let expectation = expectation(description: "setupQuantity")
        var cancellables = Set<AnyCancellable>()
        
        sut.$quantity
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(sut.quantity, 2)
    }
    
    func test_givenOptionControllerWithDict_whenAddNoMatchingValue_thenQuantityIs0() {
        let sut = makeSUT(optionValue: initValue, optionID: 123, optionType: .checkbox)
        
        sut.optionController.selectedOptionAndValueIDs[123] = [34, 43, 21, 45]
        
        let expectation = expectation(description: "setupQuantity")
        var cancellables = Set<AnyCancellable>()
        
        sut.$quantity
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(sut.quantity, 0)
    }
    
    func test_givenOptionControllerWithDict_whenAdd2IdenticalKeyValuesAndAddingThird_thenQuantityIs3() {
        let sut = makeSUT(optionValue: initValue, optionID: 123, optionType: .checkbox)
        
        sut.optionController.selectedOptionAndValueIDs[123] = [12, 43, 21, 12]
        
        sut.optionController.selectedOptionAndValueIDs[123]?.append(12)
        
        let expectation = expectation(description: "setupQuantity")
        var cancellables = Set<AnyCancellable>()
        
        sut.$quantity
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(sut.quantity, 3)
    }
    
    func test_givenOptionControllerWithDict_whenAdd2IdenticalKeyValuesAndRemoving1_thenQuantityIs1() {
        let sut = makeSUT(optionValue: initValue, optionID: 123, optionType: .checkbox)
        
        sut.optionController.selectedOptionAndValueIDs[123] = [12, 43, 21, 12]
        
        if let index = sut.optionController.selectedOptionAndValueIDs[123]?.firstIndex(of: 12) {
            sut.optionController.selectedOptionAndValueIDs[123]?.remove(at: index)
        }
        
        let expectation = expectation(description: "setupQuantity")
        var cancellables = Set<AnyCancellable>()
        
        sut.$quantity
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(sut.quantity, 1)
    }
    
    func test_givenOptionControllerWithDict_whenAddKeyValue_thenIsSelectedIsTrue() {
        let sut = makeSUT(optionValue: initValue, optionID: 123, optionType: .checkbox)
        
        sut.optionController.selectedOptionAndValueIDs[123] = [12]
        
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
        
        wait(for: [expectationQuantity, expectationIsSelected], timeout: 5)
        
        XCTAssertTrue(sut.isSelected)
        XCTAssertEqual(sut.quantity, 1)
    }
    
    func test_givenInit_whenAddValueTapped_thenQuantity1AndIsSelectedTrue() {
        let sut = makeSUT(optionValue: initValue, optionID: 123, optionType: .checkbox)
        
        sut.addValue(maxReached: .constant(false))
        
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
        
        wait(for: [expectationQuantity, expectationIsSelected], timeout: 5)
        
        XCTAssertTrue(sut.isSelected)
        XCTAssertEqual(sut.quantity, 1)
    }
    
    func test_givenInitWithValue_whenAddValueTapped_thenQuantity2AndIsSelectedTrue() {
        let sut = makeSUT(optionValue: initValue, optionID: 123, optionType: .stepper)
        
        sut.optionController.selectedOptionAndValueIDs[123] = [12]
        
        sut.addValue(maxReached: .constant(false))
        
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
        
        wait(for: [expectationQuantity, expectationIsSelected], timeout: 5)
        
        XCTAssertTrue(sut.isSelected)
        XCTAssertEqual(sut.quantity, 2)
    }
    
    func test_givenInitWithValueAndMaxReached_whenAddValueTapped_thenQuantity1AndIsSelectedTrue() {
        let sut = makeSUT(optionValue: initValue, optionID: 123, optionType: .stepper)
        
        sut.optionController.selectedOptionAndValueIDs[123] = [12]
        
        sut.addValue(maxReached: .constant(true))
        
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
        
        wait(for: [expectationQuantity, expectationIsSelected], timeout: 5)
        
        XCTAssertTrue(sut.isSelected)
        XCTAssertEqual(sut.quantity, 1)
    }
    
    func test_givenInitWith1Value_whenRemoveValueTapped_thenQuantity0AndIsSelectedFalse() {
        let sut = makeSUT(optionValue: initValue, optionID: 123, optionType: .checkbox)
        
        sut.optionController.selectedOptionAndValueIDs[123] = [12]
        
        sut.removeValue()
        
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
        
        wait(for: [expectationQuantity, expectationIsSelected], timeout: 5)
        
        XCTAssertFalse(sut.isSelected)
        XCTAssertEqual(sut.quantity, 0)
    }
    
    func test_givenInitWith3ValuesOfWhich2AreRelevant_whenRemoveValueTapped_thenQuantity1AndIsSelectedTrue() {
        let sut = makeSUT(optionValue: initValue, optionID: 123, optionType: .stepper)
        
        sut.optionController.selectedOptionAndValueIDs[123] = [12, 45, 12]
        
        sut.removeValue()
        
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
        
        wait(for: [expectationQuantity, expectationIsSelected], timeout: 5)
        
        XCTAssertTrue(sut.isSelected)
        XCTAssertEqual(sut.quantity, 1)
    }
    
    func test_givenInitWithNoValue_whenToggleValueTapped_thenQuantity1AndIsSelectedTrue() {
        let sut = makeSUT(optionValue: initValue, optionID: 123, optionType: .checkbox)
        
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
        
        wait(for: [expectationQuantity, expectationIsSelected], timeout: 5)
        
        XCTAssertTrue(sut.isSelected)
        XCTAssertEqual(sut.quantity, 1)
    }
    
    func test_givenInitWith1Value_whenToggleValueTapped_thenQuantity0AndIsSelectedFalse() {
        let sut = makeSUT(optionValue: initValue, optionID: 123, optionType: .checkbox)
        
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
        
        wait(for: [expectationQuantity, expectationIsSelected], timeout: 5)
        
        XCTAssertFalse(sut.isSelected)
        XCTAssertEqual(sut.quantity, 0)
    }
    
    func test_givenInitWithOtherValue_whenAddValueTapped_thenQuantity1AndCorrectValue() {
        let sut = makeSUT(optionValue: initValue, optionID: 123, optionType: .radio)
        
        sut.optionController.selectedOptionAndValueIDs[123] = [23]
        
        sut.addValue(maxReached: .constant(false))
        
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
        
        wait(for: [expectationQuantity, expectationIsSelected], timeout: 5)
        
        XCTAssertEqual(sut.quantity, 1)
        XCTAssertEqual(sut.optionController.selectedOptionAndValueIDs[123], [12])
    }
    
    func test_givenInitWithNoValueAndAsManyMoreOptionType_whenToggleValueTapped_thenQuantityIs0() {
        let sut = makeSUT(optionValue: initValue, optionID: 123, optionType: .manyMore)
        
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
        
        wait(for: [expectationQuantity, expectationIsSelected], timeout: 5)
        
        XCTAssertFalse(sut.isSelected)
        XCTAssertEqual(sut.quantity, 0)
    }
    
    func test_givenInitWithNoValueAndAsStepperOptionType_whenToggleValueTapped_thenQuantityIs1() {
        let sut = makeSUT(optionValue: initValue, optionID: 123, optionType: .stepper)
        
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
        
        wait(for: [expectationQuantity, expectationIsSelected], timeout: 5)
        
        XCTAssertTrue(sut.isSelected)
        XCTAssertEqual(sut.quantity, 1)
    }
    
    func test_givenInitWithOneValueAndAsStepperOptionType_whenToggleValueTapped_thenQuantityRemains1() {
        let sut = makeSUT(optionValue: initValue, optionID: 123, optionType: .stepper)
        
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
        
        wait(for: [expectationQuantity, expectationIsSelected], timeout: 5)
        
        XCTAssertTrue(sut.isSelected)
        XCTAssertEqual(sut.quantity, 1)
    }
    
    func test_givenInitWithOptionValueWithPrice_thenPriceMatchesCurrency() {
        let sut = makeSUT(optionValue: initValueWithPrice, optionID: 123, optionType: .radio)
        
        XCTAssertEqual(sut.price, " + £0.50")
    }
    
    func test_givenInitWithSizeValueWithPrice_thenPriceMatchesCurrency() {
        let sut = makeSUT(size: initSizeWithPrice)
        
        XCTAssertEqual(sut.price, " + £1.50")
    }
    
    func test_givenInitWithValueWithLargeSizePrice_thenPriceMatchesSizeExtraCost() {
        let sut = makeSUT(optionValue: initValueWithSizePrices, optionID: 123, optionType: .checkbox)
        
        sut.optionController.selectedOptionAndValueIDs[0] = [92]
        
        XCTAssertEqual(sut.price, " + £2.00")
    }
    
    func test_givenInitWithValueWithLargeSizePrice_whenChangeSize_thenPriceMatchesSizeExtraCost() {
        let sut = makeSUT(optionValue: initValueWithSizePrices, optionID: 123, optionType: .radio)
        
        sut.optionController.selectedOptionAndValueIDs[0] = [92]
        
        sut.optionController.selectedOptionAndValueIDs[0] = [91]
        
        XCTAssertEqual(sut.price, " + £1.50")
    }
    
    func test_givenInit_whenMaximumReachedIsTrueAndValueIsSelected_thenIsDisabledIsTrue() {
        let sut = makeSUT(optionValue: initValue, optionID: 123, optionType: .checkbox)
        
        sut.optionController.selectedOptionAndValueIDs[123] = [12]
        
        XCTAssertFalse(sut.isDisabled(.constant(true)))
    }
    
    func test_givenInit_whenMaximumReachedIsFalseAndValueIsSelected_thenIsDisabledIsFalse() {
        let sut = makeSUT(optionValue: initValue, optionID: 123, optionType: .checkbox)
        
        sut.optionController.selectedOptionAndValueIDs[123] = [12]
        
        XCTAssertFalse(sut.isDisabled(.constant(false)))
    }
    
    func test_givenInitWithRadioType_whenMaximumReachedIsTrueAndValueNotIsSelected_thenIsDisabledIsFalse() {
        let sut = makeSUT(optionValue: initValue, optionID: 123, optionType: .radio)
        
        sut.optionController.selectedOptionAndValueIDs[123] = [13]
        
        XCTAssertFalse(sut.isDisabled(.constant(true)))
    }
    
    func test_givenInitWithStepperType_whenMaximumReachedIsTrueAndValueIsSelected_thenIsDisabledIsTrue() {
        let sut = makeSUT(optionValue: initValue, optionID: 123, optionType: .stepper)
        
        sut.optionController.selectedOptionAndValueIDs[123] = [12, 12]
        
        XCTAssertTrue(sut.isDisabled(.constant(true)))
    }

    func makeSUT(optionValue: RetailStoreMenuItemOptionValue, optionID: Int, optionType: OptionValueType, optionController: OptionController = OptionController()) -> OptionValueCardViewModel {
        let sut = OptionValueCardViewModel(optionValue: optionValue, optionID: optionID, optionsType: optionType, optionController: OptionController())
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
    
    func makeSUT(size: RetailStoreMenuItemSize, optionController: OptionController = OptionController()) -> OptionValueCardViewModel {
        let sut = OptionValueCardViewModel(size: size, optionController: OptionController())
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
    
    let initValue = RetailStoreMenuItemOptionValue(id: 12, name: nil, extraCost: nil, default: nil, sizeExtraCost: nil)
    
    let initValueWithPrice = RetailStoreMenuItemOptionValue(id: 12, name: nil, extraCost: 0.5, default: nil, sizeExtraCost: nil)
    
    let initValueWithSizePrices = RetailStoreMenuItemOptionValue(id: 12, name: nil, extraCost: 0.5, default: nil, sizeExtraCost: [sizeS, sizeM, sizeL])
    
    private static let sizeS = RetailStoreMenuItemOptionValueSize(id: 45, sizeId: 90, extraCost: 1)
    private static let sizeM = RetailStoreMenuItemOptionValueSize(id: 46, sizeId: 91, extraCost: 1.5)
    private static let sizeL = RetailStoreMenuItemOptionValueSize(id: 47, sizeId: 92, extraCost: 2)
    
    let initSize = RetailStoreMenuItemSize(id: 123, name: "AnySize", price: nil)
    
    let initSizeWithPrice = RetailStoreMenuItemSize(id: 123, name: "AnySize", price: 1.5)

}
