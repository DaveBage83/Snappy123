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
    
    func test_successfulGetProfile_whenWebResult_returnWebResult() {
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
        
        let exp = XCTestExpectation(description: #function)
        sut
            .getProfile()
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTAssertEqual(self.appState.value.businessData.businessProfile, profile, file: #file, line: #line)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 2)
    }
    
    func test_successfulGetProfile_whenWebErrorAndInDB_returnDBResult() {
        
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
            fetchLocaleCode: AppV2Constants.Client.languageCode,
            fetchTimestamp: Date(),
            colors: nil,
            marketingText: nil
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
        
        let exp = XCTestExpectation(description: #function)
        sut
            .getProfile()
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTAssertEqual(self.appState.value.businessData.businessProfile, profileWithLocaleCodeAndNowTimestamp, file: #file, line: #line)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 2)
    }
    
    func test_unsuccessfulGetProfile_whenWebErrorAndNotInDB_returnWebError() {
        
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
        
        let exp = XCTestExpectation(description: #function)
        sut
            .getProfile()
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTFail("Unexpected success", file: #file, line: #line)
                case let .failure(error):
                    XCTAssertEqual(error as NSError, networkError, file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 2)
    }
    
    func test_unsuccessfulGetProfile_whenWebErrorAndDBExpired_returnError() {
        
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
            fetchLocaleCode: AppV2Constants.Client.languageCode,
            fetchTimestamp: expiredDate,
            colors: nil,
            marketingText: nil
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
        
        let exp = XCTestExpectation(description: #function)
        sut
            .getProfile()
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    XCTFail("Unexpected success", file: #file, line: #line)
                case let .failure(error):
                    XCTAssertEqual(error as NSError, networkError, file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 2)
    }
}
