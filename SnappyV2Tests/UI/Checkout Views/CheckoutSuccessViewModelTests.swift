//
//  CheckoutSuccessViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 05/09/2022.
//

import Foundation

import XCTest
import Combine
@testable import SnappyV2
import SwiftUI

@MainActor
class CheckoutSuccessViewModelTests: XCTestCase {
    
    func test_whenStoreNumberPresentInAppState_thenAssignToStoreNumber() {
        let sut = makeSUT()
        sut.container.appState.value.userData.selectedStore = .loaded(.mockedData)
        XCTAssertEqual(sut.storeNumber, "tel://01382621132")
    }
    
    func test_whenStoreNumberIsNotNilOrEmpty_thenShowCallStoreButtonTrue() {
        let sut = makeSUT()
        sut.container.appState.value.userData.selectedStore = .loaded(.mockedData)
        XCTAssertTrue(sut.showCallStoreButton)
    }
    
    func test_whenClearSuccessCheckoutBasketCalled_thenSuccessCheckoutBasketCleared() {
        let sut = makeSUT()
        sut.container.appState.value.userData.successCheckoutBasket = .mockedData
        sut.clearSuccessCheckoutBasket()
        XCTAssertNil(sut.container.appState.value.userData.successCheckoutBasket)
    }
    
    func test_whenBusinessProfileNotNilAndOrderingClientUpdateRequirementsNotNil_thenMinRequiredOSForUpdateStringPopulated() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        
        container.appState.value.businessData.businessProfile = .mockedDataFromAPI
        let sut = makeSUT(container: container)
        XCTAssertEqual(sut.minRequiredOSForUpdate, "15.1")
    }
    
    func test_whenBusinessProfileISNil_thenMinRequiredOSForUpdateNil() {
        let sut = makeSUT()
        XCTAssertNil(sut.minRequiredOSForUpdate)
    }
    
    func test_whenBusinessProfileNotNilAndOrderingClientUpdateRequirementsISNil_thenMinRequiredOSForUpdateStringNil() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        
        container.appState.value.businessData.businessProfile = .mockedDataNoIOSUpdateInfo
        let sut = makeSUT(container: container)
        XCTAssertNil(sut.minRequiredOSForUpdate)
    }
    
    func test_whenMinimumOSRequiredForUpdateNilReturnSimplifiedOSUpdatetext_then() {
        let sut = makeSUT()
        
        XCTAssertEqual(sut.osUpdateText, Strings.VersionUpdateCustomisable.simplified.localizedFormat(AppV2Constants.Client.systemVersion))
    }
    
    func test_whenMinimumOSRequiredForUpdateNOTNilReturnSimplifiedOSUpdatetext_then() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        
        container.appState.value.businessData.businessProfile = .mockedDataFromAPI
        
        let sut = makeSUT(container: container)
        
        if let minOSVersion = sut.minRequiredOSForUpdate {
            XCTAssertEqual(sut.osUpdateText, Strings.VersionUpdateCustomisable.standard.localizedFormat(AppV2Constants.Client.systemVersion, minOSVersion))
        } else {
            XCTFail("minOSVersion not set")
        }
    }
    
    func test_whenProfileLoaded_givenUserOSVersionLowerThanMinRequired_thenShowOSUpdateAlertTrue() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        
        var cancellables = Set<AnyCancellable>()
        
        container.appState.value.businessData.businessProfile = .mockedDataMaxOSVersion
        
        let sut = makeSUT(container: container)
        
        let expectation = expectation(description: "set showOSUpdateAlert to true")
        
        sut.$showOSUpdateAlert
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertTrue(sut.showOSUpdateAlert)
    }
    
    func test_whenProfileLoaded_givenUserOSVersionHigherThanMinRequired_thenShowOSUpdateAlertFalse() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        
        var cancellables = Set<AnyCancellable>()
        
        container.appState.value.businessData.businessProfile = .mockedDataMinOSVersion
        
        let sut = makeSUT(container: container)
        
        let expectation = expectation(description: "set showOSUpdateAlert to true")
        
        sut.$showOSUpdateAlert
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertFalse(sut.showOSUpdateAlert)
    }
    
    func test_whenProfileLoaded_givenNoProfileAndUserOSVersionHigherThanMinRequired_thenShowOSUpdateAlertFalse() {
        var cancellables = Set<AnyCancellable>()
        
        let sut = makeSUT()
        
        let expectation = expectation(description: "set showOSUpdateAlert to true")
        
        sut.$showOSUpdateAlert
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertFalse(sut.showOSUpdateAlert)
    }
    
    
    func test_whenProfileLoaded_givenProfilePresentAndNoIOSUpgradeInfoAndUserOSVersionHigherThanMinRequired_thenShowOSUpdateAlertFalse() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        
        var cancellables = Set<AnyCancellable>()
        
        container.appState.value.businessData.businessProfile = .mockedDataNoIOSUpdateInfo
        
        let sut = makeSUT(container: container)
        
        let expectation = expectation(description: "set showOSUpdateAlert to true")
        
        sut.$showOSUpdateAlert
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertFalse(sut.showOSUpdateAlert)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), checkoutState: @escaping (CheckoutRootViewModel.CheckoutState) -> Void = {_ in }, dateGenerator: @escaping () -> Date = Date.init) -> CheckoutSuccessViewModel {
        let sut = CheckoutSuccessViewModel(container: container)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
