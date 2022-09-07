//
//  InitialViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 17/11/2021.
//

import XCTest
import Combine
@testable import SnappyV2

// 3rd parties
import KeychainAccess
import DriverInterface

@MainActor
class InitialViewModelTests: XCTestCase {
    func test_init() {
        let sut = makeSUT()
        
        XCTAssertEqual(sut.container.appState.value, AppState())
        XCTAssertFalse(sut.loginButtonPressed)
        XCTAssertFalse(sut.hasStore)
        XCTAssertEqual(sut.searchResult, .notRequested)
        XCTAssertFalse(sut.isLoading)
    }
    
    func test_givenStoreSearchResult_whenIsLoadingStatus_thenReturnsTrue() {
        let sut = makeSUT()
        sut.searchResult = .isLoading(last: nil, cancelBag: CancelBag())
        
        XCTAssertTrue(sut.isLoading)
    }
    
    func test_givenStoreSearchResult_whenLoadedStatus_thenReturnsFalse() {
        let sut = makeSUT()
        sut.searchResult = .loaded(RetailStoresSearch(storeProductTypes: nil, stores: nil, fulfilmentLocation: FulfilmentLocation(country: "", latitude: 0, longitude: 0, postcode: "")))
        
        XCTAssertFalse(sut.isLoading)
    }
    
    func test_whenMemberSignedIn_thenShowLoginScreenAndShowRegScreenAreFalse() {
        let sut = makeSUT()
        
        let profile = MemberProfile.mockedData
        
        sut.container.appState.value.userData.memberProfile = profile
        
        XCTAssertNil(sut.viewState)
    }
    
    func test_whenDriverMemberSignedIn_thenShowDriverStartShiftTrue() {
        let sut = makeSUT()
        
        let profile = MemberProfile.mockedDataIsDriver
        
        sut.container.appState.value.userData.memberProfile = profile
    
        XCTAssertEqual(sut.showDriverStartShift, true)
    }
    
    func test_whenLoginTapped_thenShowLoginScreenSetToTrue() {
        let sut = makeSUT()
        
        sut.loginTapped()
        XCTAssertEqual(sut.viewState, .login)
    }
    
    func test_whenSignupTapped_thenShowRegistrationScreenSetToTrue() {
        let sut = makeSUT()
        
        sut.signUpTapped()
        
        XCTAssertEqual(sut.viewState, .create)
    }
    
    func test_whenStartDriverShiftTapped_thenSetDriverSettings() async {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(memberService: [.getDriverSessionSettings]))
        let mockedSettings = DriverSessionSettings.mockedData
        let timeTraver = TimeTraveler()
        let nineAM20220803 = Date(timeIntervalSince1970: 1659517200)
        timeTraver.date = nineAM20220803
        let sut = makeSUT(container: container) {
            timeTraver.generateDate()
        }
        sut.container.appState.value.userData.memberProfile = .mockedDataIsDriver
        
        await sut.startDriverShiftTapped()
        XCTAssertEqual(sut.driverDependencies?.bussinessId, AppV2Constants.Business.id)
        XCTAssertEqual(sut.driverDependencies?.apiRootPath, AppV2Constants.DriverInterface.baseURL)
        XCTAssertEqual(sut.driverDependencies?.v1sessionToken, mockedSettings.v1sessionToken)
        XCTAssertEqual(sut.driverDependencies?.businessLocationName, AppV2Constants.Business.businessLocationName)
        XCTAssertEqual(sut.driverDependencies?.driverUserDetails.firstName, sut.container.appState.value.userData.memberProfile?.firstname)
        XCTAssertEqual(sut.driverDependencies?.driverUserDetails.lastName, sut.container.appState.value.userData.memberProfile?.lastname)
        XCTAssertEqual(sut.driverDependencies?.driverUserDetails.endDriverShiftRestrictions, mockedSettings.endDriverShiftRestrictions.mapToDriverPackageRestriction())
        XCTAssertEqual(sut.driverDependencies?.driverUserDetails.canRefundItems, mockedSettings.canRefundItems)
        XCTAssertEqual(sut.driverDependencies?.driverUserDetails.automaticEnRouteDetection, mockedSettings.automaticEnRouteDetection)
        XCTAssertEqual(sut.driverDependencies?.driverUserDetails.canRequestUnassignedOrders, mockedSettings.canRequestUnassignedOrders)
        XCTAssertEqual(sut.driverDependencies?.driverAppStoreSettings, mockedSettings.mapToDriverAppSettingsProfiles())
        XCTAssertEqual(sut.driverDependencies?.getPriceStringHandler(23.3), "£23.30")
        
