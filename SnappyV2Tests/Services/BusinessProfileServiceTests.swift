//
//  BusinessProfileServiceTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 02/03/2022.
//

import XCTest
import Combine
import KeychainAccess

@testable import SnappyV2

class BusinessProfileServiceTests: XCTestCase {
    
    var appState = CurrentValueSubject<AppState, Never>(AppState())
    var mockedEventLogger: MockedEventLogger!
    var mockedWebRepo: MockedBusinessProfileWebRepository!
    var mockedDBRepo: MockedBusinessProfileDBRepository!
    var mockedDCDeviceChecker: MockedDCDeviceChecker!
    var subscriptions = Set<AnyCancellable>()
    var sut: BusinessProfileService!
    let keychain = Keychain(service: Bundle.main.bundleIdentifier!)

    override func setUp() {
        mockedWebRepo = MockedBusinessProfileWebRepository()
        mockedEventLogger = MockedEventLogger()
        mockedDBRepo = MockedBusinessProfileDBRepository()
        mockedDCDeviceChecker = MockedDCDeviceChecker()
        sut = BusinessProfileService(
            webRepository: mockedWebRepo,
            dbRepository: mockedDBRepo,
            appState: appState,
            eventLogger: mockedEventLogger,
            deviceChecker: mockedDCDeviceChecker
        )
        // keychain cleared here as well as tearDown because individual menual
        // tests will not always call teardown between tests.
        keychain[AppV2Constants.Business.orderPlacedPreviouslyKey] = nil
    }
    
    func delay(_ closure: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: closure)
    }

    override func tearDown() {
        appState = CurrentValueSubject<AppState, Never>(AppState())
        subscriptions = Set<AnyCancellable>()
        mockedEventLogger = nil
        mockedWebRepo = nil
        mockedDBRepo = nil
        mockedDCDeviceChecker = nil
        sut = nil
        keychain[AppV2Constants.Business.orderPlacedPreviouslyKey] = nil
    }
}

// MARK: - func getProfile()
final class GetBusinessProfileTests: BusinessProfileServiceTests {
    
