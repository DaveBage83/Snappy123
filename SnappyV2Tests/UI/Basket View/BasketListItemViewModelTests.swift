//
//  BasketListItemViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 05/01/2022.
//

import XCTest
import Combine
@testable import SnappyV2

@MainActor
class BasketListItemViewModelTests: XCTestCase {
    
    func test_init() {
        let basketItem = BasketItem.mockedData
        let sut = makeSUT(item: basketItem, changeQuantity: {_,_ in })
        
        XCTAssertTrue(sut.sizeText.isEmpty)
        XCTAssertFalse(sut.hasMissedPromotions)
        XCTAssertNil(sut.basket)
        XCTAssertTrue(sut.bannerDetails.isEmpty)
        XCTAssertNil(sut.missedPromoShown)
        XCTAssertNil(sut.complexItemShown)
        XCTAssertTrue(sut.optionTexts.isEmpty)
    }
    
    func test_init_givenItemHasNoMissedPromotions() {
        let storeMenuItemPrice = RetailStoreMenuItemPrice(price: 10, fromPrice: 9, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let storeMenuItem = RetailStoreMenuItem(id: 123, name: "ItemName", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: storeMenuItemPrice, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory(id: 345, name: ""), itemDetails: nil, deal: nil)
        let basketItem = BasketItem(basketLineId: 321, menuItem: storeMenuItem, totalPrice: 10, totalPriceBeforeDiscounts: 9, price: 9, pricePaid: 9, quantity: 0, instructions: nil, size: nil, selectedOptions: nil, missedPromotions: nil, isAlcohol: false)
        let sut = makeSUT(item: basketItem, changeQuantity: {_, _ in})
        
        XCTAssertEqual(sut.item, basketItem)
        XCTAssertFalse(sut.hasMissedPromotions)
    }
    
    func test_givenBasketItemWithPromos_whenInit_thenHasMissedPromotions() {
        let basketItem = BasketItem.mockedDataComplex
        let basket = Basket.mockedData
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.basket = basket
        let sut = makeSUT(container: container, item: basketItem, changeQuantity: {_, _ in})
        
        let expectation = expectation(description: #function)
        var cancellables = Set<AnyCancellable>()
        
        sut.$hasMissedPromotions
            .collect(2)
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertTrue(sut.hasMissedPromotions)
        XCTAssertEqual(sut.bannerDetails.count, 2)
        XCTAssertEqual(sut.bannerDetails[1].type, .missedOffer)
        XCTAssertEqual(sut.bannerDetails[1].text, "MISSED: " + (basketItem.missedPromotions?.first?.name ?? ""))
    }
    
    func test_givenBasketItemMissedPromotion_whenShowMissedPromoTriggered_thenMissedPromoShownIsPopulated() {
        let promo = BasketItemMissedPromotion.mockedData
        let sut = makeSUT(item: BasketItem.mockedData, changeQuantity: {_,_ in })
        
        sut.showPromoTapped(promo: promo)
        
        XCTAssertEqual(sut.missedPromoShown, promo)
    }
    
    func test_givenMissedPromoShownPopulated_whenDismissTapped_thenMissedPromoShownIsNil() {
        let basketItem = BasketItem.mockedData
        let sut = makeSUT(item: basketItem, changeQuantity: {_,_ in })
        sut.missedPromoShown = BasketItemMissedPromotion.mockedData
        
        sut.dismissTapped()
        
        XCTAssertNil(sut.missedPromoShown)
    }
    
    func test_givenBasketItemAndStore_whenInit_thenTotalPriceStringAndPricceStringAreCorrect() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        let basketItem = BasketItem.mockedData
        let store = RetailStoreDetails.mockedData
        container.appState.value.userData.selectedStore = .loaded(store)
        let sut = makeSUT(container: container, item: basketItem, changeQuantity: {_,_ in})
        
        XCTAssertEqual(sut.totalPriceString, "£10.00")
        XCTAssertEqual(sut.priceString, "£10.00")
    }
    
    func test_givenItemWithOptions_whenInit_thenPromoBannerAddedToBannerDetails() {
        let basketItem = BasketItem.mockedDataComplex
        let basket = Basket.mockedData
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.basket = basket
        let sut = makeSUT(container: container, item: basketItem, changeQuantity: {_,_ in})
        
        let expectation = expectation(description: #function)
        var cancellables = Set<AnyCancellable>()
        
        sut.$hasMissedPromotions
            .collect(2)
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.bannerDetails.first?.type, .viewSelection)
        XCTAssertEqual(sut.bannerDetails.first?.text, Strings.BasketView.viewSelection.localized)
    }
    
    func test_givenComplexItem_whenInit_thenSizeTextIsCorrect() {
        let basketItem = BasketItem.mockedDataComplex
        let sut = makeSUT(item: basketItem, changeQuantity: {_,_ in})
        
        XCTAssertEqual(sut.sizeText, " (\(basketItem.size?.name ?? ""))")
    }
    
    func test_givenBasketAndBasketItem_whenViewSelectionTapped_thenCorrectServiceCalledAndComplexItemShownIsPopulated() async {
        let basket = Basket.mockedData
        let basketItem = basket.items.first!
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.basket = basket
        let sut = makeSUT(container: container, item: basketItem, changeQuantity: {_,_ in})

        sut.viewSelectionTapped()

        XCTAssertEqual(sut.complexItemShown, RetailStoreMenuItem.mockedDataComplex)
    }
    
    func test_givenBasketWithComplexItem_thenInit_thenOptionTextsPopulatedCorrectly() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        let basket = Basket.mockedData
        container.appState.value.userData.basket = basket
        let basketItem = BasketItem.mockedDataComplex
        let sut = makeSUT(container: container, item: basketItem, changeQuantity: {_,_ in})
        
        let expectation = expectation(description: #function)
        var cancellables = Set<AnyCancellable>()
        
        sut.$optionTexts
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.optionTexts.count, 3)
        XCTAssertEqual(sut.optionTexts.first?.title, basketItem.menuItem.menuItemOptions?.first?.name)
        XCTAssertEqual(sut.optionTexts.first?.type, .option)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), item: BasketItem, changeQuantity: @escaping (BasketItem, Int) -> Void) -> BasketListItemViewModel {
        let sut = BasketListItemViewModel(container: container, item: item, changeQuantity: changeQuantity)
        trackForMemoryLeaks(sut)
        return sut
    }

}
