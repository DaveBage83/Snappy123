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
    
    func test_givenInit_whenSelectedValueExistsAndSelectedValueIsDeselected_thenFilteredOptionsIsCorrect() {
        let sut = makeSUT()
        
        sut.selectedOptionValueIDs.insert(222)
        
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
    
    let itemWith5OptionsOfWhich2Dependencies = MenuItem(name: "Fresh Pizzas", description: "Choose your own pizza from as little as £5.00 and a drink", sizes: nil, options: [toppings, bases, makeAMeal, drinks, sides])
    
    static let toppings = MenuItemOption(id: 377, name: "Toppings", maxiumSelected: 8, mutuallyExlusive: false, minimumSelected: 2, values: [topping1, topping2, topping3, topping4, topping5, topping6, topping7, topping8, topping9], type: "")
    static let bases = MenuItemOption(id: 366, name: "Base", maxiumSelected: 1, mutuallyExlusive: true, minimumSelected: 1, values: [base1, base2, base3], type: "")
    static let makeAMeal = MenuItemOption(id: 994, name: "Make a meal out of it", placeholder: "Choose", maxiumSelected: 1, displayAsGrid: false, mutuallyExlusive: false, minimumSelected: 1, dependentOn: nil, values: [mealYes, mealNo], type: "")
    static let drinks = MenuItemOption(id: 355, name: "Drinks", maxiumSelected: nil, mutuallyExlusive: false, minimumSelected: 0, dependentOn: [222], values: [drink1, drink2, drink3], type: "")
    static let sides = MenuItemOption(id: 344, name: "Side", maxiumSelected: 0, mutuallyExlusive: false, minimumSelected: 0, dependentOn: [222], values: [side1, side2, side3], type: "")
    
    static let sizeS = MenuItemSize(id: 123, name: "Small - 9", price: 0)
    static let sizeM = MenuItemSize(id: 124, name: "Medium - 11", price: 1.5)
    static let sizeL = MenuItemSize(id: 142, name: "Large - 13", price: 3)
    
    static let topping1 = MenuItemOptionValue(id: 435, name: "Mushrooms", extraCost: nil, default: nil, sizeExtraCost: nil)
    static let topping2 = MenuItemOptionValue(id: 324, name: "Peppers", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    static let topping3 = MenuItemOptionValue(id: 643, name: "Goats Cheese", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    static let topping4 = MenuItemOptionValue(id: 153, name: "Red Onions", extraCost: nil, default: nil, sizeExtraCost: nil)
    static let topping5 = MenuItemOptionValue(id: 984, name: "Falafel", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    static let topping6 = MenuItemOptionValue(id: 904, name: "Beef Strips", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    static let topping7 = MenuItemOptionValue(id: 783, name: "Bacon", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    static let topping8 = MenuItemOptionValue(id: 376, name: "Pepperoni", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    static let topping9 = MenuItemOptionValue(id: 409, name: "Sweetcorn", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    
    static let base1 = MenuItemOptionValue(id: 234, name: "Classic", extraCost: nil, default: nil, sizeExtraCost: nil)
    static let base2 = MenuItemOptionValue(id: 759, name: "Stuffed crust", extraCost: nil, default: nil, sizeExtraCost: nil)
    static let base3 = MenuItemOptionValue(id: 333, name: "Italian style", extraCost: nil, default: nil, sizeExtraCost: nil)
    
    static let mealYes = MenuItemOptionValue(id: 222, name: "Yes", extraCost: 0, default: nil, sizeExtraCost: nil)
    static let mealNo = MenuItemOptionValue(id: 111, name: "No", extraCost: 0, default: nil, sizeExtraCost: nil)
    
    static let drink1 = MenuItemOptionValue(id: 555, name: "Coca Cola", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    static let drink2 = MenuItemOptionValue(id: 666, name: "Fanta", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    static let drink3 = MenuItemOptionValue(id: 777, name: "Coke Zero", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    
    static let side1 = MenuItemOptionValue(id: 888, name: "Chicken Wings", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    static let side2 = MenuItemOptionValue(id: 999, name: "Wedges", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    static let side3 = MenuItemOptionValue(id: 327, name: "Cookies", extraCost: 1.5, default: nil, sizeExtraCost: nil)
}


