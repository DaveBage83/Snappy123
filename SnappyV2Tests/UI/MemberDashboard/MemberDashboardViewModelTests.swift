//
//  MemberDashboardViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 20/03/2022.
//

import XCTest
import Combine
@testable import SnappyV2

@MainActor
class MemberDashboardViewModelTests: XCTestCase {
    func test_init_whenNoProfilePresent_thenProfileDetailsNotPresent() {
        let sut = makeSUT()
        XCTAssertEqual(sut.viewState, .dashboard)
        XCTAssertFalse(sut.firstNamePresent)
        XCTAssertTrue(sut.isDashboardSelected)
        XCTAssertFalse(sut.isOrdersSelected)
        XCTAssertFalse(sut.isAddressesSelected)
        XCTAssertFalse(sut.isProfileSelected)
        XCTAssertFalse(sut.isLoyaltySelected)
        XCTAssertFalse(sut.isLogOutSelected)
        XCTAssertNil(sut.profile)
        XCTAssertTrue(sut.noMemberFound)
        XCTAssertFalse(sut.showVerifyAccountOption)
    }
    
    func test_init_whenProfileIsPresent_thenProfileDetailsArePopulated() {
        let sut = makeSUT(profile: MemberProfile.mockedData)
        XCTAssertEqual(sut.viewState, .dashboard)
        XCTAssertTrue(sut.isDashboardSelected)
        XCTAssertFalse(sut.isOrdersSelected)
        XCTAssertFalse(sut.isAddressesSelected)
        XCTAssertFalse(sut.isProfileSelected)
        XCTAssertFalse(sut.isLoyaltySelected)
        XCTAssertFalse(sut.isLogOutSelected)
        XCTAssertFalse(sut.showVerifyAccountOption)
    }
    
    func test_init_whenProfileIsPresentWithoutVerifiedNumber_thenProfileDetailsArePopulatedWithVerifyOption() {
        let sut = makeSUT(profile: MemberProfile.mockedDataMobileNotVerified)
        XCTAssertEqual(sut.viewState, .dashboard)
        XCTAssertTrue(sut.isDashboardSelected)
        XCTAssertFalse(sut.isOrdersSelected)
        XCTAssertFalse(sut.isAddressesSelected)
        XCTAssertFalse(sut.isProfileSelected)
        XCTAssertFalse(sut.isLoyaltySelected)
        XCTAssertFalse(sut.isLogOutSelected)
        XCTAssertTrue(sut.showVerifyAccountOption)
    }

    func test_whenAddAddressTapped_thenAddressAdded() async {
        let address = Address(id: 123, isDefault: false, addressName: "", firstName: "", lastName: "", addressLine1: "", addressLine2: "", town: "", postcode: "", county: "", countryCode: "", type: .delivery, location: nil, email: nil, telephone: nil)

        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(memberService: [.addAddress(address: address)]))
        
        let sut = makeSUT(container: container)
        await sut.addAddress(address: address)

