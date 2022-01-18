//
//  AddressDBRepositoryTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 16/01/2022.
//

import XCTest
import Combine
@testable import SnappyV2

final class AddressDBRepositoryTests: XCTestCase {
    
    var mockedStore: MockedPersistentStore!
    var sut: AddressDBRepository!
    var cancelBag = CancelBag()
    
    override func setUp() {
        mockedStore = MockedPersistentStore()
        sut = AddressDBRepository(persistentStore: mockedStore)
        mockedStore.verify()
    }
    
    override func tearDown() {
        cancelBag = CancelBag()
        sut = nil
        mockedStore = nil
    }

    // MARK: - findAddressesFetch(postcode:countryCode:)
    
    func test_findAddressesFetch_whenDataStored_returnAddresses() throws {
        let search = AddressesSearch.mockedData
        
        mockedStore.actions = .init(expected: [
            .fetch(String(describing: AddressesSearchMO.self), .init(inserted: 0, updated: 0, deleted: 0))
        ])
        
        try mockedStore.preloadData { context in
            // this will also set the timestamp
            search.store(in: context)
        }
        
        let exp = XCTestExpectation(description: #function)
        sut.findAddressesFetch(postcode: search.fetchPostcode, countryCode: search.fetchCountryCode)
            .sinkToResult { result in
                switch result {
                case let .success(resultValue):
                    // fetched result should come back with the expected
                    // data preloaded plus a timestamp
                    XCTAssertNotNil(resultValue?.fetchTimestamp, file: #file, line: #line)
                    let searchWithTimeStamp = AddressesSearch(
                        addresses: search.addresses,
                        fetchPostcode: search.fetchPostcode,
                        fetchCountryCode: search.fetchCountryCode,
                        fetchTimestamp: resultValue?.fetchTimestamp
                    )
                    result.assertSuccess(value: searchWithTimeStamp)
                case let .failure(error):
                    XCTFail("Expected success, error: \(error)", file: #file, line: #line)
                }
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_findAddressesFetch_whenNoDataStored_returnNilResult() throws {
        let search = AddressesSearch.mockedData
        
        mockedStore.actions = .init(expected: [
            .fetch(String(describing: AddressesSearchMO.self), .init(inserted: 0, updated: 0, deleted: 0))
        ])
        
        // no preloaded data
        
        let exp = XCTestExpectation(description: #function)
        sut.findAddressesFetch(postcode: search.fetchPostcode, countryCode: search.fetchCountryCode)
            .sinkToResult { result in
                result.assertSuccess(value: nil)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
    }
    
    // MARK: - clearAddressesFetch(postcode:countryCode:)
    
    func test_clearAddressesFetch() throws {
        let search = AddressesSearch.mockedData
        
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
            search.store(in: context)
        }
        
        let exp = XCTestExpectation(description: #function)
        sut.clearAddressesFetch(postcode: search.fetchPostcode, countryCode: search.fetchCountryCode)
            .sinkToResult { result in
                result.assertSuccess(value: true)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
    }
    
    // MARK: - store(addresses:postcode:countryCode:)
    
    func test_storeForAddress_addressesGiven_storeAndReturnWithAddresses() throws {
        let search = AddressesSearch.mockedData
        
        mockedStore.actions = .init(expected: [
            .update(.init(
                    inserted: search.recordsCount,
                    updated: 0,
                    deleted: 0
                )
            )
        ])
        
        let exp = XCTestExpectation(description: #function)
        sut.store(
                addresses: search.addresses,
                postcode: search.fetchPostcode,
                countryCode: search.fetchCountryCode
            )
            .sinkToResult { result in
                switch result {
                case let .success(resultValue):
                    // fetched result should come back with the expected
                    // data preloaded plus a timestamp
                    XCTAssertNotNil(resultValue?.fetchTimestamp, file: #file, line: #line)
                    let searchWithTimeStamp = AddressesSearch(
                        addresses: search.addresses,
                        fetchPostcode: search.fetchPostcode,
                        fetchCountryCode: search.fetchCountryCode,
                        fetchTimestamp: resultValue?.fetchTimestamp
                    )
                    result.assertSuccess(value: searchWithTimeStamp)
                case let .failure(error):
                    XCTFail("Expected success, error: \(error)", file: #file, line: #line)
                }
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_storeForAddress_noAddressesGiven_storeAndReturnWithNilAddresses() throws {
        let search = AddressesSearch.mockedDataWithNoAddresses
        
        mockedStore.actions = .init(expected: [
            .update(.init(
                    inserted: search.recordsCount,
                    updated: 0,
                    deleted: 0
                )
            )
        ])
        
        let exp = XCTestExpectation(description: #function)
        sut.store(
                addresses: search.addresses,
                postcode: search.fetchPostcode,
                countryCode: search.fetchCountryCode
            )
            .sinkToResult { result in
                switch result {
                case let .success(resultValue):
                    // fetched result should come back with the expected
                    // data preloaded plus a timestamp
                    XCTAssertNotNil(resultValue?.fetchTimestamp, file: #file, line: #line)
                    let searchWithTimeStamp = AddressesSearch(
                        addresses: search.addresses,
                        fetchPostcode: search.fetchPostcode,
                        fetchCountryCode: search.fetchCountryCode,
                        fetchTimestamp: resultValue?.fetchTimestamp
                    )
                    result.assertSuccess(value: searchWithTimeStamp)
                case let .failure(error):
                    XCTFail("Expected success, error: \(error)", file: #file, line: #line)
                }
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_storeForAddress_givenInvalidAddresses_filterInvalidAddresses() throws {
        let search = AddressesSearch.mockedDataWithOneValidAddress
        let searchAfterFiltering = AddressesSearch.mockedDataWithOneValidAddressAfterFiltering
        
        mockedStore.actions = .init(expected: [
            .update(.init(
                    inserted: searchAfterFiltering.recordsCount,
                    updated: 0,
                    deleted: 0
                )
            )
        ])
        
        let exp = XCTestExpectation(description: #function)
        sut.store(
                addresses: search.addresses,
                postcode: search.fetchPostcode,
                countryCode: search.fetchCountryCode
            )
            .sinkToResult { result in
                switch result {
                case let .success(resultValue):
                    // fetched result should come back with the expected
                    // data preloaded plus a timestamp
                    XCTAssertNotNil(resultValue?.fetchTimestamp, file: #file, line: #line)
                    let searchWithTimeStamp = AddressesSearch(
                        addresses: FoundAddress.mockedArrayDataWithFilteredOutInvalidAddresses,
                        fetchPostcode: search.fetchPostcode,
                        fetchCountryCode: search.fetchCountryCode,
                        fetchTimestamp: resultValue?.fetchTimestamp
                    )
                    result.assertSuccess(value: searchWithTimeStamp)
                case let .failure(error):
                    XCTFail("Expected success, error: \(error)", file: #file, line: #line)
                }
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
    }
    
    // MARK: - findAddressSelectionCountriesFetch(forLocaleCode:)
    
    func test_findAddressSelectionCountriesFetch_whenDataStored_returnData() throws {
        let fetch = AddressSelectionCountriesFetch.mockedData
        
        mockedStore.actions = .init(expected: [
            .fetch(String(describing: AddressSelectionCountriesFetchMO.self), .init(inserted: 0, updated: 0, deleted: 0))
        ])
        
        try mockedStore.preloadData { context in
            // this will also set the timestamp
            fetch.store(in: context)
        }
        
        let exp = XCTestExpectation(description: #function)
        sut.findAddressSelectionCountriesFetch(forLocaleCode: fetch.fetchLocaleCode)
            .sinkToResult { result in
                switch result {
                case let .success(resultValue):
                    // fetched result should come back with the expected
                    // data preloaded plus a timestamp
                    XCTAssertNotNil(resultValue?.fetchTimestamp, file: #file, line: #line)
                    let fetchWithTimeStamp = AddressSelectionCountriesFetch(
                        countries: fetch.countries,
                        fetchLocaleCode: fetch.fetchLocaleCode,
                        fetchTimestamp: resultValue?.fetchTimestamp
                    )
                    result.assertSuccess(value: fetchWithTimeStamp)
                case let .failure(error):
                    XCTFail("Expected success, error: \(error)", file: #file, line: #line)
                }
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_findAddressSelectionCountriesFetch_whenNoDataStored_returnNilResult() throws {
        let fetch = AddressSelectionCountriesFetch.mockedData
        
        mockedStore.actions = .init(expected: [
            .fetch(String(describing: AddressSelectionCountriesFetchMO.self), .init(inserted: 0, updated: 0, deleted: 0))
        ])
        
        // no preloaded data
        
        let exp = XCTestExpectation(description: #function)
        sut.findAddressSelectionCountriesFetch(forLocaleCode: fetch.fetchLocaleCode)
            .sinkToResult { result in
                result.assertSuccess(value: nil)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
    }
    
    // MARK: - clearAddressSelectionCountriesFetch(forLocaleCode:)
    
    func test_clearAddressSelectionCountriesFetch() throws {
        let fetch = AddressSelectionCountriesFetch.mockedData
        
        mockedStore.actions = .init(expected: [
            .update(
                .init(
                    inserted: 0,
                    updated: 0,
                    // not fetch.recordsCount because of cascade deletion
                    deleted: 1
                )
            )
        ])
        
        try mockedStore.preloadData { context in
            fetch.store(in: context)
        }
        
        let exp = XCTestExpectation(description: #function)
        sut.clearAddressSelectionCountriesFetch(forLocaleCode: fetch.fetchLocaleCode)
            .sinkToResult { result in
                result.assertSuccess(value: true)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
    }
    
    // MARK: - store(countries:forLocaleCode:)
    
    func test_storeForSelectionCountries_countriesGriven_storeAndReturnWithCountries() throws {
        let fetch = AddressSelectionCountriesFetch.mockedData
        
        mockedStore.actions = .init(expected: [
            .update(.init(
                    inserted: fetch.recordsCount,
                    updated: 0,
                    deleted: 0
                )
            )
        ])
        
        let exp = XCTestExpectation(description: #function)
        sut.store(countries: fetch.countries, forLocaleCode: fetch.fetchLocaleCode)
            .sinkToResult { result in
                switch result {
                case let .success(resultValue):
                    // fetched result should come back with the expected
                    // data preloaded plus a timestamp
                    XCTAssertNotNil(resultValue?.fetchTimestamp, file: #file, line: #line)
                    let fetchWithTimeStamp = AddressSelectionCountriesFetch(
                        countries: fetch.countries,
                        fetchLocaleCode: fetch.fetchLocaleCode,
                        fetchTimestamp: resultValue?.fetchTimestamp
                    )
                    result.assertSuccess(value: fetchWithTimeStamp)
                case let .failure(error):
                    XCTFail("Expected success, error: \(error)", file: #file, line: #line)
                }
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_storeForSelectionCountries_whenNoCountriesGriven_storeAndReturnWithNilResult() throws {
        let fetch = AddressSelectionCountriesFetch.mockedDataWithNoCounties
        
        mockedStore.actions = .init(expected: [
            .update(.init(
                    inserted: fetch.recordsCount,
                    updated: 0,
                    deleted: 0
                )
            )
        ])
        
        let exp = XCTestExpectation(description: #function)
        sut.store(countries: fetch.countries, forLocaleCode: fetch.fetchLocaleCode)
            .sinkToResult { result in
                switch result {
                case let .success(resultValue):
                    // fetched result should come back with the expected
                    // data preloaded plus a timestamp
                    XCTAssertNotNil(resultValue?.fetchTimestamp, file: #file, line: #line)
                    let fetchWithTimeStamp = AddressSelectionCountriesFetch(
                        countries: fetch.countries,
                        fetchLocaleCode: fetch.fetchLocaleCode,
                        fetchTimestamp: resultValue?.fetchTimestamp
                    )
                    result.assertSuccess(value: fetchWithTimeStamp)
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
