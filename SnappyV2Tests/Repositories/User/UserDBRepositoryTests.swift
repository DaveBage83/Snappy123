//
//  UserDBRepositoryTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 10/02/2022.
//

import XCTest
import Combine
@testable import SnappyV2

class UserDBRepositoryTests: XCTestCase {
    
    var mockedStore: MockedPersistentStore!
    var sut: UserDBRepository!
    var cancelBag = CancelBag()
    
    override func setUp() {
        mockedStore = MockedPersistentStore()
        sut = UserDBRepository(persistentStore: mockedStore)
        mockedStore.verify()
    }
    
    override func tearDown() {
        cancelBag = CancelBag()
        sut = nil
        mockedStore = nil
    }
    
}

// MARK: - Methods in UserDBRepositoryProtocol

final class UserDBRepositoryProtocolTests: UserDBRepositoryTests {
    
    // MARK: - clearBasket()
    
    func test_clearBasket() throws {
        let member = MemberProfile.mockedData
        
        mockedStore.actions = .init(expected: [
            .update(
                .init(
                    inserted: 0,
                    updated: 0,
                    // not member.recordsCount because of cascade deletion
                    deleted: 1
                )
            )
        ])
        
        try mockedStore.preloadData { context in
            member.store(in: context)
        }
        
        let exp = XCTestExpectation(description: #function)
        sut.clearMemberProfile()
            .sinkToResult { result in
                result.assertSuccess(value: true)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 2.0)
    }
    
    // MARK: - store(memberProfile:)
    
    func test_storeMemberProfile() throws {
        
        let memberFromAPI = MemberProfile.mockedDataFromAPI
        
        mockedStore.actions = .init(expected: [
            .update(.init(
                inserted: memberFromAPI.recordsCount,
                updated: 0,
                deleted: 0)
            )
        ])
        
        let exp = XCTestExpectation(description: #function)
        sut.store(memberProfile: memberFromAPI, forStoreId: nil)
            .sinkToResult { result in
                // need to check all the fields except the timestamp
                // because a few nano seconds make the result incomparable
                // to MemberProfile.mockedData
                switch result {
                case let .success(resultValue):
                    XCTAssertEqual(resultValue.firstname, memberFromAPI.firstname, file: #file, line: #line)
                    XCTAssertEqual(resultValue.lastname, memberFromAPI.lastname, file: #file, line: #line)
                    XCTAssertEqual(resultValue.emailAddress, memberFromAPI.emailAddress, file: #file, line: #line)
                    XCTAssertEqual(resultValue.type, memberFromAPI.type, file: #file, line: #line)
                    XCTAssertEqual(resultValue.referFriendBalance, memberFromAPI.referFriendBalance, file: #file, line: #line)
                    XCTAssertEqual(resultValue.numberOfReferrals, memberFromAPI.numberOfReferrals, file: #file, line: #line)
                    XCTAssertEqual(resultValue.mobileContactNumber, memberFromAPI.mobileContactNumber, file: #file, line: #line)
                    XCTAssertEqual(resultValue.mobileValidated, memberFromAPI.mobileValidated, file: #file, line: #line)
                    XCTAssertEqual(resultValue.acceptedMarketing, memberFromAPI.acceptedMarketing, file: #file, line: #line)
                    XCTAssertEqual(resultValue.defaultBillingDetails, memberFromAPI.defaultBillingDetails, file: #file, line: #line)
                    XCTAssertEqual(resultValue.savedAddresses, memberFromAPI.savedAddresses, file: #file, line: #line)
                    XCTAssertNotEqual(resultValue.fetchTimestamp, nil, file: #file, line: #line)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 2.0)
        
    }
    
    // MARK: - clearAllFetchedUserMarketingOptions()
    
    func test_clearAllFetchedUserMarketingOptions_givenMultipleFetches() throws {
        
        let marketingOptions = UserMarketingOptionsFetch.mockedDataNotificationDisabled
        let marketingOptionsForBasket = UserMarketingOptionsFetch.mockedDataNotificationDisabledWithBasketToken
        
        mockedStore.actions = .init(expected: [
            .update(
                .init(
                    inserted: 0,
                    updated: 0,
                    // not marketingOptions.recordsCount + marketingOptionsForBasket.recordsCount
                    // because of cascade deletion
                    deleted: 2
                )
            )
        ])
        
        try mockedStore.preloadData { context in
            marketingOptions.store(in: context)
            marketingOptionsForBasket.store(in: context)
        }
        
        let exp = XCTestExpectation(description: #function)
        sut.clearAllFetchedUserMarketingOptions()
            .sinkToResult { result in
                result.assertSuccess(value: true)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 2.0)
    }
    
    // MARK: - clearFetchedUserMarketingOptions(isCheckout:notificationsEnabled:basketToken:)
    
    func test_clearFetchedUserMarketingOptions_whenMultipleNotMatching_expectNoDeletions() async throws {
        let marketingOptions = UserMarketingOptionsFetch.mockedDataNotificationDisabled
        let marketingOptionsForBasket = UserMarketingOptionsFetch.mockedDataNotificationDisabledWithBasketToken

        mockedStore.actions = .init(expected: [
            .update(
                .init(
                    inserted: 0,
                    updated: 0,
                    // not marketingOptions.recordsCount + marketingOptionsForBasket.recordsCount
                    // because of cascade deletion
                    deleted: 0
                )
            )
        ])

        try await mockedStore.preloadData { context in
            marketingOptions.store(in: context)
            marketingOptionsForBasket.store(in: context)
        }
        
        let result = try await sut
            .clearFetchedUserMarketingOptions(
                isCheckout: true,
                notificationsEnabled: true,
                basketToken: nil
            )
        
        XCTAssertTrue(result, file: #file, line: #line)
        self.mockedStore.verify()

    }
    
    func test_clearFetchedUserMarketingOptions_whenMultipleWithOneMatching_expectOneDeletion() async throws {
        let marketingOptions = UserMarketingOptionsFetch.mockedDataNotificationDisabled
        let marketingOptionsForBasket = UserMarketingOptionsFetch.mockedDataNotificationDisabledWithBasketToken

        mockedStore.actions = .init(expected: [
            .update(
                .init(
                    inserted: 0,
                    updated: 0,
                    // not marketingOptions.recordsCount + marketingOptionsForBasket.recordsCount
                    // because of cascade deletion
                    deleted: 1
                )
            )
        ])

        try await mockedStore.preloadData { context in
            marketingOptions.store(in: context)
            marketingOptionsForBasket.store(in: context)
        }

        let result = try await sut
            .clearFetchedUserMarketingOptions(
                isCheckout: true,
                notificationsEnabled: false,
                basketToken: marketingOptionsForBasket.fetchBasketToken!
            )
        
        XCTAssertTrue(result, file: #file, line: #line)
        self.mockedStore.verify()
    }
    
    // MARK: - store(marketingOptionsFetch:isCheckout:notificationsEnabled:basketToken:)
    
    func test_storeMarketingOptionsFetch() async throws {
        let marketingOptionsFromAPI = UserMarketingOptionsFetch.mockedDataFromAPI
        let marketingOptions = UserMarketingOptionsFetch.mockedDataNotificationDisabledWithBasketToken

        mockedStore.actions = .init(expected: [
            .update(
                .init(
                    inserted: marketingOptions.recordsCount,
                    updated: 0,
                    deleted: 0
                )
            )
        ])
        
        let result = try await sut
            .store(
                marketingOptionsFetch: marketingOptionsFromAPI,
                isCheckout: marketingOptions.fetchIsCheckout!,
                notificationsEnabled: marketingOptions.fetchNotificationsEnabled!,
                basketToken: marketingOptions.fetchBasketToken!
            )
        
        XCTAssertEqual(result.marketingPreferencesIntro, marketingOptions.marketingPreferencesIntro, file: #file, line: #line)
        XCTAssertEqual(result.marketingPreferencesGuestIntro, marketingOptions.marketingPreferencesGuestIntro, file: #file, line: #line)
        XCTAssertEqual(result.marketingOptions, marketingOptions.marketingOptions, file: #file, line: #line)
        XCTAssertEqual(result.fetchIsCheckout, marketingOptions.fetchIsCheckout, file: #file, line: #line)
        XCTAssertEqual(result.fetchNotificationsEnabled, marketingOptions.fetchNotificationsEnabled, file: #file, line: #line)
        XCTAssertEqual(result.fetchBasketToken, marketingOptions.fetchBasketToken, file: #file, line: #line)
        XCTAssertNotEqual(result.fetchTimestamp, nil, file: #file, line: #line)
        self.mockedStore.verify()
    }
    
    // MARK: - userMarketingOptionsFetch(isCheckout:notificationsEnabled:basketToken:)
    
    func test_userMarketingOptionsFetch_givenMatchingCriteria_returnResult() async throws {
        let marketingOptions = UserMarketingOptionsFetch.mockedDataNotificationDisabled
        let marketingOptionsForBasket = UserMarketingOptionsFetch.mockedDataNotificationDisabledWithBasketToken

        mockedStore.actions = .init(expected: [
            .fetch(String(describing: UserMarketingOptionsFetchMO.self), .init(inserted: 0, updated: 0, deleted: 0))
        ])

        try await mockedStore.preloadData { context in
            marketingOptions.store(in: context)
            marketingOptionsForBasket.store(in: context)
        }
        let result = try await sut
            .userMarketingOptionsFetch(
                isCheckout: false,
                notificationsEnabled: true,
                basketToken: marketingOptionsForBasket.fetchBasketToken!
            )
        
        XCTAssertNil(result, file: #file, line: #line)
        self.mockedStore.verify()
    }

    func test_userMarketingOptionsFetch_givenCriteriaWithNoMatches_returnNoResult() async throws {
        let marketingOptions = UserMarketingOptionsFetch.mockedDataNotificationDisabled
        let marketingOptionsForBasket = UserMarketingOptionsFetch.mockedDataNotificationDisabledWithBasketToken

        mockedStore.actions = .init(expected: [
            .fetch(String(describing: UserMarketingOptionsFetchMO.self), .init(inserted: 0, updated: 0, deleted: 0))
        ])

        try await mockedStore.preloadData { context in
            marketingOptions.store(in: context)
            marketingOptionsForBasket.store(in: context)
        }
        
        let result = try await sut
            .userMarketingOptionsFetch(
                isCheckout: marketingOptionsForBasket.fetchIsCheckout!,
                notificationsEnabled: marketingOptionsForBasket.fetchNotificationsEnabled!,
                basketToken: marketingOptionsForBasket.fetchBasketToken!
            )
        
        XCTAssertEqual(result?.marketingPreferencesIntro, marketingOptionsForBasket.marketingPreferencesIntro, file: #file, line: #line)
        XCTAssertEqual(result?.marketingPreferencesGuestIntro, marketingOptionsForBasket.marketingPreferencesGuestIntro, file: #file, line: #line)
        XCTAssertEqual(result?.marketingOptions, marketingOptionsForBasket.marketingOptions, file: #file, line: #line)
        XCTAssertEqual(result?.fetchIsCheckout, marketingOptionsForBasket.fetchIsCheckout, file: #file, line: #line)
        XCTAssertEqual(result?.fetchNotificationsEnabled, marketingOptionsForBasket.fetchNotificationsEnabled, file: #file, line: #line)
        XCTAssertEqual(result?.fetchBasketToken, marketingOptionsForBasket.fetchBasketToken, file: #file, line: #line)
        XCTAssertNotEqual(result?.fetchTimestamp, nil, file: #file, line: #line)
        self.mockedStore.verify()
    }
    
}
