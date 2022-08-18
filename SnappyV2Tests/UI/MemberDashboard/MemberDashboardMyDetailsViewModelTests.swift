//
//  MemberDashboardMyDetailsViewModelTests.swift
//  SnappyV2SnapshotTests
//
//  Created by David Bage on 26/07/2022.
//

import XCTest
import SwiftUI
@testable import SnappyV2
import Combine

@MainActor
class MemberDashboardMyDetailsViewModelTests: XCTestCase {
    
    func test_Init() {
        let sut = makeSUT()
        
        XCTAssertFalse(sut.showAddDeliveryAddressView)
        XCTAssertFalse(sut.showEditAddressView)
        XCTAssertNil(sut.profile)
        XCTAssertTrue(sut.savedCardDetails.isEmpty)
    }
    
    // Test profile populated when present in appState
    func test_whenProfilePresentInAppState_thenProfileSetLocally() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        
        container.appState.value.userData.memberProfile = MemberProfile.mockedData
        
        let sut = makeSUT(container: container)
        
        let expectation = expectation(description: "memberProfileSet")
        var cancellables = Set<AnyCancellable>()
        
        sut.$profile
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.profile, MemberProfile.mockedData)
    }
    
    // Test profile nil when not present in appState
    func test_whenProfileNilInAppState_thenProfileIsNilLocally() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        
        container.appState.value.userData.memberProfile = nil
        
        let sut = makeSUT(container: container)
        
        let expectation = expectation(description: "memberProfileNil")
        var cancellables = Set<AnyCancellable>()
        
        sut.$profile
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertNil(sut.profile)
    }
    
    // Test when addresses are empty in profile, noDeliveryAddresses is true
    func test_whenAddressesEmptyInProfile_noDeliveryAddressesAndNoBillingAddressesIsTrue() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        
        container.appState.value.userData.memberProfile = MemberProfile.mockedDataNoAddresses
        
        let sut = makeSUT(container: container)
        
        let expectation = expectation(description: "noDeliveryAddressesAndNoBillingAddressesIsTrue")
        var cancellables = Set<AnyCancellable>()
        
        sut.$profile
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertTrue(sut.noDeliveryAddresses)
        XCTAssertTrue(sut.noBillingAddresses)
        XCTAssertEqual(sut.deliveryAddresses, [])
        XCTAssertEqual(sut.deliveryAddresses, [])
    }
    
    // Test when addresses are empty in profile, noDeliveryAddresses is true
    func test_whenAddressesNotEmptyInProfile_noDeliveryAddressesAndNoBillingAddressesIsFalse() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        
        container.appState.value.userData.memberProfile = MemberProfile.mockedData
        
        let sut = makeSUT(container: container)
        
        let expectation = expectation(description: "noDeliveryAddressesAndNoBillingAddressesIsFalse")
        var cancellables = Set<AnyCancellable>()
        
        sut.$profile
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertFalse(sut.noDeliveryAddresses)
        XCTAssertFalse(sut.noBillingAddresses)
    }
    
    // Test when addresses are empty in profile, noDeliveryAddresses is true
    func test_whenAddressesNotEmptyInProfile_DeliveryAndBillingAddressesSetAccordingly() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        
        container.appState.value.userData.memberProfile = MemberProfile.mockedData
        
        let sut = makeSUT(container: container)
        
        let expectation = expectation(description: "deliveryAndBillingAddressesPopulated")
        var cancellables = Set<AnyCancellable>()
        
        let deliveryAddresses = Address.mockedSavedAddressesArray.filter { $0.type == .delivery }
        
        let billingAddresses = Address.mockedSavedAddressesArray.filter { $0.type == .billing }
        
        sut.$profile
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.deliveryAddresses, deliveryAddresses)
        XCTAssertEqual(sut.billingAddresses, billingAddresses)
    }
    
    // When add delivery address tapped, showAddDeliveryAddressView is set to true
    func test_whenAddDeliveryAddressTapped_thenShowAddDeliveryAddressViewIsTrue() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
                
        let sut = makeSUT(container: container)
        XCTAssertFalse(sut.showAddDeliveryAddressView) // Intially false
        sut.addAddressTapped(addressType: .delivery)
        XCTAssertTrue(sut.showAddDeliveryAddressView) // Set to true
    }
    
    // Test when dismissAddDeliveryAddressView triggered, showAddDeliveryAddressView set to false
    func test_whenDismissAddDeliveryAddressViewTriggered_thenShowAddDeliveryAddressViewSetToFalse() {
        let sut = makeSUT()
        
        sut.dismissAddDeliveryAddressView()
        XCTAssertFalse(sut.showAddDeliveryAddressView)
    }
    
    // Test when deleteAddressTapped and id is present then delete address
    func test_whenDeleteAddressTapped_givenAddressIDPresent_thenDeleteAddress() async {
        let address = Address(id: 123, isDefault: false, addressName: "Test", firstName: "Test", lastName: "Test", addressLine1: "Test", addressLine2: "Test", town: "Test", postcode: "Test", county: "Test", countryCode: "Test", type: .delivery, location: nil, email: "test@test.com", telephone: "12222333")
        
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(memberService: [.removeAddress(addressId: address.id!)]))
                
        let sut = makeSUT(container: container)
        var isLoadingTriggered = false
        
        await sut.deleteAddressTapped(address, didSetError: { _ in }, setLoading: {_ in
            isLoadingTriggered = true
        })
        XCTAssertTrue(isLoadingTriggered)
        container.services.verify(as: .user)
    }
    
    // Test when deleteAddressTapped but no id present then throw error
    func test_whenDeleteAddressTapped_givenNoAddressId_thenThrowError() async {
        let address = Address(id: nil, isDefault: false, addressName: "Test", firstName: "Test", lastName: "Test", addressLine1: "Test", addressLine2: "Test", town: "Test", postcode: "Test", county: "Test", countryCode: "Test", type: .delivery, location: nil, email: "test@test.com", telephone: "12222333")
        
        let sut = makeSUT()
        
        var errorSet: Swift.Error?
        var isLoadingTriggered = false
        
        await sut.deleteAddressTapped(address, didSetError: { error in
            errorSet = error
        }, setLoading: { _ in
            isLoadingTriggered = true
        })
        
        XCTAssertTrue(isLoadingTriggered)
        XCTAssertEqual(errorSet as? GenericError, GenericError.somethingWrong)
    }
    
    // Test sortedAddresses orders addresses correctly
    func test_whenSortedAddressesCalledOnAddressesArray_thenAddressesSortedAsExpected() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        
        container.appState.value.userData.memberProfile = MemberProfile.mockedDataWithDefaultAddresses
        
        let sut = makeSUT(container: container)
        let expectation = expectation(description: "orderAddresses")
        var cancellables = Set<AnyCancellable>()
        
        sut.$profile
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.deliveryAddresses[0].addressName, "B Address")
        XCTAssertEqual(sut.deliveryAddresses[1].addressName, "A Address")
        XCTAssertEqual(sut.deliveryAddresses[2].addressName, "C Address")
        XCTAssertEqual(sut.deliveryAddresses[3].addressName, "D Address")
        
        XCTAssertEqual(sut.billingAddresses[0].addressName, "B Address")
        XCTAssertEqual(sut.billingAddresses[1].addressName, "A Address")
        XCTAssertEqual(sut.billingAddresses[2].addressName, "C Address")
        XCTAssertEqual(sut.billingAddresses[3].addressName, "D Address")
    }
    
    // Test when dismissEditAddressViewTapped then showEditAddressView set to false
    func test_whenDismissEditAddressViewTapped_thenShowEditAddressViewFalse() {
        let sut = makeSUT()
        sut.dismissEditAddressView()
        XCTAssertFalse(sut.showEditAddressView)
    }
    
    // Test when editAddressTapped then addressToEdit set, addressType set and showEditAddressView is set to true
    func test_whenEditAddressTapped_thenAddressToEditSetAndAddressTypeSetAndShowEditAddressViewTrue() {
        let sut = makeSUT()
        sut.editAddressTapped(addressType: .delivery, address: Address.mockedBillingData)
        
        XCTAssertEqual(sut.addressToEdit, Address.mockedBillingData)
        XCTAssertEqual(sut.addressType, .delivery)
        XCTAssertTrue(sut.showEditAddressView)
    }
    
    func test_whenOnAppearTrigger_thenCorrectServiceCall() async {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(memberService: [.getSavedCards]))
        let sut = makeSUT(container: container)
        
        await sut.onAppearTrigger()
        
        container.services.verify(as: .user)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())) -> MemberDashboardMyDetailsViewModel {

        let sut = MemberDashboardMyDetailsViewModel(container: container)
        trackForMemoryLeaks(sut)
        return sut
    }
}
