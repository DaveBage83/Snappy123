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
    
    func test_init() {
        let sut = makeSUT(item: itemWith5OptionsOfWhich2Dependencies)
        
        XCTAssertFalse(sut.availableOptions.isEmpty)
        XCTAssertTrue(sut.optionController.selectedOptionAndValueIDs.isEmpty)
        XCTAssertNotNil(sut.item)
    }
    
    func test_givenInit_whenAvailableOptionsInitted_thenFilteredOptionsIsCorrect() {
        let sut = makeSUT(item: itemWith5OptionsOfWhich2Dependencies)
        
        let expectation = expectation(description: "setupFilteredOptions")
        var cancellables = Set<AnyCancellable>()
        
        sut.$filteredOptions
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(sut.filteredOptions.count, 3)
    }
    
    func test_givenInit_whenADependentValueIsSelected_thenFilteredOptionsIsCorrect() {
        let sut = makeSUT(item: itemWith5OptionsOfWhich2Dependencies)

        sut.optionController.selectedOptionAndValueIDs[994] = [222]

        let expectation = expectation(description: "setupFilteredOptions")
        var cancellables = Set<AnyCancellable>()

        sut.$filteredOptions
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5)

        XCTAssertEqual(sut.filteredOptions.count, 5)
        XCTAssertEqual(sut.filteredOptions[2].id, 355)
        XCTAssertEqual(sut.filteredOptions[3].id, 344)
    }

    func test_givenInit_whenADependentValueIsSelectedAndDeselected_thenFilteredOptionsIsCorrect() {
        let sut = makeSUT(item: itemWith5OptionsOfWhich2Dependencies)

        sut.optionController.selectedOptionAndValueIDs[994] = [222]

        if let index = sut.optionController.selectedOptionAndValueIDs[994]?.firstIndex(of: 222) {
            sut.optionController.selectedOptionAndValueIDs[994]?.remove(at: index)
        }

        let expectation = expectation(description: "setupFilteredOptions")
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

        let expectation = expectation(description: "setupFilteredOptions")
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

        let expectation = expectation(description: "setupFilteredOptions")
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
    
    func test_givenInitItemWithPrice_thenTotalPriceIsCorrect() {
        let sut = makeSUT(item: itemWithNoOptions)
        
        let expectation = expectation(description: "setupTotalPrice")
        var cancellables = Set<AnyCancellable>()
        
        sut.$totalPrice
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(sut.totalPrice, "£10.00")
    }
    
    func test_givenInitWithPriceAndOptionWithPrices_whenOptionSelected_thenTotalPriceIsCorrect() {
        let sut = makeSUT(item: itemWithOneOptionAndPrice)

        sut.optionController.selectedOptionAndValueIDs[377] = [324, 643, 324, 435]

        let expectation = expectation(description: "setupTotalPrice")
        var cancellables = Set<AnyCancellable>()
        
        sut.$totalPrice
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)

        XCTAssertEqual(sut.totalPrice, "£14.50")
    }
    
    func test_givenInitWithPriceAndSizesWithPrices_whenOptionSelected_thenTotalPriceIsCorrect() {
        let sut = makeSUT(item: itemWithSizesAndPrices)

        sut.optionController.selectedOptionAndValueIDs[0] = [124]

        let expectation = expectation(description: "setupTotalPrice")
        var cancellables = Set<AnyCancellable>()
        
        sut.$totalPrice
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)

        XCTAssertEqual(sut.totalPrice, "£11.50")
    }
    
    func test_givenInitWithPriceAndSizesWithPricesAndOptionsWithExtraSizePrice_whenOptionSelected_thenTotalPriceIsCorrect() {
        let sut = makeSUT(item: itemWithSizesAndOptionsAndPrices)

        sut.optionController.selectedOptionAndValueIDs[0] = [142] // Add size L
        
        sut.optionController.selectedOptionAndValueIDs[377] = [984] // Add falafel topping

        let expectation = expectation(description: "setupTotalPrice")
        var cancellables = Set<AnyCancellable>()
        
        sut.$totalPrice
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)

        XCTAssertEqual(sut.totalPrice, "£15.00")
    }
    
    func test_givenInitAndExistingSelections_whenDependencyDeselected_thenActualSelectedOptionsAndValueIDsIsCorrect() {
        let sut = makeSUT(item: itemWith5OptionsOfWhich2Dependencies)
        
        sut.optionController.selectedOptionAndValueIDs[377] = [435] // non-dependency related choice
        sut.optionController.selectedOptionAndValueIDs[994] = [] // dependency unselected
        sut.optionController.selectedOptionAndValueIDs[355] = [555] // dependency related choice
        sut.optionController.selectedOptionAndValueIDs[344] = [888] // dependency related choice
        
        let expectation = expectation(description: "setupActualSelectedOptionsAndValueIDs")
        var cancellables = Set<AnyCancellable>()
        
        sut.optionController.$actualSelectedOptionsAndValueIDs
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        print("Output: \(sut.optionController.actualSelectedOptionsAndValueIDs)")
        
        XCTAssertEqual(sut.optionController.selectedOptionAndValueIDs.count, 4)
        XCTAssertEqual(sut.optionController.actualSelectedOptionsAndValueIDs.count, 1)
    }
    
    func test_makeProductOptionSectionViewModelWithOption() {
        let sut = makeSUT(item: itemWithNoOptions)
        
        let result = sut.makeProductOptionSectionViewModel(itemOption: ProductOptionsViewModelTests.toppings)
        
        XCTAssertEqual(result.optionID, 377)
        XCTAssertEqual(result.optionValues.count, 9)
    }
    
    func test_makeProductOptionSectionViewModelWithSize() {
        let sut = makeSUT(item: itemWithNoOptions)
        
        let result = sut.makeProductOptionSectionViewModel(itemSizes: [ProductOptionsViewModelTests.sizeS, ProductOptionsViewModelTests.sizeM, ProductOptionsViewModelTests.sizeL])
        
        XCTAssertEqual(result.sizeValues.count, 3)
        XCTAssertEqual(result.sizeValues[0].id, 123)
    }
    
    func test_makeOptionValueCardViewModelWithOption() {
        let sut = makeSUT(item: itemWithNoOptions)
        
        let result = sut.makeOptionValueCardViewModel(optionValue: ProductOptionsViewModelTests.topping1, optionID: 123, optionsType: .checkbox)
        
        XCTAssertEqual(result.optionsType, .checkbox)
        XCTAssertEqual(result.valueID, 435)
    }
    
    func test_makeOptionValueCardViewModelWithSize() {
        let sut = makeSUT(item: itemWithNoOptions)
        
        let result = sut.makeOptionValueCardViewModel(size: ProductOptionsViewModelTests.sizeS)
        
        XCTAssertEqual(result.optionsType, .radio)
        XCTAssertEqual(result.valueID, 123)
    }
    
    func makeSUT(item: MenuItem) -> ProductOptionsViewModel {
        let sut = ProductOptionsViewModel(item: item)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
    
    let itemWithNoOptions = MenuItem(name: "ItemName", price: itemPrice, description: nil, sizes: nil, options: nil)
    let itemWithTwoIdenticalOptions = MenuItem(name: "ItemName", price: itemPrice, description: nil, sizes: nil, options: [MenuItemOption(id: 123, name: "OptionName", placeholder: nil, maximumSelected: nil, displayAsGrid: nil, mutuallyExclusive: false, minimumSelected: nil, dependentOn: nil, values: [MenuItemOptionValue(id: 123, name: nil, extraCost: nil, default: nil, sizeExtraCost: nil)], type: "Type"), MenuItemOption(id: 123, name: "OptionName", placeholder: nil, maximumSelected: nil, displayAsGrid: nil, mutuallyExclusive: false, minimumSelected: nil, dependentOn: nil, values: [MenuItemOptionValue(id: 123, name: nil, extraCost: nil, default: nil, sizeExtraCost: nil)], type: "Type")])
    
    let itemWith5OptionsOfWhich2Dependencies = MenuItem(name: "Fresh Pizzas", price: itemPrice, description: "Choose your own pizza from as little as £5.00 and a drink", sizes: nil, options: [bases, makeAMeal, drinks, sides, toppings])
    
    let itemWithOneOptionAndPrice = MenuItem(name: "ItemName", price: itemPrice, description: nil, sizes: nil, options: [toppings])
    
    let itemWithSizesAndPrices = MenuItem(name: "ItemName", price: itemPrice, description: nil, sizes: [sizeS, sizeM, sizeL], options: [])
    
    let itemWithSizesAndOptionsAndPrices = MenuItem(name: "ItemName", price: itemPrice, description: nil, sizes: [sizeS, sizeM, sizeL], options: [toppings])
    
    static let itemPrice = Price(price: 10, fromPrice: nil, wasPrice: nil, unitMetric: nil, unitsInPack: nil, unitVolume: nil)
    
    static let toppings = MenuItemOption(id: 377, name: "Toppings", maximumSelected: 8, mutuallyExclusive: false, minimumSelected: 2, values: [topping1, topping2, topping3, topping4, topping5, topping6, topping7, topping8, topping9], type: "")
    static let bases = MenuItemOption(id: 366, name: "Base", maximumSelected: 1, mutuallyExclusive: true, minimumSelected: 1, values: [base1, base2, base3], type: "")
    static let makeAMeal = MenuItemOption(id: 994, name: "Make a meal out of it", placeholder: "Choose", maximumSelected: 1, displayAsGrid: false, mutuallyExclusive: false, minimumSelected: 1, dependentOn: nil, values: [mealYes, mealNo], type: "")
    static let drinks = MenuItemOption(id: 355, name: "Drinks", maximumSelected: nil, mutuallyExclusive: false, minimumSelected: 0, dependentOn: [222], values: [drink1, drink2, drink3], type: "")
    static let sides = MenuItemOption(id: 344, name: "Side", maximumSelected: 0, mutuallyExclusive: false, minimumSelected: 0, dependentOn: [222], values: [side1, side2, side3], type: "")
    
    static let sizeS = MenuItemSize(id: 123, name: "Small - 9", price: 0)
    static let sizeM = MenuItemSize(id: 124, name: "Medium - 11", price: 1.5)
    static let sizeL = MenuItemSize(id: 142, name: "Large - 13", price: 3)
    
    static let topping1 = MenuItemOptionValue(id: 435, name: "Mushrooms", extraCost: nil, default: nil, sizeExtraCost: nil)
    static let topping2 = MenuItemOptionValue(id: 324, name: "Peppers", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    static let topping3 = MenuItemOptionValue(id: 643, name: "Goats Cheese", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    static let topping4 = MenuItemOptionValue(id: 153, name: "Red Onions", extraCost: nil, default: nil, sizeExtraCost: nil)
    static let topping5 = MenuItemOptionValue(id: 984, name: "Falafel", extraCost: 1, default: nil, sizeExtraCost: [falafelSizeS, falafelSizeM, falafelSizeL])
    static let topping6 = MenuItemOptionValue(id: 904, name: "Beef Strips", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    static let topping7 = MenuItemOptionValue(id: 783, name: "Bacon", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    static let topping8 = MenuItemOptionValue(id: 376, name: "Pepperoni", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    static let topping9 = MenuItemOptionValue(id: 409, name: "Sweetcorn", extraCost: 1.5, default: nil, sizeExtraCost: nil)
    
    static let falafelSizeS = MenuItemOptionValueSize(id: 678, sizeId: 123, extraCost: 1)
    static let falafelSizeM = MenuItemOptionValueSize(id: 679, sizeId: 124, extraCost: 1.5)
    static let falafelSizeL = MenuItemOptionValueSize(id: 680, sizeId: 142, extraCost: 2)
    
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


