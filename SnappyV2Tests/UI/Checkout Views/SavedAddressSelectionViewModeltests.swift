//
//  SavedAddressSelectionViewModeltests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 18/07/2022.
//

import XCTest
import Combine
@testable import SnappyV2
import SwiftUI

@MainActor
class SavedAddressSelectionViewModeltests: XCTestCase {
    typealias SavedAddressStrings = Strings.CheckoutDetails.SavedAddressesSelectionView
    
    func test_whenAddressTypeIsDelivery_thenTitleSet() {
        let sut = makeSUT(container: .preview, addressType: .delivery)
        XCTAssertEqual(sut.title, SavedAddressStrings.title.localized)
    }
    
    func test_whenAddressTypeIsBilling_thenTitleSet() {
        let sut = makeSUT(container: .preview, addressType: .delivery)
        XCTAssertEqual(sut.title, SavedAddressStrings.title.localized)
    }
    
    func test_whenAddressTypeIsDelivery_thenButtonTitleSet() {
        let sut = makeSUT(container: .preview, addressType: .delivery)
        XCTAssertEqual(sut.buttonTitle, SavedAddressStrings.setAsDeliveryAddressButton.localized )
    }
    
    func test_whenAddressTypeIsBilling_thenButtonTitleSet() {
        let sut = makeSUT(container: .preview, addressType: .billing)
        XCTAssertEqual(sut.buttonTitle, SavedAddressStrings.setAsBillingAddressButton.localized)
    }
    
    
    func test_whenAddressTypeIsDelivery_thenNavTitleSet() {
        let sut = makeSUT(container: .preview, addressType: .delivery)
        XCTAssertEqual(sut.navTitle, SavedAddressStrings.navTitle.localized)
    }
    
    func test_whenAddressTypeIsBilling_thenNavTitleSet() {
        let sut = makeSUT(container: .preview, addressType: .billing)
        XCTAssertEqual(sut.navTitle, SavedAddressStrings.navTitleBilling.localized)
    }
    
    func test_whenInit_givenBasketAddressesArePresent_thenSetUpInitialAddresses() {

        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.basket = Basket.mockedDataWithAddresses
        let sut = makeSUT(container: container, addressType: .delivery)
        XCTAssertEqual(sut.selectedAddress?.id, 102259)
    }

    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), addressType: AddressType) -> SavedAddressesSelectionViewModel {
        let addresses = Address.mockedSavedAddressesArray
        
        let sut = SavedAddressesSelectionViewModel(
            container: container,
            savedAddressType: addressType,
            addresses: addresses,
            firstName: "Test",
            lastName: "Test2",
            email: "test@test.com",
            phone: "09928282828")
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
