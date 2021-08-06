//
//  ProductOptionsViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 03/08/2021.
//

import XCTest
import Combine
@testable import SnappyV2

class ProductOptionsViewModelTests: XCTestCase {
    
    func test_givenTapOptionTapped_thenCorrectSelectedOptionsIDAppended() {
        let sut = makeSUT()
        
        sut.tapOption(optionID: 123)
        
        XCTAssertTrue(sut.selectedOptionValueIDs.contains(123))
        XCTAssertEqual(sut.selectedOptionValueIDs.count, 1)
    }
    
    func test_givenTapOptionTapped_whenTappedAgain_thenSelectedOptionsValueIDsEmpty() {
        let sut = makeSUT()
        
        sut.tapOption(optionID: 123)
        
        sut.tapOption(optionID: 123)
        
        XCTAssertTrue(sut.selectedOptionValueIDs.isEmpty)
    }
    
    func test_givenExistingValueInSelectedOptionsValueIDs_whenTapOptionTriggeredTwice_thenSelectedOptionsValueIDsOriginalValueRemains() {
        let sut = makeSUT()
        
        sut.selectedOptionValueIDs.insert(321)
        
        sut.tapOption(optionID: 123)
        
        XCTAssertTrue(sut.selectedOptionValueIDs.contains(321))
        XCTAssertTrue(sut.selectedOptionValueIDs.contains(123))
        
        sut.tapOption(optionID: 123)
        
        XCTAssertTrue(sut.selectedOptionValueIDs.contains(321))
        XCTAssertEqual(sut.selectedOptionValueIDs.count, 1)
    }

    func test_givenInit_thenAvailableOptionsPopulated() {
        let sut = makeSUT()
        
        XCTAssertFalse(sut.availableOptions.isEmpty)
    }
    
    func test_givenInit_thenSelectedOptionValueIDsIsEmpty() {
        let sut = makeSUT()
        
        XCTAssertTrue(sut.selectedOptionValueIDs.isEmpty)
    }
    
    func test_givenInit_whenAvailableOptionsInitted_thenFilteredOptionsIsCorrect() {
        let sut = makeSUT()
        
        let expectation = expectation(description: "filterAvailableOptions")
        var cancellables = Set<AnyCancellable>()
        
        sut.$filteredOptions
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 10)
        
        XCTAssertEqual(sut.filteredOptions.count, 3)
    }
    
    func test_givenInit_whenADependentValueIsSelected_thenFilteredOptionsIsCorrect() {
        let sut = makeSUT()
        
        sut.tapOption(optionID: 222)
        
        let expectation = expectation(description: "filterAvailableOptions")
        var cancellables = Set<AnyCancellable>()
        
        sut.$filteredOptions
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(sut.filteredOptions.count, 5)
    }
    
    func test_givenInit_whenADependentValueIsSelectedAndDeselected_thenFilteredOptionsIsCorrect() {
        let sut = makeSUT()
        
        sut.tapOption(optionID: 222)
        
        sut.tapOption(optionID: 222)
        
        let expectation = expectation(description: "filterAvailableOptions")
        var cancellables = Set<AnyCancellable>()
        
        sut.$filteredOptions
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(sut.filteredOptions.count, 3)
    }
    
    func test_givenInitWithItemWithNoOptions_thenFilteredOptionsIsEmpty() {
        let sut = makeSUT(item: itemWithNoOptions)
        
        let expectation = expectation(description: "filterAvailableOptions")
        var cancellables = Set<AnyCancellable>()
        
        sut.$filteredOptions
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertTrue(sut.filteredOptions.isEmpty)
    }
    
    func test_givenInitWithItemWithTwoIdenticalOptionIDs_thenFilteredOptionsOnlyContainsOne() {
        let sut = makeSUT(item: itemWithTwoIdenticalOptions)
        
        let expectation = expectation(description: "filterAvailableOptions")
        var cancellables = Set<AnyCancellable>()
        
        sut.$filteredOptions
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertFalse(sut.filteredOptions.isEmpty)
        XCTAssertEqual(sut.filteredOptions.count, 1)
        XCTAssertEqual(sut.filteredOptions.first?.id, 123)
    }
    
    func makeSUT(item: MenuItem = MockData.item) -> ProductOptionsViewModel {
        let sut = ProductOptionsViewModel(item: item)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
    
    let itemWithNoOptions = MenuItem(name: "ItemName", description: nil, sizes: nil, options: nil)
    let itemWithTwoIdenticalOptions = MenuItem(name: "ItemName", description: nil, sizes: nil, options: [MenuItemOption(id: 123, name: "OptionName", placeholder: nil, maxiumSelected: nil, displayAsGrid: nil, mutuallyExlusive: false, minimumSelected: nil, dependentOn: nil, values: [MenuItemOptionValue(id: 123, name: nil, extraCost: nil, default: nil, sizeExtraCost: nil)], type: "Type"), MenuItemOption(id: 123, name: "OptionName", placeholder: nil, maxiumSelected: nil, displayAsGrid: nil, mutuallyExlusive: false, minimumSelected: nil, dependentOn: nil, values: [MenuItemOptionValue(id: 123, name: nil, extraCost: nil, default: nil, sizeExtraCost: nil)], type: "Type")])
}


