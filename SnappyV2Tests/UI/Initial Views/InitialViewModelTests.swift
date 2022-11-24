//
//  InitialViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 17/11/2021.
//

import XCTest
import Combine
import CoreLocation

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
        XCTAssertNil(sut.viewState)
    }
    
    func test_givenStoreSearchResult_whenIsLoadingStatus_thenReturnsTrue() {
        let sut = makeSUT()
        sut.searchResult = .isLoading(last: nil, cancelBag: CancelBag())
        
        XCTAssertTrue(sut.isLoading)
    }
    
    func test_givenNoPreviousLocation_whenUserSearchesLocation_thenLocationDataIsReturned() async {
        
        let testLocation = CLLocation(latitude: CLLocationDegrees(60.15340293), longitude: CLLocationDegrees(-1.14356283)) //Lerwick, Shetland
        let sut = makeSUT(locationAuthorisationStatus: .authorizedAlways, testLocation: testLocation)
                
        await sut.searchViaLocationTapped()
        
        XCTAssertEqual(testLocation, sut.locationManager.lastLocation)
    }
        
    // Location denied alert shown
    func test_givenNoAccessToLocationData_whenUserSearchesLocation_thenLocationDeniedAlertShown() async {
        let sut = makeSUT(locationAuthorisationStatus: .denied)
        
        await sut.searchViaLocationTapped()
        XCTAssertTrue(sut.locationManager.showDeniedLocationAlert)
    }
    
    // Location unknown alert shown
    func test_givenDetectedLocationIsUnknownAndUserIsAuthorised_whenUserSearchesLocation_thenLocationUnknownAlertShown() async {
        let sut = makeSUT(locationAuthorisationStatus: .authorizedAlways, testLocation: nil)
        await sut.searchViaLocationTapped()
        
        XCTAssertTrue(sut.locationManager.showLocationUnknownAlert)
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
        sut.container.appState.value.userData.memberProfile = MemberProfile.mockedDataIsDriver
        
        let expectation = expectation(description: #function)
        var cancellables = Set<AnyCancellable>()
        
        sut.$businessProfileIsLoaded
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.container.appState.value.businessData.businessProfile = BusinessProfile.mockedDataFromAPI
        
        wait(for: [expectation], timeout: 2)
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
        let businessProfileService = MockedBusinessProfileService(expected: [.getProfile])
        businessProfileService.getProfileResponse = .success(true)
        
        let services = DIContainer.Services(
            businessProfileService: businessProfileService,
            retailStoreService: MockedRetailStoreService(expected: []),
            retailStoreMenuService: MockedRetailStoreMenuService(expected: []),
            basketService: MockedBasketService(expected: []),
            memberService: MockedUserService(expected: []),
            checkoutService: MockedCheckoutService(expected: []),
            addressService: MockedAddressService(expected: []),
            utilityService: MockedUtilityService(expected: []),
            imageService: MockedAsyncImageService(expected: []),
            notificationService: MockedNotificationService(expected: []),
            userPermissionsService: MockedUserPermissionsService(expected: [])
        )
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: services)
        let sut = makeSUT(container: container)

        await sut.loadBusinessProfile()
        
        XCTAssertTrue(sut.showFirstView)
        container.services.verify(as: .businessProfile)
    }
    
    func test_whenloadBusinessProfileIsTriggered_thengetMemberProfileIsCalled() async throws {
        let businessProfileService = MockedBusinessProfileService(expected: [.getProfile])
        businessProfileService.getProfileResponse = .success(true)
        
        let services = DIContainer.Services(
            businessProfileService: businessProfileService,
            retailStoreService: MockedRetailStoreService(expected: []),
            retailStoreMenuService: MockedRetailStoreMenuService(expected: []),
            basketService: MockedBasketService(expected: []),
            memberService: MockedUserService(expected: [.restoreLastUser]),
            checkoutService: MockedCheckoutService(expected: []),
            addressService: MockedAddressService(expected: []),
            utilityService: MockedUtilityService(expected: []),
            imageService: MockedAsyncImageService(expected: []),
            notificationService: MockedNotificationService(expected: []),
            userPermissionsService: MockedUserPermissionsService(expected: [])
        )
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: services)
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
        
        let postcode = "PA34 4AG"
        let eventLogger = MockedEventLogger(
            expected: [.sendEvent(for: .storeSearchFromStartView, with: .firebaseAnalytics, params: ["search_text": postcode])]
        )
        
        let container = DIContainer(
            appState: AppState(),
            eventLogger: eventLogger,
            services: .mocked(retailStoreService: [.searchRetailStores(postcode: postcode)])
        )
        let sut = makeSUT(container: container)
        sut.postcode = postcode
        
        await sut.tapLoadRetailStores()
        
        XCTAssertFalse(sut.container.appState.value.routing.showInitialView)
        container.services.verify(as: .retailStore)
        eventLogger.verify()
    }
    
    func test_whenOnAppearSendEvenTriggered_thenAppsFlyerEventCalled() {
        let eventLogger = MockedEventLogger(expected: [.sendEvent(for: .viewScreen(.outside, .initialStoreSearch), with: .appsFlyer, params: [:])])
        let container = DIContainer(appState: AppState(), eventLogger: eventLogger, services: .mocked())
        let sut = makeSUT(container: container)
        
        sut.onAppearSendEvent()
        
        eventLogger.verify()
    }
    
    func test_whenDriverPushNotification_thenDriverNotificationPopulated() {
        
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        let sut = makeSUT(container: container)
        
        let driverNotification = RawNotification(data: ["test": true])
        
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
        
        XCTAssertTrue(driverNotification.data.isEqual(to: sut.driverPushNotification))
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
            imageService: MockedAsyncImageService(expected: []),
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
    
    func test_businessProfileIsLoaded_setToTrueWhenSetInTheAppState() {
        
        let sut = makeSUT()
        
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: #function)
        
        XCTAssertFalse(sut.businessProfileIsLoaded)
        
        sut.$businessProfileIsLoaded
            .filter { $0 }
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.container.appState.value.businessData.businessProfile = BusinessProfile.mockedDataFromAPI
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func test_loadBusinessProfile_whenBusinessProfileServiceSuccessful() async {
        
        let businessProfileService = MockedBusinessProfileService(expected: [.getProfile])
        businessProfileService.getProfileResponse = .success(true)
        
        let services = DIContainer.Services(
            businessProfileService: businessProfileService,
            retailStoreService: MockedRetailStoreService(expected: []),
            retailStoreMenuService: MockedRetailStoreMenuService(expected: []),
            basketService: MockedBasketService(expected: []),
            memberService: MockedUserService(expected: [.restoreLastUser]),
            checkoutService: MockedCheckoutService(expected: []),
            addressService: MockedAddressService(expected: []),
            utilityService: MockedUtilityService(expected: []),
            imageService: MockedAsyncImageService(expected: []),
            notificationService: MockedNotificationService(expected: []),
            userPermissionsService: MockedUserPermissionsService(expected: [])
        )
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: services)
        
        let sut = makeSUT(container: container)
        
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: #function)
        
        sut.$businessProfileIsLoading
            .filter { $0 }
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        await sut.loadBusinessProfile()
        
        wait(for: [expectation], timeout: 2.0)
        
        businessProfileService.verify()
        container.services.verify(as: .member)
        XCTAssertNil(sut.businessProfileLoadingError)
        XCTAssertNil(sut.showAlert)
    }
    
    func test_loadBusinessProfile_whenBusinessProfileServiceReturnsError() async {
        
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        let businessProfileService = MockedBusinessProfileService(expected: [.getProfile])
        businessProfileService.getProfileResponse = .failure(networkError)
        
        let services = DIContainer.Services(
            businessProfileService: businessProfileService,
            retailStoreService: MockedRetailStoreService(expected: []),
            retailStoreMenuService: MockedRetailStoreMenuService(expected: []),
            basketService: MockedBasketService(expected: []),
            memberService: MockedUserService(expected: []),
            checkoutService: MockedCheckoutService(expected: []),
            addressService: MockedAddressService(expected: []),
            utilityService: MockedUtilityService(expected: []),
            imageService: MockedAsyncImageService(expected: []),
            notificationService: MockedNotificationService(expected: []),
            userPermissionsService: MockedUserPermissionsService(expected: [])
        )
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: services)
        
        let sut = makeSUT(container: container)

        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: #function)

        sut.$businessProfileIsLoading
            .filter { $0 }
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        await sut.loadBusinessProfile()
        
        wait(for: [expectation], timeout: 2.0)
        
        businessProfileService.verify()
        XCTAssertFalse(sut.businessProfileIsLoading)
        XCTAssertEqual(sut.businessProfileLoadingError as? NSError, networkError)
        XCTAssertEqual(sut.showAlert?.id, .errorLoadingBusinessProfile)
    }
    
    func test_setupResetPaswordDeepLinkNavigation_givenPasswordResetCode_thenUpdateViewState() {
        
        let sut = makeSUT()
        
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: #function)

        sut.$viewState
            .filter { $0 != nil }
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.container.appState.value.passwordResetCode = "p6rGf6KLBD"
        
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(sut.viewState, .memberDashboard)
    }

    func test_whenIsRestoringIsTrueAndBusinessProfileLoadedIsTrue_thenShowAccountButtonFalse() {
        let sut = makeSUT()
        sut.isRestoring = true
        sut.businessProfileIsLoaded = true
        XCTAssertFalse(sut.showAccountButton)
    }
    
    func test_whenIsRestoringIsFalseAndBusinessProfileLoadedIsFalse_thenShowAccountButtonFalse() {
        let sut = makeSUT()
        sut.isRestoring = false
        sut.businessProfileIsLoaded = false
        XCTAssertFalse(sut.showAccountButton)
    }
    
    func test_whenIsRestoringIsFalseAndBusinessProfileLoadedIsTrue_thenShowAccountButtonTrue() {
        let sut = makeSUT()
        sut.isRestoring = false
        sut.businessProfileIsLoaded = true
        XCTAssertTrue(sut.showAccountButton)
    }
    
    /*Location manager is difficult to mock via protocols, so it is being partially mocked by subclassing the real locationManager
     and manually passing in the location/authorisation data required for testing. */
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()),
                 dateGenerator: @escaping () -> Date = Date.init,
                 locationAuthorisationStatus: CLAuthorizationStatus = .notDetermined,
                 testLocation: CLLocation? = nil) -> InitialViewModel {
        
        let mockedLocationManager = MockedLocationManager(locationAuthStatus: locationAuthorisationStatus, setLocation: testLocation)
        return InitialViewModel(container: container, dateGenerator: dateGenerator, locationManager: mockedLocationManager)
    }
    
}