    func test_successfulGetProfile_whenWebResultAndOrderPlacedPreviouslyKeyChainNotSetAndNoDeviceCheckerToken_returnWebResult() async {
        let profile = BusinessProfile.mockedDataFromAPI
        
        // Configuring expected actions on repositories

        mockedDCDeviceChecker.actions = .init(expected: [
            .getAppleDeviceToken
        ])
        mockedWebRepo.actions = .init(expected: [
            .getProfile
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearBusinessProfile(forLocaleCode: AppV2Constants.Client.languageCode),
            .store(businessProfile: profile, forLocaleCode: AppV2Constants.Client.languageCode)
        ])

        // Configuring responses from repositories

        mockedWebRepo.getProfileResponse = .success(profile)
        mockedDBRepo.clearBusinessProfileResult = .success(true)
        mockedDBRepo.storeBusinessProfileResult = .success(profile)
        
        XCTAssertTrue(appState.value.userData.isFirstOrder, file: #file, line: #line)
        
        do {
            try await sut.getProfile()
            XCTAssertEqual(appState.value.businessData.businessProfile, profile, file: #file, line: #line)
            XCTAssertTrue(appState.value.userData.isFirstOrder, file: #file, line: #line)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
            mockedDCDeviceChecker.verify()
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }
    
    func test_successfulGetProfile_whenWebResultAndOrderPlacedPreviouslyKeyChainSetAndNoDeviceCheckerToken_returnWebResultAndUpdateFirstOrderState() async {
        let profile = BusinessProfile.mockedDataFromAPI
        
        // Configuring previous states
        
        keychain[AppV2Constants.Business.orderPlacedPreviouslyKey] = AppV2Constants.Business.keychainTrueValue
        
        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [
            .getProfile
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearBusinessProfile(forLocaleCode: AppV2Constants.Client.languageCode),
            .store(businessProfile: profile, forLocaleCode: AppV2Constants.Client.languageCode)
        ])

        // Configuring responses from repositories

        mockedWebRepo.getProfileResponse = .success(profile)
        mockedDBRepo.clearBusinessProfileResult = .success(true)
        mockedDBRepo.storeBusinessProfileResult = .success(profile)
        
        XCTAssertTrue(appState.value.userData.isFirstOrder, file: #file, line: #line)
        
        do {
            try await sut.getProfile()
            XCTAssertEqual(appState.value.businessData.businessProfile, profile, file: #file, line: #line)
            XCTAssertFalse(appState.value.userData.isFirstOrder, file: #file, line: #line)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
            mockedDCDeviceChecker.verify()
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }
    
    func test_successfulGetProfile_whenWebResultAndOrderPlacedPreviouslyKeyChainNotSetAndDeviceCheckerTokenWithDeviceStateSet_returnWebResultAndUpdateFirstOrderState() async {
        let profile = BusinessProfile.mockedDataFromAPI
        let usedDeviceState = CheckPreviousOrderedDeviceStateResult.mockedDeviceUsedToPlaceOrder
        let deviceCheckToken = "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"
        
        // Configuring expected actions on repositories

        mockedDCDeviceChecker.actions = .init(expected: [
            .getAppleDeviceToken
        ])
        mockedWebRepo.actions = .init(expected: [
            .getProfile,
            .checkPreviousOrderedDeviceState(deviceCheckToken: deviceCheckToken)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearBusinessProfile(forLocaleCode: AppV2Constants.Client.languageCode),
            .store(businessProfile: profile, forLocaleCode: AppV2Constants.Client.languageCode)
        ])

        // Configuring responses from repositories

        mockedWebRepo.getProfileResponse = .success(profile)
        mockedWebRepo.checkPreviousOrderedDeviceStateResponse = .success(usedDeviceState)
        mockedDBRepo.clearBusinessProfileResult = .success(true)
        mockedDBRepo.storeBusinessProfileResult = .success(profile)
        mockedDCDeviceChecker.appleDeviceTokenResult = deviceCheckToken
        
        XCTAssertTrue(appState.value.userData.isFirstOrder, file: #file, line: #line)
        
        do {
            try await sut.getProfile()
            XCTAssertEqual(appState.value.businessData.businessProfile, profile, file: #file, line: #line)
            XCTAssertFalse(appState.value.userData.isFirstOrder, file: #file, line: #line)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
            mockedDCDeviceChecker.verify()
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }
    
    func test_successfulGetProfile_whenWebResultAndOrderPlacedPreviouslyKeyChainNotSetAndDeviceCheckerTokenWithDeviceStateNotSet_returnWebResultWithoutUpdatingFirstOrderState() async {
        let profile = BusinessProfile.mockedDataFromAPI
        let unusedDeviceState = CheckPreviousOrderedDeviceStateResult.mockedDeviceNotUsedToPlaceOrder
        let deviceCheckToken = "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"
        
        // Configuring expected actions on repositories

        mockedDCDeviceChecker.actions = .init(expected: [
            .getAppleDeviceToken
        ])
        mockedWebRepo.actions = .init(expected: [
            .getProfile,
            .checkPreviousOrderedDeviceState(deviceCheckToken: deviceCheckToken)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearBusinessProfile(forLocaleCode: AppV2Constants.Client.languageCode),
            .store(businessProfile: profile, forLocaleCode: AppV2Constants.Client.languageCode)
        ])

        // Configuring responses from repositories

        mockedWebRepo.getProfileResponse = .success(profile)
        mockedWebRepo.checkPreviousOrderedDeviceStateResponse = .success(unusedDeviceState)
        mockedDBRepo.clearBusinessProfileResult = .success(true)
        mockedDBRepo.storeBusinessProfileResult = .success(profile)
        mockedDCDeviceChecker.appleDeviceTokenResult = deviceCheckToken
        
        XCTAssertTrue(appState.value.userData.isFirstOrder, file: #file, line: #line)
        
        do {
            try await sut.getProfile()
            XCTAssertEqual(appState.value.businessData.businessProfile, profile, file: #file, line: #line)
            XCTAssertTrue(appState.value.userData.isFirstOrder, file: #file, line: #line)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
            mockedDCDeviceChecker.verify()
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }
    
    func test_successfulGetProfile_whenWebResultAndOrderPlacedPreviouslyKeyChainNotSetAndDeviceCheckerTokenWithDeviceStateFetchFails_returnWebResultWithoutUpdatingFirstOrderState() async {
        let profile = BusinessProfile.mockedDataFromAPI
        let deviceStateError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        let deviceCheckToken = "AgAAACuAwzNpdWMZ2a4eAGxtoDkEUNk0+me89vLfv5ZingpyOOkgXXXyjPzYTzWmWSu+BYqcD47byirLZ++3dJccpF99hWppT7G5xAuU+y56WpSYsAQXc3tNIzYT2zgD9X8N/GfqThezzg9WN/AilM4AaHDnKWYrZ9C/Bhi76ztY/oFBgHuDvQB9FoVT7aSAMdQS7AsDVwgAADVoUEfMo6DeCOLWQsiWPL8tCdz3CSiW3NJzlvedft2yzr3sr3+DL+D7S3tQp2KjOXR5LAFE8mZqKKTi+iuoDw1obkbZWoY8GGHKdD3Hb3dLWbjdoCMh/ChnRPSRxQkoWXQjTc98OnVnuUkySuGw3BnqwziaDtybGSYdvgT1Oe7EX1zGWQhj6/Lt4Wkk1N6wy5wRhiQaOImeBxNV5ijdKdWYn4MIs80HeW0MAmsKWH+FMiMBO6WLwoI/hkpFVZ/RvRzTADf+/ndBWqpjkDI0oPEchxGMAg8V6+9TFpfFsW71CZcKO1D4UvUW6GbZJVvjtpIvZp6eo/m+YXv84Jb48W5qDqpGCS3K1AdygPDA5+z/GcQZWXXS0nWEw/EKLbIFGV3xfns06p3ib5WTFDCjqe+667TbiULRkntQ4xVR8RGG3hRNMOoZF6W+kTjOUUDmEBBAKzHDHjzELcJFUBRtuuVpuv0wz/V1Q+rKJ7nv3bmqsp+2SZMNvruc5jUgPGzQOiF9zoty1hyXuPB6Cx4ybhWxMtPRQw+RWJg6SKSXHf1Nt3bjUmpAhEa0M8TsbGD6A/usDzGahc6gi4cu2K0Jx8t4tSI+Pdc25ddaeAC8GsV+X/xviewZda7gV1bTPO1oW8z5ZZkMBKr9aW+ZYjBk2llIcV7p+1pCpvFbe1N7ErES9HImWOAIQHo+FLyzY2sZAYHrGaKLqa6TfPbu4vEVOJp+5r2dX6p0cH6r2r0rA7M95BN4BQbffAMqjmQ3aiVQMq75EO1ork3pKIK4bwb9lIxzNcH7nmYtp4xiAgryBbPcjsk45U+Ft6HL//0w/iePXUaET4zJmhkF5fdriAUeLKWDwRtSY6QRxqAXrT+HPY47nuKNya6icP44sX+zJ5pKjdP+kTRYMDDbroi7fWlPkAF34SIMDjsEivIcFzCm+QnnBQaOFsDcXfw8gQW9jN8/UFzkyHAsMxiRBxLFE8jxveJx73LYKSqqNYxvCvCkwdIIszojDzywJRUmaqXNYvqLKu8wmJmOq4S4rDmmR9yjSY48P7Wx8jznZYiGnvqHM3Izn8CGL6Q/2P69e6xYQNK66H+Z6A281xcaWZWO+foCcJhZaututkkzWLWmC3yZ3SECr4K7FPWfYArbKQBnJkKaddWSGs/WV3OkJMi3sVq86Tb781DymY5T2vldr4eKMkN0MXhYes1YIKLaJB3XDk7oR4l+ctC8kJbQ6Vs0XfQ7z3PwUkoDNeiOQqLjb9qde6iQHHNafgu5DxGLxitBKALNJDfcEHeEKWHqizR7IkjhjuKxC/26+zty3LH5koPpkBuaXobPn0K+h/dE/jkfWLlDmTKsP34INJFJfIGiojmYyHZErTGt31jXjTv3P3g/HmM2wEJAMAelGUEOijiMYCkhjyafEEJ+28LU8q39H4XoDTFi7XAsenYG/s9K3h/5dCqxbOS+SE9xb5wnAYxKvBr2P/Y9aXp6ETvPu00Pb72d7Z8BuTow3LbqDDMAqQmGf3Wfq0M4ebYKgMpaxSVvZZ1bFG6WxTzM1Ue0hiLQAXtqJPiLYvpxv/9YdSGFzU8Cwek3PdbhJ0AU1JOnEG6WTyDBJQYTlgAVl3iPbb6m+uikLWu12XpYWNzZgVr5TqeS8FYq3saBB9Lf4VBc/jCQzeAsWkHXsIrDJSDUmWdXMAmvOUgXBhOMfzeXiFLmqwsgc6H8/9jt0dz8SLlgW7n0te5bm6h4lC/+UNMOu/uRw6fBQS8pCbBGpf7Hvuk4bxhOrHEEMEA2gorS8ZUI3tkmbZJs5GEHejdn8OiN7n+iOQjHsJH+x4quu7cPNymsy5yb+WyF8tSr7sPl8j9nN0lSpKm9MKDa9UM6oKWrxcz15drOfL46cOQUvKyEdJiKb1jzWQrvf2XLgIo7ztCjO6Bat9b8KuYWIIpPIJ1SQWBBE5+LDB6e5GECFcl9JKVJa+GFvv1Ynml82nyXDt5FtVMdlyPe+6BgeDpKuBn09EfNsm5PXYvQANpLofHvmmP+QXuSQ2lHzCMqVj7MBiVsyPMz4A4Ysl/EUkV7xHt1SQ5r6oyXW5FwtkvMOKNQ1Pya43BroZYHYjwWnRdrItrbJYd1mhull+t8dGeCJqXNIWv2kFS9hghyDQ37QW91XDTafKk8pZ/VUQVYqK89s5WaIeI/S0QOZmKC1lZ3HHnSWZurLBxODW6x1VOKy8QevrPnAcQbJuDnYKnWPsVTypf2njRzqISaMlpyqDbd66dc1RdRQTjBRC8EYlYOx9vPNkHLWxemYkqtP4H2ny2VhXyNbWvMkz1Lr/LuISppV4q6KDVhyvvxiJ1SE/WBp5W7fSUUCtGzmL/ljR0raBYde7nyjkU+IY0cGvfclAcx2uu1Ghg+ZtcKFZ+8DShVgVOiZVR89DTML9+OKdbQaNkYDXWT7s9iFZQjF0ToF0v4wcWmEXF8a9GAXtFDRncVR5azXHcYJzBPs1ba8LYxUl2gMmA/fJLZX0kBYwqCh93d/im59B+5gBKe9tUXSO4kqFLHaNE0oOf29ZbCqNWNAAQksPzn+68ih0H7X4rTJykVIr+yPGbzsWgWXEgrehnZlDIXgARrOEcXZLFadimGDkuQvXQHGECVg+8Bm2fj5kbu1UI2LQcbP6TkkVPcJfQJHSAsqQjVCBNuaus0P6hp74a8OBsLtJ4c+1+5gomh8v+1fcOHVb9XqoyLDknC78cRm5JV1/bXJsbHcbFa9KdGZzWMZNwfYxx1+0r1K75i4oS4El+iLJ1UVSXXT1lJbim0oeMmHlcX1q9NYGUxCHJXvCnBrGa+EV/966JgU53x9MlfmTojOpmEeKjLfdwmWQ6B3hV2"
        
        // Configuring expected actions on repositories

        mockedDCDeviceChecker.actions = .init(expected: [
            .getAppleDeviceToken
        ])
        mockedWebRepo.actions = .init(expected: [
            .getProfile,
            .checkPreviousOrderedDeviceState(deviceCheckToken: deviceCheckToken)
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearBusinessProfile(forLocaleCode: AppV2Constants.Client.languageCode),
            .store(businessProfile: profile, forLocaleCode: AppV2Constants.Client.languageCode)
        ])

        // Configuring responses from repositories

        mockedWebRepo.getProfileResponse = .success(profile)
        mockedWebRepo.checkPreviousOrderedDeviceStateResponse = .failure(deviceStateError)
        mockedDBRepo.clearBusinessProfileResult = .success(true)
        mockedDBRepo.storeBusinessProfileResult = .success(profile)
        mockedDCDeviceChecker.appleDeviceTokenResult = deviceCheckToken
        
        XCTAssertTrue(appState.value.userData.isFirstOrder, file: #file, line: #line)
        
        do {
            try await sut.getProfile()
            XCTAssertEqual(appState.value.businessData.businessProfile, profile, file: #file, line: #line)
            XCTAssertTrue(appState.value.userData.isFirstOrder, file: #file, line: #line)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
            mockedDCDeviceChecker.verify()
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }
    
    func test_successfulGetProfile_whenWebResultAndNoDeviceCheckerToken_returnWebResult() async {
        let profile = BusinessProfile.mockedDataFromAPI
        
        // Configuring expected actions on repositories

        mockedDCDeviceChecker.actions = .init(expected: [
            .getAppleDeviceToken
        ])
        mockedWebRepo.actions = .init(expected: [
            .getProfile
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearBusinessProfile(forLocaleCode: AppV2Constants.Client.languageCode),
            .store(businessProfile: profile, forLocaleCode: AppV2Constants.Client.languageCode)
        ])

        // Configuring responses from repositories

        mockedWebRepo.getProfileResponse = .success(profile)
        mockedDBRepo.clearBusinessProfileResult = .success(true)
        mockedDBRepo.storeBusinessProfileResult = .success(profile)
        
        do {
            try await sut.getProfile()
            XCTAssertEqual(appState.value.businessData.businessProfile, profile, file: #file, line: #line)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
            mockedDCDeviceChecker.verify()
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }
    
    func test_successfulGetProfile_whenWebErrorAndInDB_returnDBResult() async {
        
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        let profile = BusinessProfile.mockedDataFromAPI
        let profileWithLocaleCodeAndNowTimestamp = BusinessProfile(
            id: profile.id,
            checkoutTimeoutSeconds: profile.checkoutTimeoutSeconds,
            minOrdersForAppReview: profile.minOrdersForAppReview,
            privacyPolicyLink: profile.privacyPolicyLink,
            pusherClusterServer: profile.pusherClusterServer,
            pusherAppKey: profile.pusherAppKey,
            mentionMeEnabled: profile.mentionMeEnabled,
            iterableMobileApiKey: profile.iterableMobileApiKey,
            useDeliveryFirms: profile.useDeliveryFirms,
            driverTipIncrement: profile.driverTipIncrement,
            tipLimitLevels: profile.tipLimitLevels,
            facebook: profile.facebook,
            tikTok: profile.tikTok,
            paymentGateways: profile.paymentGateways,
            postcodeRules: PostcodeRule.mockedDataArray,
            marketingText: nil,
            fetchLocaleCode: AppV2Constants.Client.languageCode,
            fetchTimestamp: Date(),
            colors: nil,
            orderingClientUpdateRequirements: [.mockedDataIOS]
        )
        
        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [
            .getProfile
        ])
        mockedDBRepo.actions = .init(expected: [
            .businessProfile(forLocaleCode: AppV2Constants.Client.languageCode)
        ])

        // Configuring responses from repositories

        mockedWebRepo.getProfileResponse = .failure(networkError)
        mockedDBRepo.businessProfileResult = .success(profileWithLocaleCodeAndNowTimestamp)
        
        do {
            try await sut.getProfile()
            XCTAssertNotNil(appState.value.businessData.businessProfile, file: #file, line: #line)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }
    
    func test_unsuccessfulGetProfile_whenWebErrorAndNotInDB_returnWebError() async {
        
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [
            .getProfile
        ])
        mockedDBRepo.actions = .init(expected: [
            .businessProfile(forLocaleCode: AppV2Constants.Client.languageCode)
        ])

        // Configuring responses from repositories

        mockedWebRepo.getProfileResponse = .failure(networkError)
        mockedDBRepo.businessProfileResult = .success(nil)
        
        do {
            try await sut.getProfile()
            XCTFail("Unexpected success", file: #file, line: #line)
        } catch {
            XCTAssertEqual(error as NSError, networkError, file: #file, line: #line)
            XCTAssertNil(appState.value.businessData.businessProfile, file: #file, line: #line)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
        }
    }
    
    func test_unsuccessfulGetProfile_whenWebErrorAndDBExpired_returnError() async {
        
        let expiredDate = Calendar.current.date(byAdding: .hour, value: -12, to: AppV2Constants.Business.businessProfileCachedExpiry)
        
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        let profile = BusinessProfile.mockedDataFromAPI
        let profileWithLocaleCodeAndNowTimestamp = BusinessProfile(
            id: profile.id,
            checkoutTimeoutSeconds: profile.checkoutTimeoutSeconds,
            minOrdersForAppReview: profile.minOrdersForAppReview,
            privacyPolicyLink: profile.privacyPolicyLink,
            pusherClusterServer: profile.pusherClusterServer,
            pusherAppKey: profile.pusherAppKey,
            mentionMeEnabled: profile.mentionMeEnabled,
            iterableMobileApiKey: profile.iterableMobileApiKey,
            useDeliveryFirms: profile.useDeliveryFirms,
            driverTipIncrement: profile.driverTipIncrement,
            tipLimitLevels: profile.tipLimitLevels,
            facebook: profile.facebook,
            tikTok: profile.tikTok,
            paymentGateways: profile.paymentGateways,
            postcodeRules: PostcodeRule.mockedDataArray,
            marketingText: nil,
            fetchLocaleCode: AppV2Constants.Client.languageCode,
            fetchTimestamp: expiredDate,
            colors: nil,
            orderingClientUpdateRequirements: [.mockedDataIOS]
        )
        
        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [
            .getProfile
        ])
        mockedDBRepo.actions = .init(expected: [
            .businessProfile(forLocaleCode: AppV2Constants.Client.languageCode)
        ])

        // Configuring responses from repositories

        mockedWebRepo.getProfileResponse = .failure(networkError)
        mockedDBRepo.businessProfileResult = .success(profileWithLocaleCodeAndNowTimestamp)
        
        do {
            try await sut.getProfile()
            XCTFail("Unexpected success", file: #file, line: #line)
        } catch {
            XCTAssertEqual(error as NSError, networkError, file: #file, line: #line)
            XCTAssertNil(appState.value.businessData.businessProfile, file: #file, line: #line)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
        }
    }
}
