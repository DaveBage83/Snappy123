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
            .first()
            .receive(on: RunLoop.main)
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
            .first()
            .receive(on: RunLoop.main)
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
            .first()
            .receive(on: RunLoop.main)
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
            .first()
            .receive(on: RunLoop.main)
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
            .first()
            .receive(on: RunLoop.main)
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
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(sut.totalPrice, "£10.00")
    }
    
    func test_givenInitWithPriceAndOptionWithPrices_whenOptionSelected_thenTotalPriceIsCorrect() {
        let sut = makeSUT(item: itemWithOneOptionAndPrice)

        let expectationTotalPrice = expectation(description: "setupTotalPrice")
        let expectationFilteredOptions = expectation(description: "setupFilteredOptions")
        var cancellables = Set<AnyCancellable>()
        
        sut.$filteredOptions
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectationFilteredOptions.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectationFilteredOptions], timeout: 5)
        
        sut.optionController.selectedOptionAndValueIDs[377] = [324, 643, 324, 435]
        
        sut.$totalPrice
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectationTotalPrice.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectationTotalPrice], timeout: 5)

        XCTAssertEqual(sut.totalPrice, "£14.50")
    }
    
    func test_givenInitWithPriceAndSizesWithPrices_whenSizeSelected_thenTotalPriceIsCorrect() {
        let sut = makeSUT(item: itemWithSizesAndPrices)
        
        let expectationTotalPrice = expectation(description: "setupTotalPrice")
        let expectationFilteredOptions = expectation(description: "setupFilteredOptions")
        var cancellables = Set<AnyCancellable>()
        
        sut.$filteredOptions
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectationFilteredOptions.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectationFilteredOptions], timeout: 5)
        
        sut.optionController.selectedSizeID = 124
        
        sut.$totalPrice
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectationTotalPrice.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectationTotalPrice], timeout: 5)

        XCTAssertEqual(sut.totalPrice, "£11.50")
    }
    
    func test_givenInitWithPriceAndSizesWithPricesAndOptionsWithExtraSizePrice_whenOptionSelected_thenTotalPriceIsCorrect() {
        let sut = makeSUT(item: itemWithSizesAndOptionsAndPrices)

        let expectationTotalPrice = expectation(description: "setupTotalPrice")
        let expectationFilteredOptions = expectation(description: "setupFilteredOptions")
        var cancellables = Set<AnyCancellable>()
        
        sut.$filteredOptions
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectationFilteredOptions.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectationFilteredOptions], timeout: 5)
        
        sut.optionController.selectedSizeID = 142 // Add size L
        
        sut.optionController.selectedOptionAndValueIDs[377] = [984] // Add falafel topping
        
        sut.$totalPrice
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectationTotalPrice.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectationTotalPrice], timeout: 5)
        
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
            .first()
            .receive(on: RunLoop.main)
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
        XCTAssertEqual(result.optionValueID, 435)
    }
    
    func test_makeOptionValueCardViewModelWithSize() {
        let sut = makeSUT(item: itemWithNoOptions)
        
        let result = sut.makeOptionValueCardViewModel(size: ProductOptionsViewModelTests.sizeS)
        
        XCTAssertEqual(result.optionsType, .radio)
        XCTAssertEqual(result.sizeID, 123)
    }
    
    func test_givenItemWithOptions_whenAddItemToBasketTapped_thenAddItemServiceIsTriggeredAndIsCorrect() {
        let size = RetailStoreMenuItemSize(id: 12, name: "", price: MenuItemSizePrice(price: 1.0))
        let option = RetailStoreMenuItemOption(id: 123, name: "", type: .item, placeholder: "", instances: 1, displayAsGrid: false, mutuallyExclusive: false, minimumSelected: 0, extraCostThreshold: 0, dependencies: nil, values: [RetailStoreMenuItemOptionValue(id: 321, name: "", extraCost: 0, defaultSelection: 0, sizeExtraCost: nil)])
        let price = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let menuItem = RetailStoreMenuItem(id: 123, name: "", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "", quickAdd: true, price: price, images: nil, menuItemSizes: [size], menuItemOptions: [option])
        
        let container = DIContainer(appState: AppState(), services: .mocked(basketService: [.addItem(item: BasketItemRequest(menuItemId: 123, quantity: 1, sizeId: 12, bannerAdvertId: 0, options: [BasketItemRequestOption(id: 123, values: [321], type: .item)]))]))
        let sut = makeSUT(container: container, item: menuItem)
        sut.optionController.selectedSizeID = 12
        sut.optionController.actualSelectedOptionsAndValueIDs[123] = [321]
        
        let expectation = expectation(description: "setupItemQuantityChange")
        var cancellables = Set<AnyCancellable>()
        
        sut.$isAddingToBasket
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.addItemToBasket()
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertFalse(sut.isAddingToBasket)
        
        container.services.verify()
    }
    
    func test_givenOptionsWithDefaultValueAndNoRestrictions_thenDefaultValueArePreselected() {
        let sut = makeSUT(item: itemWithTwoIdenticalOptionsAndOneDefault)
        
        XCTAssertEqual(sut.optionController.actualSelectedOptionsAndValueIDs, [123:[345]])
    }
    
    func test_givenOptionsWithTwoOfSameDefaultValueAndNoRestrictions_thenTwoDefaultValuesArePreselected() {
        let sut = makeSUT(item: itemWithTwoIdenticalOptionsAndTwoOfSameDefault)
        
        XCTAssertEqual(sut.optionController.actualSelectedOptionsAndValueIDs, [123:[345, 345]])
    }
    
    func test_givenOptionsWithFourOfSameDefaultValueAndTwoInstances_thenTwoDefaultValuesArePreselected() {
        let sut = makeSUT(item: itemWithTwoIdenticalOptionsAndFourOfSameDefaultWith2Instances)
        
        XCTAssertEqual(sut.optionController.actualSelectedOptionsAndValueIDs, [123:[345, 345]])
    }
    
    func test_givenOptionsWithFourOfSameDefaultValueAndMutuallyExclusive_thenOneDefaultValueIsPreselected() {
        let sut = makeSUT(item: itemWithTwoIdenticalOptionsAndFourOfSameDefaultWithMutallyExclusive)
        
        XCTAssertEqual(sut.optionController.actualSelectedOptionsAndValueIDs, [123:[345]])
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), services: .mocked()), item: RetailStoreMenuItem) -> ProductOptionsViewModel {
        let sut = ProductOptionsViewModel(container: container, item: item)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
    
    let itemWithNoOptions = RetailStoreMenuItem(id: 123, name: "ItemName", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: false, price: itemPrice, images: nil, menuItemSizes: nil, menuItemOptions: nil)
    
    let itemWithTwoIdenticalOptions = RetailStoreMenuItem(id: 123, name: "ItemName", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: false, price: itemPrice, images: nil, menuItemSizes: nil, menuItemOptions: [RetailStoreMenuItemOption(id: 123, name: "OptionName", type: .item, placeholder: "", instances: 0, displayAsGrid: false, mutuallyExclusive: false, minimumSelected: 0, extraCostThreshold: 0, dependencies: nil, values: [RetailStoreMenuItemOptionValue(id: 123, name: "", extraCost: 0, defaultSelection: 0, sizeExtraCost: nil)]), RetailStoreMenuItemOption(id: 123, name: "OptionName", type: .item, placeholder: "", instances: 0, displayAsGrid: false, mutuallyExclusive: false, minimumSelected: 0, extraCostThreshold: 0, dependencies: nil, values: [RetailStoreMenuItemOptionValue(id: 123, name: "", extraCost: 0, defaultSelection: 0, sizeExtraCost: nil)])])
    
    let itemWith5OptionsOfWhich2Dependencies = RetailStoreMenuItem(id: 123, name: "Fresh Pizzas", eposCode: nil, outOfStock: false, ageRestriction: 0, description: "Choose your own pizza from as little as £5.00 and a drink", quickAdd: false, price: itemPrice, images: nil, menuItemSizes: nil, menuItemOptions: [bases, makeAMeal, drinks, sides, toppings])
    
    let itemWithOneOptionAndPrice = RetailStoreMenuItem(id: 123, name: "ItemName", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: false, price: itemPrice, images: nil, menuItemSizes: nil, menuItemOptions: [toppings])
    
    let itemWithSizesAndPrices = RetailStoreMenuItem(id: 123, name: "ItemName", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: false, price: itemPrice, images: nil, menuItemSizes: [sizeS, sizeM, sizeL], menuItemOptions: [])
    
    let itemWithSizesAndOptionsAndPrices = RetailStoreMenuItem(id: 123, name: "ItemName", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: false, price: itemPrice, images: nil, menuItemSizes: [sizeS, sizeM, sizeL], menuItemOptions: [toppings])
    
    static let itemPrice = RetailStoreMenuItemPrice(price: 10, fromPrice: 0, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
    
    static let toppings = RetailStoreMenuItemOption(id: 377, name: "Toppings", type: .item, placeholder: "", instances: 8, displayAsGrid: false, mutuallyExclusive: false, minimumSelected: 2, extraCostThreshold: 0, dependencies: nil, values: [topping1, topping2, topping3, topping4, topping5, topping6, topping7, topping8, topping9])
    static let bases = RetailStoreMenuItemOption(id: 366, name: "Base", type: .item, placeholder: "", instances: 1, displayAsGrid: false, mutuallyExclusive: true, minimumSelected: 1, extraCostThreshold: 0, dependencies: nil, values: [base1, base2, base3])
    static let makeAMeal = RetailStoreMenuItemOption(id: 994, name: "Make a meal out of it", type: .item, placeholder: "Choose", instances: 1, displayAsGrid: false, mutuallyExclusive: false, minimumSelected: 1, extraCostThreshold: 0, dependencies: nil, values: [mealYes, mealNo])
    static let drinks = RetailStoreMenuItemOption(id: 355, name: "Drinks", type: .item, placeholder: "", instances: 0, displayAsGrid: false, mutuallyExclusive: false, minimumSelected: 0, extraCostThreshold: 0, dependencies: [222], values: [drink1, drink2, drink3])
    static let sides = RetailStoreMenuItemOption(id: 344, name: "Side", type: .item, placeholder: "", instances: 0, displayAsGrid: false, mutuallyExclusive: false, minimumSelected: 0, extraCostThreshold: 0, dependencies: [222], values: [side1, side2, side3])
    
    static let sizeS = RetailStoreMenuItemSize(id: 123, name: "Small - 9", price: MenuItemSizePrice(price: 0))
    static let sizeM = RetailStoreMenuItemSize(id: 124, name: "Medium - 11", price: MenuItemSizePrice(price: 1.5))
    static let sizeL = RetailStoreMenuItemSize(id: 142, name: "Large - 13", price: MenuItemSizePrice(price: 3))
    
    static let topping1 = RetailStoreMenuItemOptionValue(id: 435, name: "Mushrooms", extraCost: 0, defaultSelection: 0, sizeExtraCost: nil)
    static let topping2 = RetailStoreMenuItemOptionValue(id: 324, name: "Peppers", extraCost: 1.5, defaultSelection: 0, sizeExtraCost: nil)
    static let topping3 = RetailStoreMenuItemOptionValue(id: 643, name: "Goats Cheese", extraCost: 1.5, defaultSelection: 0, sizeExtraCost: nil)
    static let topping4 = RetailStoreMenuItemOptionValue(id: 153, name: "Red Onions", extraCost: 0, defaultSelection: 0, sizeExtraCost: nil)
    static let topping5 = RetailStoreMenuItemOptionValue(id: 984, name: "Falafel", extraCost: 1, defaultSelection: 0, sizeExtraCost: [falafelSizeS, falafelSizeM, falafelSizeL])
    static let topping6 = RetailStoreMenuItemOptionValue(id: 904, name: "Beef Strips", extraCost: 1.5, defaultSelection: 0, sizeExtraCost: nil)
    static let topping7 = RetailStoreMenuItemOptionValue(id: 783, name: "Bacon", extraCost: 1.5, defaultSelection: 0, sizeExtraCost: nil)
    static let topping8 = RetailStoreMenuItemOptionValue(id: 376, name: "Pepperoni", extraCost: 1.5, defaultSelection: 0, sizeExtraCost: nil)
    static let topping9 = RetailStoreMenuItemOptionValue(id: 409, name: "Sweetcorn", extraCost: 1.5, defaultSelection: 0, sizeExtraCost: nil)
    
    static let falafelSizeS = RetailStoreMenuItemOptionValueSizeCost(id: 678, sizeId: 123, extraCost: 1)
    static let falafelSizeM = RetailStoreMenuItemOptionValueSizeCost(id: 679, sizeId: 124, extraCost: 1.5)
    static let falafelSizeL = RetailStoreMenuItemOptionValueSizeCost(id: 680, sizeId: 142, extraCost: 2)
    
    static let base1 = RetailStoreMenuItemOptionValue(id: 234, name: "Classic", extraCost: 0, defaultSelection: 0, sizeExtraCost: nil)
    static let base2 = RetailStoreMenuItemOptionValue(id: 759, name: "Stuffed crust", extraCost: 0, defaultSelection: 0, sizeExtraCost: nil)
    static let base3 = RetailStoreMenuItemOptionValue(id: 333, name: "Italian style", extraCost: 0, defaultSelection: 0, sizeExtraCost: nil)
    
    static let mealYes = RetailStoreMenuItemOptionValue(id: 222, name: "Yes", extraCost: 0, defaultSelection: 0, sizeExtraCost: nil)
    static let mealNo = RetailStoreMenuItemOptionValue(id: 111, name: "No", extraCost: 0, defaultSelection: 0, sizeExtraCost: nil)
    
    static let drink1 = RetailStoreMenuItemOptionValue(id: 555, name: "Coca Cola", extraCost: 1.5, defaultSelection: 0, sizeExtraCost: nil)
    static let drink2 = RetailStoreMenuItemOptionValue(id: 666, name: "Fanta", extraCost: 1.5, defaultSelection: 0, sizeExtraCost: nil)
    static let drink3 = RetailStoreMenuItemOptionValue(id: 777, name: "Coke Zero", extraCost: 1.5, defaultSelection: 0, sizeExtraCost: nil)
    
    static let side1 = RetailStoreMenuItemOptionValue(id: 888, name: "Chicken Wings", extraCost: 1.5, defaultSelection: 0, sizeExtraCost: nil)
    static let side2 = RetailStoreMenuItemOptionValue(id: 999, name: "Wedges", extraCost: 1.5, defaultSelection: 0, sizeExtraCost: nil)
    static let side3 = RetailStoreMenuItemOptionValue(id: 327, name: "Cookies", extraCost: 1.5, defaultSelection: 0, sizeExtraCost: nil)
    
    let itemWithTwoIdenticalOptionsAndOneDefault = RetailStoreMenuItem(id: 234, name: "ItemName", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: false, price: itemPrice, images: nil, menuItemSizes: nil, menuItemOptions: [
        RetailStoreMenuItemOption(id: 123, name: "OptionName", type: .item, placeholder: "", instances: 0, displayAsGrid: false, mutuallyExclusive: false, minimumSelected: 0, extraCostThreshold: 0, dependencies: nil, values: [RetailStoreMenuItemOptionValue(id: 345, name: "", extraCost: 0, defaultSelection: 1, sizeExtraCost: nil)]),
        RetailStoreMenuItemOption(id: 321, name: "OptionName", type: .item, placeholder: "", instances: 0, displayAsGrid: false, mutuallyExclusive: false, minimumSelected: 0, extraCostThreshold: 0, dependencies: nil, values: [RetailStoreMenuItemOptionValue(id: 456, name: "", extraCost: 0, defaultSelection: 0, sizeExtraCost: nil)])])
    
    let itemWithTwoIdenticalOptionsAndTwoOfSameDefault = RetailStoreMenuItem(id: 234, name: "ItemName", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: false, price: itemPrice, images: nil, menuItemSizes: nil, menuItemOptions: [
        RetailStoreMenuItemOption(id: 123, name: "OptionName", type: .item, placeholder: "", instances: 0, displayAsGrid: false, mutuallyExclusive: false, minimumSelected: 0, extraCostThreshold: 0, dependencies: nil, values: [RetailStoreMenuItemOptionValue(id: 345, name: "", extraCost: 0, defaultSelection: 2, sizeExtraCost: nil)]),
        RetailStoreMenuItemOption(id: 321, name: "OptionName", type: .item, placeholder: "", instances: 0, displayAsGrid: false, mutuallyExclusive: false, minimumSelected: 0, extraCostThreshold: 0, dependencies: nil, values: [RetailStoreMenuItemOptionValue(id: 456, name: "", extraCost: 0, defaultSelection: 0, sizeExtraCost: nil)])])
    
    let itemWithTwoIdenticalOptionsAndFourOfSameDefaultWith2Instances = RetailStoreMenuItem(id: 234, name: "ItemName", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: false, price: itemPrice, images: nil, menuItemSizes: nil, menuItemOptions: [
        RetailStoreMenuItemOption(id: 123, name: "OptionName", type: .item, placeholder: "", instances: 2, displayAsGrid: false, mutuallyExclusive: false, minimumSelected: 0, extraCostThreshold: 0, dependencies: nil, values: [RetailStoreMenuItemOptionValue(id: 345, name: "", extraCost: 0, defaultSelection: 4, sizeExtraCost: nil)]),
        RetailStoreMenuItemOption(id: 321, name: "OptionName", type: .item, placeholder: "", instances: 0, displayAsGrid: false, mutuallyExclusive: false, minimumSelected: 0, extraCostThreshold: 0, dependencies: nil, values: [RetailStoreMenuItemOptionValue(id: 456, name: "", extraCost: 0, defaultSelection: 0, sizeExtraCost: nil)])])
    
    let itemWithTwoIdenticalOptionsAndFourOfSameDefaultWithMutallyExclusive = RetailStoreMenuItem(id: 234, name: "ItemName", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: false, price: itemPrice, images: nil, menuItemSizes: nil, menuItemOptions: [
        RetailStoreMenuItemOption(id: 123, name: "OptionName", type: .item, placeholder: "", instances: 0, displayAsGrid: false, mutuallyExclusive: true, minimumSelected: 0, extraCostThreshold: 0, dependencies: nil, values: [RetailStoreMenuItemOptionValue(id: 345, name: "", extraCost: 0, defaultSelection: 4, sizeExtraCost: nil)]),
        RetailStoreMenuItemOption(id: 321, name: "OptionName", type: .item, placeholder: "", instances: 0, displayAsGrid: false, mutuallyExclusive: false, minimumSelected: 0, extraCostThreshold: 0, dependencies: nil, values: [RetailStoreMenuItemOptionValue(id: 456, name: "", extraCost: 0, defaultSelection: 0, sizeExtraCost: nil)])])
}


