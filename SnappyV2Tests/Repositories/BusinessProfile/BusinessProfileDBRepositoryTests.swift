//
//  BusinessProfileDBRepositoryTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 02/03/2022.
//

import XCTest
@testable import SnappyV2

final class BusinessProfileDBRepositoryTests: XCTestCase {
    
    var mockedStore: MockedPersistentStore!
    var sut: BusinessProfileDBRepository!
    
    override func setUp() {
        mockedStore = MockedPersistentStore()
        sut = BusinessProfileDBRepository(persistentStore: mockedStore)
        mockedStore.verify()
    }
    
    override func tearDown() {
        sut = nil
        mockedStore = nil
    }
    
    // MARK: - businessProfile(forLocaleCode:)
    
    func test_businessProfile_whenDataStored_returnAddresses() async {
        
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
            paymentGateways: profile.paymentGateways,
            marketingText: nil,
            fetchLocaleCode: AppV2Constants.Client.languageCode,
            fetchTimestamp: nil,
            colors: nil
        )
        
        mockedStore.actions = .init(expected: [
            .fetch(String(describing: BusinessProfileMO.self), .init(inserted: 0, updated: 0, deleted: 0))
        ])

        do {
            try await mockedStore.preloadData { context in
                // this will also set the timestamp
                profileWithLocaleCode.store(in: context)
            }
            
            let result = try await sut.businessProfile(forLocaleCode: AppV2Constants.Client.languageCode)
            XCTAssertNotNil(result?.fetchTimestamp, file: #file, line: #line)
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
                paymentGateways: profileWithLocaleCode.paymentGateways,
                marketingText: nil,
                fetchLocaleCode: profileWithLocaleCode.fetchLocaleCode,
                fetchTimestamp: result?.fetchTimestamp,
                colors: nil
            )
            XCTAssertEqual(result, profileWithTimeStamp, file: #file, line: #line)
            mockedStore.verify()
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }
    
    func test_businessProfile_whenNoDataStored_returnNilResult() async {

        mockedStore.actions = .init(expected: [
            .fetch(String(describing: BusinessProfileMO.self), .init(inserted: 0, updated: 0, deleted: 0))
        ])

        do {
            let result = try await sut.businessProfile(forLocaleCode: AppV2Constants.Client.languageCode)
            XCTAssertNil(result, file: #file, line: #line)
            mockedStore.verify()
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }
    
    // MARK: - clearBusinessProfile(forLocaleCode:)
    
    func test_clearBusinessProfile_whenData_thenDeletion() async {
        
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
            paymentGateways: profile.paymentGateways,
            marketingText: nil,
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

        do {
            try await mockedStore.preloadData { context in
                profileWithLocaleCode.store(in: context)
            }
            
            try await sut.clearBusinessProfile(forLocaleCode: AppV2Constants.Client.languageCode)
            mockedStore.verify()
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }
    
    func test_clearBusinessProfile_whenNoMatchingData_thenNoDeletion() async {
        
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
            paymentGateways: profile.paymentGateways,
            marketingText: nil,
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
        
        do {
            try await mockedStore.preloadData { context in
                profileWithLocaleCode.store(in: context)
            }
            
            try await sut.clearBusinessProfile(forLocaleCode: "IMPOSSIBLE_CODE")
            mockedStore.verify()
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }
    
    // MARK: - store(businessProfile:forLocaleCode:)

    func test_storeBusinessProfileWhenNoBusinessProfileColors() async {
        
        let profile = BusinessProfile.mockedDataFromAPI
        
        mockedStore.actions = .init(expected: [
            .update(.init(
                    inserted: profile.recordsCount,
                    updated: 0,
                    deleted: 0
                )
            )
        ])
        
        do {
            try await sut.store(businessProfile: profile, forLocaleCode: AppV2Constants.Client.languageCode)
            mockedStore.verify()
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }
    
    func test_storeBusinessProfileWhenBusinessProfileColorsPresent() async {
        
        let profile = BusinessProfile.mockedDataFromAPIWithColors
        
        mockedStore.actions = .init(expected: [
            .update(.init(
                    inserted: profile.recordsCount,
                    updated: 0,
                    deleted: 0
                )
            )
        ])
        
        // the only difference between this and test_storeBusinessProfileWhenNoBusinessProfileColors will be
        // recordsCount because of the colours since the async changes which no longer need to return the
        // store result
        do {
            try await sut.store(businessProfile: profile, forLocaleCode: AppV2Constants.Client.languageCode)
            mockedStore.verify()
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
    }
}