        sut.container.services.verify(as: .member)
    }
    
    func test_whenUpdateAddressTapped_thenAddressUpdated() async {
        let address = Address(id: 123, isDefault: false, addressName: "", firstName: "", lastName: "", addressLine1: "", addressLine2: "", town: "", postcode: "", county: "", countryCode: "", type: .delivery, location: nil, email: nil, telephone: nil)

        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(memberService: [.updateAddress(address: address)]))
        
        let sut = makeSUT(container: container)
        await sut.updateAddress(address: address)

        sut.container.services.verify(as: .member)
    }

    func test_init_whenNormalMemberProfilePresent_thenMemberDetailsPopulatedWithoutStartShift() {
        let cancelbag = CancelBag()
        let sut = makeSUT(profile: MemberProfile.mockedData)
        let expectation = expectation(description: "userProfileDetailsPopulated")
        
        sut.$profile
            .first()
            .receive(on: RunLoop.main)
            .sink { profile in
                XCTAssertTrue(sut.firstNamePresent)
                XCTAssertEqual(sut.profile, MemberProfile.mockedData)
                expectation.fulfill()
            }
            .store(in: cancelbag)
        wait(for: [expectation], timeout: 0.2)
        
        XCTAssertFalse(sut.showDriverStartShiftOption)
    }
    
    func test_init_whenDriverMemberProfilePresent_thenMemberDetailsPopulated() {
        let sut = makeSUT(profile: MemberProfile.mockedDataIsDriver)
        XCTAssertTrue(sut.showDriverStartShiftOption)
    }
    
    func test_whenDashboardTapped_thenViewStateIsDashboardAndIsDashboardSelectedIsTrue() {
        let sut = makeSUT()
        
        // As the default init viewState is .dashboard, for this test first
        // we set viewState to .orders and then we reset to .dashboard

        sut.ordersTapped()
        XCTAssertFalse(sut.isDashboardSelected)
        XCTAssertNotEqual(sut.viewState, .dashboard)
        sut.dashboardTapped()
        XCTAssertTrue(sut.isDashboardSelected)
        XCTAssertEqual(sut.viewState, .dashboard)
    }
    
    func test_whenOrdersTapped_thenViewStateIsOrdersAndIsOrdersSelectedIsTrue() {
        let sut = makeSUT()

        sut.ordersTapped()
        XCTAssertTrue(sut.isOrdersSelected)
        XCTAssertEqual(sut.viewState, .orders)
    }
    
    func test_whenAddressesTapped_thenViewStateIsAddressesAndIsAddressesSelectedIsTrue() {
        let sut = makeSUT()

        sut.myDetailsTapped()
        XCTAssertTrue(sut.isAddressesSelected)
        XCTAssertEqual(sut.viewState, .myDetails)
    }
    
    func test_whenProfileTapped_thenViewStateIsProfileAndIsProfileSelectedIsTrue() {
        let sut = makeSUT()

        sut.profileTapped()
        XCTAssertTrue(sut.isProfileSelected)
        XCTAssertEqual(sut.viewState, .profile)
    }
    
    func test_whenLoyaltyTapped_thenViewStateIsLoyaltyAndIsLoyaltySelectedIsTrue() {
        let sut = makeSUT()

        sut.loyaltyTapped()
        XCTAssertTrue(sut.isLoyaltySelected)
        XCTAssertEqual(sut.viewState, .loyalty)
    }
    
    func test_whenVerifyAccountTappedAndOpenViewResultTrue_thenSetRoutingShowVerifyMobileViewToTrue() async {
        
        var memberService = MockedUserService(expected: [.requestMobileVerificationCode])
        memberService.requestMobileVerificationCodeResponse = .success(true)
        
        let services = DIContainer.Services(
            businessProfileService: MockedBusinessProfileService(expected: []),
            retailStoreService: MockedRetailStoreService(expected: []),
            retailStoreMenuService: MockedRetailStoreMenuService(expected: []),
            basketService: MockedBasketService(expected: []),
            memberService: memberService,
            checkoutService: MockedCheckoutService(expected: []),
            addressService: MockedAddressService(expected: []),
            utilityService: MockedUtilityService(expected: []),
            imageService: MockedAsyncImageService(expected: []),
            notificationService: MockedNotificationService(expected: []),
            userPermissionsService: MockedUserPermissionsService(expected: []),
            postcodeService: MockedPostcodeService(expected: [])
        )
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: services)
        
        let sut = makeSUT(
            container: container,
            profile: MemberProfile.mockedDataMobileNotVerified
        )
        
        let cancelbag = CancelBag()
        var requestingVerifyCodeWasTrue = false
    
        sut.$requestingVerifyCode
            .receive(on: RunLoop.main)
            .sink { requestingVerifyCode in
                if requestingVerifyCode {
                    requestingVerifyCodeWasTrue = true
                }
            }
            .store(in: cancelbag)
        
        await sut.verifyAccountTapped()

        sut.container.services.verify(as: .member)
        XCTAssertTrue(requestingVerifyCodeWasTrue)
        XCTAssertFalse(sut.requestingVerifyCode)
        XCTAssertTrue(sut.container.appState.value.routing.showVerifyMobileView)
        XCTAssertNil(sut.container.appState.value.latestError)
    }
    
    func test_whenVerifyAccountTappedAndOpenViewResultFalse_thenSetRoutingShowVerifyMobileViewToFalse() async {
        
        var memberService = MockedUserService(expected: [.requestMobileVerificationCode])
        memberService.requestMobileVerificationCodeResponse = .success(false)
        
        let services = DIContainer.Services(
            businessProfileService: MockedBusinessProfileService(expected: []),
            retailStoreService: MockedRetailStoreService(expected: []),
            retailStoreMenuService: MockedRetailStoreMenuService(expected: []),
            basketService: MockedBasketService(expected: []),
            memberService: memberService,
            checkoutService: MockedCheckoutService(expected: []),
            addressService: MockedAddressService(expected: []),
            utilityService: MockedUtilityService(expected: []),
            imageService: MockedAsyncImageService(expected: []),
            notificationService: MockedNotificationService(expected: []),
            userPermissionsService: MockedUserPermissionsService(expected: []),
            postcodeService: MockedPostcodeService(expected: [])
        )
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: services)
        
        let sut = makeSUT(
            container: container,
            profile: MemberProfile.mockedDataMobileNotVerified
        )
        
        let cancelbag = CancelBag()
        var requestingVerifyCodeWasTrue = false
    
        sut.$requestingVerifyCode
            .receive(on: RunLoop.main)
            .sink { requestingVerifyCode in
                if requestingVerifyCode {
                    requestingVerifyCodeWasTrue = true
                }
            }
            .store(in: cancelbag)
        
        await sut.verifyAccountTapped()

        sut.container.services.verify(as: .member)
        XCTAssertTrue(requestingVerifyCodeWasTrue)
        XCTAssertFalse(sut.requestingVerifyCode)
        XCTAssertFalse(sut.container.appState.value.routing.showVerifyMobileView)
        XCTAssertNil(sut.container.appState.value.latestError)
    }
    
    func test_whenVerifyAccountTappedAndOpenViewIsErrorResult_thenSetError() async {
        
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        var memberService = MockedUserService(expected: [.requestMobileVerificationCode])
        memberService.requestMobileVerificationCodeResponse = .failure(networkError)
        
        let services = DIContainer.Services(
            businessProfileService: MockedBusinessProfileService(expected: []),
            retailStoreService: MockedRetailStoreService(expected: []),
            retailStoreMenuService: MockedRetailStoreMenuService(expected: []),
            basketService: MockedBasketService(expected: []),
            memberService: memberService,
            checkoutService: MockedCheckoutService(expected: []),
            addressService: MockedAddressService(expected: []),
            utilityService: MockedUtilityService(expected: []),
            imageService: MockedAsyncImageService(expected: []),
            notificationService: MockedNotificationService(expected: []),
            userPermissionsService: MockedUserPermissionsService(expected: []),
            postcodeService: MockedPostcodeService(expected: [])
        )
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: services)
        
        let sut = makeSUT(
            container: container,
            profile: MemberProfile.mockedDataMobileNotVerified
        )
        
        let cancelbag = CancelBag()
        var requestingVerifyCodeWasTrue = false
    
        sut.$requestingVerifyCode
            .receive(on: RunLoop.main)
            .sink { requestingVerifyCode in
                if requestingVerifyCode {
                    requestingVerifyCodeWasTrue = true
                }
            }
            .store(in: cancelbag)
        
        await sut.verifyAccountTapped()

        sut.container.services.verify(as: .member)
        XCTAssertTrue(requestingVerifyCodeWasTrue)
        XCTAssertFalse(sut.requestingVerifyCode)
        XCTAssertFalse(sut.container.appState.value.routing.showVerifyMobileView)
        XCTAssertEqual(sut.container.appState.value.latestError as? NSError, networkError)
    }
    
    func test_whenLogoutTapped_thenViewStateIsLogoutAndIsLogoutSelectedIsTrue() {
        let sut = makeSUT()

        sut.logOutTapped()
        XCTAssertTrue(sut.isLogOutSelected)
        XCTAssertEqual(sut.viewState, .logOut)
    }
    
    func test_whenMemberLogsOut_thenLogoutIsSuccessful() async {
        let sut = makeSUT()
        
        await sut.logOut()
        
        XCTAssertNil(sut.container.appState.value.userData.memberProfile)
    }
    
    func test_whenOnAppearSendEvenTriggered_thenAppsFlyerEventCalled() {
        let eventLogger = MockedEventLogger(expected: [.sendEvent(for: .viewScreen(.outside, .rootAccount), with: .appsFlyer, params: [:])])
        let container = DIContainer(appState: AppState(), eventLogger: eventLogger, services: .mocked())
        let sut = makeSUT(container: container)
        
        sut.onAppearSendEvent()
        
        eventLogger.verify()
    }
    
    func test_whenOnAppearAddressViewSendEvenTriggered_thenCorrectAppsFlyerEventCalled() {
        let eventLogger = MockedEventLogger(expected: [.sendEvent(for: .viewScreen(.outside, .deliveryAddressList), with: .appsFlyer, params: [:])])
        let container = DIContainer(appState: AppState(), eventLogger: eventLogger, services: .mocked())
        let sut = makeSUT(container: container)
        
        sut.onAppearAddressViewSendEvent()
        
        eventLogger.verify()
    }
    
    func test_whenSettingsTapped_thenShowSettingsIsTrue() {
        let sut = makeSUT()
        sut.settingsTapped()
        XCTAssertTrue(sut.showSettings)
    }
    
    func test_whenSettingsDismissed_thenShowSettingsIsFalse() {
        let sut = makeSUT()
        sut.dismissSettings()
        XCTAssertFalse(sut.showSettings)
    }
    
    func test_resetPasswordDismissed_thenErrorSet() {
        let sut = makeSUT()
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        sut.resetPasswordDismissed(withError: networkError)
        XCTAssertEqual(sut.container.appState.value.latestError as? NSError, networkError)
    }
    
    func test_setupResetPaswordDeepLinkNavigation_givenPasswordResetCode_thenSetResetToken() {
        
        let sut = makeSUT()
        
        let resetToken = "p6rGf6KLBD"
        
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: #function)

        sut.$resetToken
            .filter { $0 != nil }
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.container.appState.value.passwordResetCode = resetToken
        
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(sut.resetToken, MemberDashboardViewModel.ResetToken(id: resetToken))
    }
    
    func test_setupBindToProfile_givenBasketWithValidatedMemberCouponRequirementAndMemberAppStateUpdated_thenTriggerVerify() {
        
        var memberService = MockedUserService(expected: [.requestMobileVerificationCode])
        memberService.requestMobileVerificationCodeResponse = .success(true)
        
        let services = DIContainer.Services(
            businessProfileService: MockedBusinessProfileService(expected: []),
            retailStoreService: MockedRetailStoreService(expected: []),
            retailStoreMenuService: MockedRetailStoreMenuService(expected: []),
            basketService: MockedBasketService(expected: []),
            memberService: memberService,
            checkoutService: MockedCheckoutService(expected: []),
            addressService: MockedAddressService(expected: []),
            utilityService: MockedUtilityService(expected: []),
            imageService: MockedAsyncImageService(expected: []),
            notificationService: MockedNotificationService(expected: []),
            userPermissionsService: MockedUserPermissionsService(expected: []),
            postcodeService: MockedPostcodeService(expected: [])
        )
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: services)
        let sut = makeSUT(container: container)
        sut.container.appState.value.userData.basket = Basket.mockedDataVerifiedMemberRegisteredRequiredCoupon
        
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: #function)

        sut.container.appState
            .map(\.routing.showVerifyMobileView)
            .filter { $0 }
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        XCTAssertFalse(sut.container.appState.value.routing.showVerifyMobileView)
        
        sut.container.appState.value.userData.memberProfile = MemberProfile.mockedDataMobileNotVerified
        
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertTrue(sut.container.appState.value.routing.showVerifyMobileView)
    }
    
    func test_whenShowInitialViewFalseInAppState_thenIsFromInitialViewIsFalse() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.routing.showInitialView = false
        let sut = makeSUT(container: container)
        XCTAssertFalse(sut.isFromInitialView)
    }
    
    func test_whenShowInitialViewTrueInAppState_thenIsFromInitialViewIsTrue() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.routing.showInitialView = true
        let sut = makeSUT(container: container)
        XCTAssertTrue(sut.isFromInitialView)
    }
    
    func test_whenSwitchStateCalled_thenCorrectStateSet() {
        let sut = makeSUT()
        XCTAssertEqual(sut.viewState, .dashboard)
        sut.switchState(to: .orders)
        XCTAssertEqual(sut.viewState, .orders)
    }
    
    func test_whenStateChanged_thenActiveOptionButtonChanged() {
        let sut = makeSUT()
        
        let expectation = expectation(description: "activeButtonSet")
        
        var cancellables = Set<AnyCancellable>()
        
        sut.switchState(to: .orders)

        sut.$activeOptionButton
            .dropFirst()
            .first()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(sut.activeOptionButton, .orders)
    }
    
    func test_whenIsOptionActiveCalled_givenInjectedOptionMatchesViewState_thenReturnTrue() {
        let sut = makeSUT()
        XCTAssertTrue(sut.isOptionActive(.dashboard))
    }
    
    func test_whenIsOptionActiveCalled_givenInjectedOptionDoesNotMatchViewState_thenReturnFalse() {
        let sut = makeSUT()
        XCTAssertFalse(sut.isOptionActive(.orders))
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), profile: MemberProfile? = nil) -> MemberDashboardViewModel {
        
        if let profile = profile {
            container.appState.value.userData.memberProfile = profile
        }
        
        let sut = MemberDashboardViewModel(container: container)

        trackForMemoryLeaks(sut)
        return sut
    }
}
