//
//  BusinessProfileServiceTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 02/03/2022.
//

import XCTest
import Combine
@testable import SnappyV2

class BusinessProfileServiceTests: XCTestCase {
    
    var appState = CurrentValueSubject<AppState, Never>(AppState())
    var mockedEventLogger: MockedEventLogger!
    var mockedWebRepo: MockedBusinessProfileWebRepository!
    var mockedDBRepo: MockedBusinessProfileDBRepository!
    var subscriptions = Set<AnyCancellable>()
    var sut: BusinessProfileService!

    override func setUp() {
        mockedWebRepo = MockedBusinessProfileWebRepository()
        mockedEventLogger = MockedEventLogger()
        mockedDBRepo = MockedBusinessProfileDBRepository()
        sut = BusinessProfileService(
            webRepository: mockedWebRepo,
            dbRepository: mockedDBRepo,
            appState: appState,
            eventLogger: mockedEventLogger
        )
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
        sut = nil
    }
}

// MARK: - func getProfile()
final class GetBusinessProfileTests: BusinessProfileServiceTests {
    
    func test_successfulGetProfile_whenWebResult_returnWebResult() async {
        let profile = BusinessProfile.mockedDataFromAPI
        
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
        
        do {
            try await sut.getProfile()
            XCTAssertEqual(appState.value.businessData.businessProfile, profile, file: #file, line: #line)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
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
