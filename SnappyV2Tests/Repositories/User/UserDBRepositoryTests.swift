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
        wait(for: [exp], timeout: 0.5)
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
        sut.store(memberProfile: memberFromAPI)
            .sinkToResult { result in
                // need to check all the fields except the timestamp
                // because a few nano seconds make the result incomparable
                // to MemberProfile.mockedData
                switch result {
                case let .success(resultValue):
                    XCTAssertEqual(resultValue.firstName, memberFromAPI.firstName, file: #file, line: #line)
                    XCTAssertEqual(resultValue.lastName, memberFromAPI.lastName, file: #file, line: #line)
                    XCTAssertEqual(resultValue.emailAddress, memberFromAPI.emailAddress, file: #file, line: #line)
                    XCTAssertEqual(resultValue.type, memberFromAPI.type, file: #file, line: #line)
                    XCTAssertNotEqual(resultValue.fetchTimestamp, nil, file: #file, line: #line)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
        
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
        wait(for: [exp], timeout: 0.5)
    }
    
    // MARK: - clearFetchedUserMarketingOptions(isCheckout:notificationsEnabled:basketToken:)
    
    func test_clearFetchedUserMarketingOptions_whenMultipleNotMatching_expectNoDeletions() throws {
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
        
        try mockedStore.preloadData { context in
            marketingOptions.store(in: context)
            marketingOptionsForBasket.store(in: context)
        }
        
        let exp = XCTestExpectation(description: #function)
        sut
            .clearFetchedUserMarketingOptions(
                isCheckout: true,
                notificationsEnabled: true,
                basketToken: nil
            )
            .sinkToResult { result in
                result.assertSuccess(value: true)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_clearFetchedUserMarketingOptions_whenMultipleWithOneMatching_expectOneDeletion() throws {
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
        
        try mockedStore.preloadData { context in
            marketingOptions.store(in: context)
            marketingOptionsForBasket.store(in: context)
        }
        
        let exp = XCTestExpectation(description: #function)
        sut
            .clearFetchedUserMarketingOptions(
                isCheckout: true,
                notificationsEnabled: false,
                basketToken: marketingOptionsForBasket.fetchBasketToken!
            )
            .sinkToResult { result in
                result.assertSuccess(value: true)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
    }
    
    // MARK: - store(marketingOptionsFetch:isCheckout:notificationsEnabled:basketToken:)
    
    func test_storeMarketingOptionsFetch() throws {
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
        
        let exp = XCTestExpectation(description: #function)
        sut
            .store(
                marketingOptionsFetch: marketingOptionsFromAPI,
                isCheckout: marketingOptions.fetchIsCheckout!,
                notificationsEnabled: marketingOptions.fetchNotificationsEnabled!,
                basketToken: marketingOptions.fetchBasketToken!
            )
            .sinkToResult { result in
                // need to check all the fields except the timestamp
                // because a few nano seconds make the result incomparable
                // to marketingOptions.fetchTimestamp
                switch result {
                case let .success(resultValue):
                    XCTAssertEqual(resultValue.marketingPreferencesIntro, marketingOptions.marketingPreferencesIntro, file: #file, line: #line)
                    XCTAssertEqual(resultValue.marketingPreferencesGuestIntro, marketingOptions.marketingPreferencesGuestIntro, file: #file, line: #line)
                    XCTAssertEqual(resultValue.marketingOptions, marketingOptions.marketingOptions, file: #file, line: #line)
                    XCTAssertEqual(resultValue.fetchIsCheckout, marketingOptions.fetchIsCheckout, file: #file, line: #line)
                    XCTAssertEqual(resultValue.fetchNotificationsEnabled, marketingOptions.fetchNotificationsEnabled, file: #file, line: #line)
                    XCTAssertEqual(resultValue.fetchBasketToken, marketingOptions.fetchBasketToken, file: #file, line: #line)
                    XCTAssertNotEqual(resultValue.fetchTimestamp, nil, file: #file, line: #line)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
    }
    
    // MARK: - userMarketingOptionsFetch(isCheckout:notificationsEnabled:basketToken:)
    
    func test_userMarketingOptionsFetch_givenMatchingCriteria_returnResult() throws {
        let marketingOptions = UserMarketingOptionsFetch.mockedDataNotificationDisabled
        let marketingOptionsForBasket = UserMarketingOptionsFetch.mockedDataNotificationDisabledWithBasketToken
        
        mockedStore.actions = .init(expected: [
            .fetch(String(describing: UserMarketingOptionsFetchMO.self), .init(inserted: 0, updated: 0, deleted: 0))
        ])
        
        try mockedStore.preloadData { context in
            marketingOptions.store(in: context)
            marketingOptionsForBasket.store(in: context)
        }
        
        let exp = XCTestExpectation(description: #function)
        sut
            .userMarketingOptionsFetch(
                isCheckout: false,
                notificationsEnabled: true,
                basketToken: marketingOptionsForBasket.fetchBasketToken!
            )
            .sinkToResult { result in
                result.assertSuccess(value: nil)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_userMarketingOptionsFetch_givenCriteriaWithNoMatches_returnNoResult() throws {
        let marketingOptions = UserMarketingOptionsFetch.mockedDataNotificationDisabled
        let marketingOptionsForBasket = UserMarketingOptionsFetch.mockedDataNotificationDisabledWithBasketToken
        
        mockedStore.actions = .init(expected: [
            .fetch(String(describing: UserMarketingOptionsFetchMO.self), .init(inserted: 0, updated: 0, deleted: 0))
        ])
        
        try mockedStore.preloadData { context in
            marketingOptions.store(in: context)
            marketingOptionsForBasket.store(in: context)
        }
        
        let exp = XCTestExpectation(description: #function)
        sut
            .userMarketingOptionsFetch(
                isCheckout: marketingOptionsForBasket.fetchIsCheckout!,
                notificationsEnabled: marketingOptionsForBasket.fetchNotificationsEnabled!,
                basketToken: marketingOptionsForBasket.fetchBasketToken!
            )
            .sinkToResult { result in
                // need to check all the fields except the timestamp
                // because a few nano seconds make the result incomparable
                // to marketingOptions.fetchTimestamp
                switch result {
                case let .success(resultValue):
                    XCTAssertEqual(resultValue?.marketingPreferencesIntro, marketingOptionsForBasket.marketingPreferencesIntro, file: #file, line: #line)
                    XCTAssertEqual(resultValue?.marketingPreferencesGuestIntro, marketingOptionsForBasket.marketingPreferencesGuestIntro, file: #file, line: #line)
                    XCTAssertEqual(resultValue?.marketingOptions, marketingOptionsForBasket.marketingOptions, file: #file, line: #line)
                    XCTAssertEqual(resultValue?.fetchIsCheckout, marketingOptionsForBasket.fetchIsCheckout, file: #file, line: #line)
                    XCTAssertEqual(resultValue?.fetchNotificationsEnabled, marketingOptionsForBasket.fetchNotificationsEnabled, file: #file, line: #line)
                    XCTAssertEqual(resultValue?.fetchBasketToken, marketingOptionsForBasket.fetchBasketToken, file: #file, line: #line)
                    XCTAssertNotEqual(resultValue?.fetchTimestamp, nil, file: #file, line: #line)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
    }
    
}
