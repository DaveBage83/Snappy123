//
//  AddressCardViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 15/04/2022.
//

import XCTest
@testable import SnappyV2
import Combine

class AddressCardViewModelTests: XCTestCase {
    
    func test_init() {
        let sut = makeSUT(address: Address.mockedBillingData)
        
        XCTAssertFalse(sut.isDefault)
        XCTAssertEqual(sut.profile, MemberProfile.mockedData)
        XCTAssertTrue(sut.allowDelete)
    }
    
    func test_whenAddressSetToDefault_theIsDefaultIsTrue() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(memberService: [.setDefaultAddress(addressId: 102259)]))
        
        let sut = makeSUT(container: container, address: Address.mockedBillingData)
        
        let expectation = expectation(description: "setAddressToDefault")
        
        sut.$profile
            .sink(receiveValue: { _ in
                expectation.fulfill()
            })
            .store(in: CancelBag())
        
        sut.setAddressToDefault()
        
        wait(for: [expectation], timeout: 0.2)
        
        container.services.verify(as: .user)
    }
    
    func test_whenAddressDeletedCalled_thenAddressDeletedSuccessfully() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(memberService: [.removeAddress(addressId: 102259)]))
        
        let sut = makeSUT(container: container, address: Address.mockedBillingData)
        
        let expectation = expectation(description: "deleteAddress")
        
        sut.$profile
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: CancelBag())
        
        sut.deleteAddress()
        
        wait(for: [expectation], timeout: 0.2)
        
        container.services.verify(as: .user)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), address: Address) -> AddressCardViewModel {
        container.appState.value.userData.memberProfile = MemberProfile.mockedData
        let sut = AddressCardViewModel(container: container, address: address)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}

