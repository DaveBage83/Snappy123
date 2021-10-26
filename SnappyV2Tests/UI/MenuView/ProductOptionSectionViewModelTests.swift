//
//  ProductOptionSectionViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 10/08/2021.
//

import XCTest
import Combine
@testable import SnappyV2

class ProductOptionSectionViewModelTests: XCTestCase {

    func test_optionInit() {
        let sut = makeSUT(itemOption: itemOptionInit)
        
        XCTAssertEqual(sut.title, "OptionName")
        XCTAssertTrue(sut.optionValues.isEmpty)
        XCTAssertFalse(sut.useBottomSheet)
        XCTAssertFalse(sut.mutuallyExclusive)
        XCTAssertEqual(sut.minimumSelected, 0)
        XCTAssertEqual(sut.maximumSelected, 0)
        XCTAssertTrue(sut.sizeValues.isEmpty)
        XCTAssertTrue(sut.selectedOptionValues.isEmpty)
        XCTAssertEqual(sut.sectionType, .options)
        XCTAssertTrue(sut.optionLimitationsSubtitle.isEmpty)
        XCTAssertFalse(sut.maximumReached)
    }
    
    func test_bottomSheetInit() {
        let sut = makeSUT(itemOption: itemOptionBottomSheetInit)
        
        XCTAssertEqual(sut.title, "OptionName")
        XCTAssertTrue(sut.optionValues.isEmpty)
        XCTAssertFalse(sut.useBottomSheet)
        XCTAssertFalse(sut.mutuallyExclusive)
        XCTAssertEqual(sut.minimumSelected, 0)
        XCTAssertEqual(sut.maximumSelected, 0)
        XCTAssertTrue(sut.sizeValues.isEmpty)
        XCTAssertTrue(sut.selectedOptionValues.isEmpty)
        XCTAssertEqual(sut.sectionType, .bottomSheet)
        XCTAssertTrue(sut.optionLimitationsSubtitle.isEmpty)
        XCTAssertFalse(sut.maximumReached)
    }
    
    func test_sizesInit() {
        let sut = makeSizeSUT(itemSizes: itemSizes)
        
        XCTAssertEqual(sut.title, "Size")
        XCTAssertTrue(sut.optionValues.isEmpty)
        XCTAssertFalse(sut.useBottomSheet)
        XCTAssertEqual(sut.mutuallyExclusive, true)
        XCTAssertEqual(sut.minimumSelected, 1)
        XCTAssertEqual(sut.maximumSelected, 1)
        XCTAssertEqual(sut.sizeValues.count, 3)
        XCTAssertTrue(sut.selectedOptionValues.isEmpty)
        XCTAssertEqual(sut.sectionType, .sizes)
        XCTAssertTrue(sut.optionLimitationsSubtitle.isEmpty)
        XCTAssertFalse(sut.maximumReached)
    }
    
    func test_givenMaxIsMoreThanOneAndMutuallyExlusiveIsFalse_whenInit_thenOptionValueTypeIsStepper() {
        let sut = makeSUT(itemOption: itemOptionMax2)
        
        XCTAssertEqual(sut.optionsType, .stepper)
    }
    
    func test_givenMaxIsMoreThanOneAndMutuallyExlusiveIsTrue_whenInit_thenOptionValueTypeIsCheckbox() {
        let sut = makeSUT(itemOption: itemOptionMax2AndMutExclIsTrue)
        
        XCTAssertEqual(sut.optionsType, .checkbox)
    }
    
    func test_givenMaxIsOne_whenInit_thenOptionValueTypeIsRadio() {
        let sut = makeSUT(itemOption: itemOptionMax1)
        
        XCTAssertEqual(sut.optionsType, .radio)
    }
    
    func test_whenInitAndDisplayAsGridIsFalse_whenShowBottomSheetIsTriggered_thenBottomSheetValuesIsPopulated() {
        let sut = makeSUT(itemOption: itemOptionInit)
        
        XCTAssertNil(sut.bottomSheetValues)
        
        sut.showBottomSheet()
        
        XCTAssertNotNil(sut.bottomSheetValues)
    }
    
    func test_whenInitAndDisplayAsGridIsFalse_whenDismissBottomSheetIsTriggered_thenBottomSheetValuesIsNil() {
        let sut = makeSUT(itemOption: itemOptionInit)
        
        sut.bottomSheetValues = itemOptionInit
        
        sut.dismissBottomSheet()
        
        XCTAssertNil(sut.bottomSheetValues)
    }
    
