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
    }
    
    func test_init_givenItemHasNoMissedPromotions() {
        let storeMenuItemPrice = RetailStoreMenuItemPrice(price: 10, fromPrice: 9, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let storeMenuItem = RetailStoreMenuItem(id: 123, name: "ItemName", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: storeMenuItemPrice, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory(id: 345, name: ""), itemDetails: nil)
        let basketItem = BasketItem(basketLineId: 321, menuItem: storeMenuItem, totalPrice: 10, totalPriceBeforeDiscounts: 9, price: 9, pricePaid: 9, quantity: 0, instructions: nil, size: nil, selectedOptions: nil, missedPromotions: nil, isAlcohol: false)
        let sut = makeSUT(item: basketItem, changeQuantity: {_, _ in})
        
        XCTAssertEqual(sut.item, basketItem)
        XCTAssertTrue(sut.quantity.isEmpty)
        XCTAssertNil(sut.latestMissedPromotion)
        XCTAssertFalse(sut.hasMissedPromotions)
    }
    
    func test_init_givenItemHasMissedPromotions() {
        let storeMenuItemPrice = RetailStoreMenuItemPrice(price: 10, fromPrice: 9, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let storeMenuItem = RetailStoreMenuItem(id: 123, name: "ItemName", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: storeMenuItemPrice, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory(id: 345, name: ""), itemDetails: nil)
        let basketItem = BasketItem(basketLineId: 321, menuItem: storeMenuItem, totalPrice: 10, totalPriceBeforeDiscounts: 9, price: 9, pricePaid: 9, quantity: 0, instructions: nil, size: nil, selectedOptions: nil, missedPromotions: [
            BasketItemMissedPromotion(id: 123, name: "Test promo", type: .multiSectionDiscount, missedSections: nil),
            BasketItemMissedPromotion(id: 456, name: "Test promo", type: .multiSectionDiscount, missedSections: nil)
        ], isAlcohol: false)
        let sut = makeSUT(item: basketItem, changeQuantity: {_, _ in})
        
        XCTAssertEqual(sut.item, basketItem)
        XCTAssertTrue(sut.quantity.isEmpty)
        XCTAssertEqual(sut.bannerDetails.count, 2)
        XCTAssertTrue(sut.hasMissedPromotions)
    }
    
    func test_givenBasketItem_whenOnSubmit_thenQuantityIsResetAndClosureReturns() {
        let storeMenuItemPrice = RetailStoreMenuItemPrice(price: 10, fromPrice: 9, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let storeMenuItem = RetailStoreMenuItem(id: 123, name: "ItemName", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: storeMenuItemPrice, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory(id: 345, name: ""), itemDetails: nil)
        let basketItem = BasketItem(basketLineId: 321, menuItem: storeMenuItem, totalPrice: 10, totalPriceBeforeDiscounts: 9, price: 9, pricePaid: 9, quantity: 0, instructions: nil, size: nil, selectedOptions: nil, missedPromotions: nil, isAlcohol: false)
        let sut = makeSUT(item: basketItem) { basketItem, quantity in
            XCTAssertEqual(basketItem.menuItem.id, 123)
            XCTAssertEqual(quantity, 2)
            XCTAssertEqual(basketItem.basketLineId, 321)
        }
        sut.quantity = "2"
        
        sut.onSubmit()
        
        XCTAssertTrue(sut.quantity.isEmpty)
    }
    
    func test_whenFilterQuantityToStringNumberIsTriggered_thenOnlyNumberIsStored() {
        let storeMenuItemPrice = RetailStoreMenuItemPrice(price: 10, fromPrice: 9, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let storeMenuItem = RetailStoreMenuItem(id: 123, name: "ItemName", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: storeMenuItemPrice, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory(id: 345, name: ""), itemDetails: nil)
        let basketItem = BasketItem(basketLineId: 321, menuItem: storeMenuItem, totalPrice: 10, totalPriceBeforeDiscounts: 9, price: 9, pricePaid: 9, quantity: 0, instructions: nil, size: nil, selectedOptions: nil, missedPromotions: nil, isAlcohol: false)
        let sut = makeSUT(item: basketItem, changeQuantity: {_, _ in})
        
        sut.filterQuantityToStringNumber(stringValue: "OneTwo12")
        
        XCTAssertEqual(sut.quantity, "12")
    }
    
    func test_hasMissedPromotions() {
        let storeMenuItemPrice = RetailStoreMenuItemPrice(price: 10, fromPrice: 9, unitMetric: "", unitsInPack: 0, unitVolume: 0, wasPrice: nil)
        let storeMenuItem = RetailStoreMenuItem(id: 123, name: "ItemName", eposCode: nil, outOfStock: false, ageRestriction: 0, description: nil, quickAdd: true, acceptCustomerInstructions: false, basketQuantityLimit: 500, price: storeMenuItemPrice, images: nil, menuItemSizes: nil, menuItemOptions: nil, availableDeals: nil, itemCaptions: nil, mainCategory: MenuItemCategory(id: 345, name: ""), itemDetails: nil)
        let basketItem_with_missed_promo = BasketItem(basketLineId: 321, menuItem: storeMenuItem, totalPrice: 10, totalPriceBeforeDiscounts: 9, price: 9, pricePaid: 9, quantity: 0, instructions: nil, size: nil, selectedOptions: nil, missedPromotions: [BasketItemMissedPromotion(id: 123, name: "Test promotion", type: .multiSectionDiscount, missedSections: nil), BasketItemMissedPromotion(id: 456, name: "Test promotion1", type: .multiSectionDiscount, missedSections: nil)], isAlcohol: false)
        let basketItem_without_missed_promo = BasketItem(basketLineId: 321, menuItem: storeMenuItem, totalPrice: 10, totalPriceBeforeDiscounts: 9, price: 9, pricePaid: 9, quantity: 0, instructions: nil, size: nil, selectedOptions: nil, missedPromotions: nil, isAlcohol: false)
        
        let sutMissedPromo = makeSUT(item: basketItem_with_missed_promo, changeQuantity: {_, _ in})
        let sutNoMissedPromo = makeSUT(item: basketItem_without_missed_promo, changeQuantity: {_, _ in})
        
        XCTAssertTrue(sutMissedPromo.hasMissedPromotions)
        XCTAssertFalse(sutNoMissedPromo.hasMissedPromotions)
        XCTAssertEqual(sutMissedPromo.bannerDetails.count, 2)
        XCTAssertEqual(sutMissedPromo.bannerDetails[1].type, .missedOffer)
        XCTAssertEqual(sutMissedPromo.bannerDetails[1].text, "MISSED: Test promotion1")
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
    
    func test_givenMissedPromo_whenShowMissedPromoTapped_thenMissedPromoShownIsPopulated() {
        let basketItem = BasketItem.mockedDataComplex
        let promo = BasketItemMissedPromotion.mockedData
        let sut = makeSUT(item: basketItem, changeQuantity: {_,_ in})
        
        sut.showMissed(promo: promo)
        
        XCTAssertEqual(sut.missedPromoShown, promo)
    }
    
    func test_givenItemWithOptions_whenInit_thenPromoBannerAddedToBannerDetails() {
        let basketItem = BasketItem.mockedDataComplex
        let sut = makeSUT(item: basketItem, changeQuantity: {_,_ in})
        
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