        // Removed because fails only on Xcode Cloud:
        // XCTAssertEqual failed: ("Optional(2022-08-03 08:59:59 +0000)") is not equal to ("Optional(2022-08-03 09:00:00 +0000)")
        // XCTAssertEqual(sut.driverDependencies?.getTrueDateHandler(), nineAM20220803)
        
        container.services.verify(as: .member)
    }

    func test_whenloadBusinessProfileIsTriggered_thengetProfileIsCalled() async throws {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(businessProfileService: [.getProfile]))
        let sut = makeSUT(container: container)

        await sut.loadBusinessProfile()
        
        XCTAssertTrue(sut.showFirstView)
        container.services.verify(as: .businessProfile)
    }
    
    func test_whenloadBusinessProfileIsTriggered_thengetMemberProfileIsCalled() async throws {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(memberService: [.restoreLastUser]))
        let sut = makeSUT(container: container)
        
        let keychain = Keychain(service: Bundle.main.bundleIdentifier!)
        keychain["memberSignedIn"] = "email"
        
        await sut.loadBusinessProfile()
        
        XCTAssertTrue(sut.showFirstView)
        container.services.verify(as: .member)
    }
    
    func test_whenDissmissLocationAlertTappedTriggered_thenLocationIsLoadingIsFalse() {
        let sut = makeSUT()
        sut.locationIsLoading = true
        
        sut.dismissLocationAlertTapped()
        
        XCTAssertFalse(sut.locationIsLoading)
    }
    
    func test_whenTapLoadRetailStoresTriggered_thenServiceCalledAndShowInitialViewIsFalse() async {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(retailStoreService: [.searchRetailStores(postcode: "PA34 4AG")]))
        let sut = makeSUT(container: container)
        
        await sut.tapLoadRetailStores()
        
        XCTAssertFalse(sut.container.appState.value.routing.showInitialView)
        container.services.verify(as: .retailStore)
    }
    
    func test_whenOnAppearSendEvenTriggered_thenAppsFlyerEventCalled() {
        let eventLogger = MockedEventLogger(expected: [.sendEvent(for: .viewScreen, with: .appsFlyer, params: ["screen_reference": "initial_store_search"])])
        let container = DIContainer(appState: AppState(), eventLogger: eventLogger, services: .mocked())
        let sut = makeSUT(container: container)
        
        sut.onAppearSendEvent()
        
        eventLogger.verify()
    }
    
    func test_whenDriverPushNotification_thenDriverNotificationPopulated() {
        
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container)
        
        let driverNotification: [AnyHashable: Any] = ["test": true]
        
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: #function)
        
        sut.container.appState
            .map(\.pushNotifications.driverNotification)
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.container.appState.value.pushNotifications.driverNotification = driverNotification
        
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertTrue(driverNotification.isEqual(to: sut.driverPushNotification))
    }
    
    func test_registerForNotificationsHandler_ignoreUnknownAndReturnRegistered() async {

        let userPermissionsService = MockedUserPermissionsService(expected: [.request(permission: .pushNotifications)])
        
        let services = DIContainer.Services(
            businessProfileService: MockedBusinessProfileService(expected: []),
            retailStoreService: MockedRetailStoreService(expected: []),
            retailStoreMenuService: MockedRetailStoreMenuService(expected: []),
            basketService: MockedBasketService(expected: []),
            memberService: MockedUserService(expected: []),
            checkoutService: MockedCheckoutService(expected: []),
            addressService: MockedAddressService(expected: []),
            utilityService: MockedUtilityService(expected: []),
            imageService: MockedImageService(expected: []),
            notificationService: MockedNotificationService(expected: []),
            userPermissionsService: userPermissionsService
        )
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: services)
        
        let sut = makeSUT(container: container)
        
        // The registerForNotificationsHandler() functionality requires the following with delays
        // because it starts the system request and then makes the binding. It cannot start the
        // binding until after the system request.
        
        userPermissionsService.requestOutcome = {
            Task { @MainActor in
                // Delay the task by 0.1 second
                try await Task.sleep(nanoseconds: 10000000)
                // The binding should filter this:
                container.appState.value.permissions.push = .unknown
                
                // Delay the task by 0.1 second
                try await Task.sleep(nanoseconds: 10000000)
                // The binding should pass this:
                container.appState.value.permissions.push = .granted
            }
        }
        
        let result = await sut.exposeRegisterForNotificationsHandler()
        
        XCTAssertEqual(result.enabled, true)
        XCTAssertEqual(result.denied, false)
    }

    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), dateGenerator: @escaping () -> Date = Date.init) -> InitialViewModel {
        return InitialViewModel(container: container, dateGenerator: dateGenerator)
    }
}