    func test_givenOptionsTypeIsManyMore_whenSelectedValuesAre1_thenSelectedOptionsCorrectOne() {
        let sut = makeSUT(itemOption: itemOptionBottomSheetWith3Values)
        
        sut.optionController.selectedOptionAndValueIDs[123] = [234]
        
        let expectation = expectation(description: "setupSelectedOptions")
        var cancellables = Set<AnyCancellable>()
        
        sut.$selectedOptionValues
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(sut.optionsType, .manyMore)
        XCTAssertEqual(sut.selectedOptionValues.count, 1)
    }
    
    func test_givenOptionsTypeIsManyMore_whenSelectedValuesAre1Twice_thenSelectedOptionsCorrectOne() {
        let sut = makeSUT(itemOption: itemOptionBottomSheetWith3Values)
        
        sut.optionController.selectedOptionAndValueIDs[123] = [234, 234]
        
        let expectation = expectation(description: "setupSelectedOptions")
        var cancellables = Set<AnyCancellable>()
        
        sut.$selectedOptionValues
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(sut.optionsType, .manyMore)
        XCTAssertEqual(sut.selectedOptionValues.count, 1)
    }
    
    func test_givenOptionsTypeIsManyMoreAnd2IdenticalOptions_whenSelectedValuesAre1_thenSelectedOptionsCorrectOne() {
        let sut = makeSUT(itemOption: itemOptionBottomSheetWith2IdenticalValues)
        
        sut.optionController.selectedOptionAndValueIDs[123] = [234]
        
        let expectation = expectation(description: "setupSelectedOptions")
        var cancellables = Set<AnyCancellable>()
        
        sut.$selectedOptionValues
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(sut.optionsType, .manyMore)
        XCTAssertEqual(sut.selectedOptionValues.count, 1)
    }
    
    func test_givenInitWithMinMaxLimitations_thenCorrectSubtitleDisplayed() {
        let sut = makeSUT(itemOption: itemOptionMax2Min1)
        
        XCTAssertEqual(sut.optionLimitationsSubtitle, "Select 1 minimum. Choose up to 2.")
    }
    
    func test_givenInitWithMinLimitation_thenCorrectSubtitleDisplayed() {
        let sut = makeSUT(itemOption: itemOptionMin1)
        
        XCTAssertEqual(sut.optionLimitationsSubtitle, "Select 1 minimum. ")
    }
    
    func test_givenInitWithMaxLimitation_thenCorrectSubtitleDisplayed() {
        let sut = makeSUT(itemOption: itemOptionMax2)
        
        XCTAssertEqual(sut.optionLimitationsSubtitle, "Choose up to 2.")
    }
    
    func test_givenInitWithRadioType_thenCorrectSubtitleDisplayed() {
        let sut = makeSUT(itemOption: itemOptionMax1)
        
        XCTAssertEqual(sut.optionsType, .radio)
        XCTAssertEqual(sut.optionLimitationsSubtitle, "Select 1")
    }
    
    func test_givenInitWithMaxLimitation_whenAddingMaxOptions_thenMaximumReachedIsTrue() {
        let sut = makeSUT(itemOption: itemOptionMax2)
        
        sut.optionController.selectedOptionAndValueIDs[123] = [234, 234]
        
        let expectation = expectation(description: "setupMaximumReached")
        var cancellables = Set<AnyCancellable>()
        
        sut.$maximumReached
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertTrue(sut.maximumReached)
    }
    
    func test_givenInitWithMaxLimitation_whenAddingUnderMaxOptions_thenMaximumReachedIsFalse() {
        let sut = makeSUT(itemOption: itemOptionMax2)
        
        sut.optionController.selectedOptionAndValueIDs[123] = [234]
        
        let expectation = expectation(description: "setupMaximumReached")
        var cancellables = Set<AnyCancellable>()
        
        sut.$maximumReached
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertFalse(sut.maximumReached)
    }
    
