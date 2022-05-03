//
//  BusinessProfileDBRepositoryTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 02/03/2022.
//

import XCTest
import Combine
@testable import SnappyV2

final class BusinessProfileDBRepositoryTests: XCTestCase {
    
    var mockedStore: MockedPersistentStore!
    var sut: BusinessProfileDBRepository!
    var cancelBag = CancelBag()
    
    override func setUp() {
        mockedStore = MockedPersistentStore()
        sut = BusinessProfileDBRepository(persistentStore: mockedStore)
        mockedStore.verify()
    }
    
    override func tearDown() {
        cancelBag = CancelBag()
        sut = nil
        mockedStore = nil
    }
    
    // MARK: - businessProfile(forLocaleCode:)
    
    func test_businessProfile_whenDataStored_returnAddresses() throws {
        
        let profile = BusinessProfile.mockedDataFromAPI
        let profileWithLocaleCode = BusinessProfile(
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
            fetchLocaleCode: AppV2Constants.Client.languageCode,
            fetchTimestamp: nil,
            colors: nil
        )
        
        mockedStore.actions = .init(expected: [
            .fetch(String(describing: BusinessProfileMO.self), .init(inserted: 0, updated: 0, deleted: 0))
        ])
        
        try mockedStore.preloadData { context in
            // this will also set the timestamp
            profileWithLocaleCode.store(in: context)
        }
        
        let exp = XCTestExpectation(description: #function)
        sut.businessProfile(forLocaleCode: AppV2Constants.Client.languageCode)
            .sinkToResult { result in
                switch result {
                case let .success(resultValue):
                    // fetched result should come back with the expected
                    // data preloaded plus a timestamp
                    XCTAssertNotNil(resultValue?.fetchTimestamp, file: #file, line: #line)
                    let profileWithTimeStamp = BusinessProfile(
                        id: profileWithLocaleCode.id,
                        checkoutTimeoutSeconds: profileWithLocaleCode.checkoutTimeoutSeconds,
                        minOrdersForAppReview: profileWithLocaleCode.minOrdersForAppReview,
                        privacyPolicyLink: profileWithLocaleCode.privacyPolicyLink,
                        pusherClusterServer: profileWithLocaleCode.pusherClusterServer,
                        pusherAppKey: profileWithLocaleCode.pusherAppKey,
                        mentionMeEnabled: profileWithLocaleCode.mentionMeEnabled,
                        iterableMobileApiKey: profileWithLocaleCode.iterableMobileApiKey,
                        useDeliveryFirms: profileWithLocaleCode.useDeliveryFirms,
                        driverTipIncrement: profileWithLocaleCode.driverTipIncrement,
                        tipLimitLevels: profileWithLocaleCode.tipLimitLevels,
                        facebook: profileWithLocaleCode.facebook,
                        tikTok: profileWithLocaleCode.tikTok,
                        fetchLocaleCode: profileWithLocaleCode.fetchLocaleCode,
                        fetchTimestamp: resultValue?.fetchTimestamp,
                        colors: nil
                    )
                    result.assertSuccess(value: profileWithTimeStamp)
                case let .failure(error):
                    XCTFail("Expected success, error: \(error)", file: #file, line: #line)
                }
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_businessProfile_whenNoDataStored_returnNilResult() throws {

        mockedStore.actions = .init(expected: [
            .fetch(String(describing: BusinessProfileMO.self), .init(inserted: 0, updated: 0, deleted: 0))
        ])

        // no preloaded data

        let exp = XCTestExpectation(description: #function)
        sut.businessProfile(forLocaleCode: AppV2Constants.Client.languageCode)
            .sinkToResult { result in
                result.assertSuccess(value: nil)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
    }
    
    // MARK: - clearBusinessProfile(forLocaleCode:)
    
    func test_clearBusinessProfile_whenData_thenDeletion() throws {
        
        let profile = BusinessProfile.mockedDataFromAPI
        let profileWithLocaleCode = BusinessProfile(
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
            fetchLocaleCode: AppV2Constants.Client.languageCode,
            fetchTimestamp: nil,
            colors: nil
        )
        
        mockedStore.actions = .init(expected: [
            .update(
                .init(
                    inserted: 0,
                    updated: 0,
                    // not search.recordsCount because of cascade deletion
                    deleted: 1
                )
            )
        ])
        
        try mockedStore.preloadData { context in
            profileWithLocaleCode.store(in: context)
        }
        
        let exp = XCTestExpectation(description: #function)
        sut.clearBusinessProfile(forLocaleCode: AppV2Constants.Client.languageCode)
            .sinkToResult { result in
                result.assertSuccess(value: true)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_clearBusinessProfile_whenNoMatchingData_thenNoDeletion() throws {
        
        let profile = BusinessProfile.mockedDataFromAPI
        let profileWithLocaleCode = BusinessProfile(
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
            fetchLocaleCode: AppV2Constants.Client.languageCode,
            fetchTimestamp: nil,
            colors: nil
        )
        
        mockedStore.actions = .init(expected: [
            .update(
                .init(
                    inserted: 0,
                    updated: 0,
                    // not search.recordsCount because of cascade deletion
                    deleted: 0
                )
            )
        ])
        
        try mockedStore.preloadData { context in
            profileWithLocaleCode.store(in: context)
        }
        
        let exp = XCTestExpectation(description: #function)
        sut.clearBusinessProfile(forLocaleCode: "IMPOSSIBLE_CODE")
            .sinkToResult { result in
                result.assertSuccess(value: true)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
    }
    
    // MARK: - store(businessProfile:forLocaleCode:)

    func test_storeBusinessProfile() throws {
        
        let profile = BusinessProfile.mockedDataFromAPI
        
        mockedStore.actions = .init(expected: [
            .update(.init(
                    inserted: profile.recordsCount,
                    updated: 0,
                    deleted: 0
                )
            )
        ])
        
        let exp = XCTestExpectation(description: #function)
        sut.store(businessProfile: profile, forLocaleCode: AppV2Constants.Client.languageCode)
            .sinkToResult { result in
                switch result {
                case let .success(resultValue):
                    // fetched result should come back with the expected
                    // data preloaded plus a timestamp
                    XCTAssertNotNil(resultValue.fetchTimestamp, file: #file, line: #line)
                    let profileWithTimeStampAndLocale = BusinessProfile(
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
                        fetchLocaleCode: AppV2Constants.Client.languageCode,
                        fetchTimestamp: resultValue.fetchTimestamp,
                        colors: nil
                    )
                    result.assertSuccess(value: profileWithTimeStampAndLocale)
                case let .failure(error):
                    XCTFail("Expected success, error: \(error)", file: #file, line: #line)
                }
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
    }
    
}