    func makeSUT(itemOption: MenuItemOption) -> ProductOptionSectionViewModel {
        let sut = ProductOptionSectionViewModel(itemOption: itemOption, optionID: 123, optionController: OptionController())
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
    
    func makeSizeSUT(itemSizes: [MenuItemSize]) -> ProductOptionSectionViewModel {
        let sut = ProductOptionSectionViewModel(itemSizes: itemSizes, optionController: OptionController())
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
    
    let itemOptionInit = MenuItemOption(id: 123, name: "OptionName", placeholder: nil, maximumSelected: nil, displayAsGrid: nil, mutuallyExclusive: false, minimumSelected: nil, dependentOn: nil, values: [], type: "")
    
    let itemOptionBottomSheetInit = MenuItemOption(id: 123, name: "OptionName", placeholder: nil, maximumSelected: nil, displayAsGrid: false, mutuallyExclusive: false, minimumSelected: nil, dependentOn: nil, values: [], type: "")
    
    let itemOptionBottomSheetWith3Values = MenuItemOption(id: 123, name: "OptionName", placeholder: nil, maximumSelected: nil, displayAsGrid: false, mutuallyExclusive: false, minimumSelected: nil, dependentOn: nil, values: [MenuItemOptionValue(id: 234, name: nil, extraCost: nil, default: nil, sizeExtraCost: nil), MenuItemOptionValue(id: 435, name: nil, extraCost: nil, default: nil, sizeExtraCost: nil), MenuItemOptionValue(id: 456, name: nil, extraCost: nil, default: nil, sizeExtraCost: nil)], type: "")
    
    let itemOptionBottomSheetWith2IdenticalValues = MenuItemOption(id: 123, name: "OptionName", placeholder: nil, maximumSelected: nil, displayAsGrid: false, mutuallyExclusive: false, minimumSelected: nil, dependentOn: nil, values: [MenuItemOptionValue(id: 234, name: nil, extraCost: nil, default: nil, sizeExtraCost: nil), MenuItemOptionValue(id: 234, name: nil, extraCost: nil, default: nil, sizeExtraCost: nil), MenuItemOptionValue(id: 456, name: nil, extraCost: nil, default: nil, sizeExtraCost: nil)], type: "")
    
    let itemOptionMax2 = MenuItemOption(id: 123, name: "", placeholder: nil, maximumSelected: 2, displayAsGrid: nil, mutuallyExclusive: nil, minimumSelected: nil, dependentOn: nil, values: [MenuItemOptionValue(id: 234, name: nil, extraCost: nil, default: nil, sizeExtraCost: nil), MenuItemOptionValue(id: 435, name: nil, extraCost: nil, default: nil, sizeExtraCost: nil), MenuItemOptionValue(id: 456, name: nil, extraCost: nil, default: nil, sizeExtraCost: nil)], type: "")
    
    let itemOptionMax2Min1 = MenuItemOption(id: 123, name: "", placeholder: nil, maximumSelected: 2, displayAsGrid: nil, mutuallyExclusive: nil, minimumSelected: 1, dependentOn: nil, values: [MenuItemOptionValue(id: 234, name: nil, extraCost: nil, default: nil, sizeExtraCost: nil), MenuItemOptionValue(id: 435, name: nil, extraCost: nil, default: nil, sizeExtraCost: nil), MenuItemOptionValue(id: 456, name: nil, extraCost: nil, default: nil, sizeExtraCost: nil)], type: "")
    
    let itemOptionMin1 = MenuItemOption(id: 123, name: "", placeholder: nil, maximumSelected: nil, displayAsGrid: nil, mutuallyExclusive: nil, minimumSelected: 1, dependentOn: nil, values: [MenuItemOptionValue(id: 234, name: nil, extraCost: nil, default: nil, sizeExtraCost: nil), MenuItemOptionValue(id: 435, name: nil, extraCost: nil, default: nil, sizeExtraCost: nil), MenuItemOptionValue(id: 456, name: nil, extraCost: nil, default: nil, sizeExtraCost: nil)], type: "")
    
    let itemOptionMax2AndMutExclIsTrue = MenuItemOption(id: 123, name: "", placeholder: nil, maximumSelected: 2, displayAsGrid: nil, mutuallyExclusive: true, minimumSelected: nil, dependentOn: nil, values: [MenuItemOptionValue(id: 234, name: nil, extraCost: nil, default: nil, sizeExtraCost: nil), MenuItemOptionValue(id: 435, name: nil, extraCost: nil, default: nil, sizeExtraCost: nil), MenuItemOptionValue(id: 456, name: nil, extraCost: nil, default: nil, sizeExtraCost: nil)], type: "")
    
    let itemOptionMax1 = MenuItemOption(id: 123, name: "", placeholder: nil, maximumSelected: 1, displayAsGrid: nil, mutuallyExclusive: nil, minimumSelected: nil, dependentOn: nil, values: [MenuItemOptionValue(id: 234, name: nil, extraCost: nil, default: nil, sizeExtraCost: nil), MenuItemOptionValue(id: 435, name: nil, extraCost: nil, default: nil, sizeExtraCost: nil), MenuItemOptionValue(id: 456, name: nil, extraCost: nil, default: nil, sizeExtraCost: nil)], type: "")
    
    let itemOptionInitWithShowAsGridFalse = MenuItemOption(id: 123, name: "OptionName", placeholder: nil, maximumSelected: nil, displayAsGrid: false, mutuallyExclusive: false, minimumSelected: nil, dependentOn: nil, values: [], type: "")
    
    let itemSizes = [MenuItemSize(id: 123, name: "First", price: 0), MenuItemSize(id: 234, name: "Second", price: 0.5), MenuItemSize(id: 345, name: "Third", price: 1.0)]
}