//
//  AddressServiceTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 17/01/2022.
//

import XCTest
import Combine
@testable import SnappyV2

class AddressServiceTests: XCTestCase {
    
    var appState = CurrentValueSubject<AppState, Never>(AppState())
    var mockedEventLogger: MockedEventLogger!
    var mockedWebRepo: MockedAddressWebRepository!
    var mockedDBRepo: MockedAddressDBRepository!
    var subscriptions = Set<AnyCancellable>()
    var sut: AddressService!

    override func setUp() {
        
        mockedEventLogger = MockedEventLogger()
        mockedWebRepo = MockedAddressWebRepository()
        mockedDBRepo = MockedAddressDBRepository()
        sut = AddressService(
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

// MARK: - func findAddresses(addresses:postcode:countryCode:)
final class FindAddressesTests: AddressServiceTests {
    
    func test_successfulFind_whenEmptyDB_thenFetchFromWeb() {
        let searchResult = AddressesSearch.mockedData
        
        appState.value.businessData.businessProfile = BusinessProfile.mockedDataFromAPI
        
        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [
            .findAddresses(postcode: searchResult.fetchPostcode, countryCode: searchResult.fetchCountryCode)
        ])
        mockedDBRepo.actions = .init(expected: [
            .findAddressesFetch(postcode: searchResult.fetchPostcode, countryCode: searchResult.fetchCountryCode),
            .clearAddressesFetch(postcode: searchResult.fetchPostcode, countryCode: searchResult.fetchCountryCode),
            .store(addresses: searchResult.addresses, postcode: searchResult.fetchPostcode, countryCode: searchResult.fetchCountryCode)
        ])

        // Configuring responses from repositories

        mockedWebRepo.findAddressesResponse = .success(searchResult.addresses)
        mockedDBRepo.findAddressesFetchResult = .success(nil)
        mockedDBRepo.clearAddressesFetchResult = .success(true)
        mockedDBRepo.storeAddressesResult = .success(searchResult)
        
        let exp = XCTestExpectation(description: #function)
        let addresses = BindingWithPublisher(value: Loadable<[FoundAddress]?>.notRequested)
        sut.findAddresses(addresses: addresses.binding, postcode: searchResult.fetchPostcode, countryCode: searchResult.fetchCountryCode)
        addresses.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .loaded(searchResult.addresses)
            ], removing: [])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
    }
    
    func test_successfulFind_whenInDB_thenReturnDBResult() {
        
        let searchResult = AddressesSearch(
            addresses: AddressesSearch.mockedData.addresses,
            fetchPostcode: AddressesSearch.mockedData.fetchPostcode,
            fetchCountryCode: AddressesSearch.mockedData.fetchCountryCode,
            fetchTimestamp: Date()
        )
        
        // Configuring expected actions on repositories

        mockedDBRepo.actions = .init(expected: [
            .findAddressesFetch(postcode: searchResult.fetchPostcode, countryCode: searchResult.fetchCountryCode)
        ])

        // Configuring responses from repositories

        mockedDBRepo.findAddressesFetchResult = .success(searchResult)
        
        let exp = XCTestExpectation(description: #function)
        let addresses = BindingWithPublisher(value: Loadable<[FoundAddress]?>.notRequested)
        sut.findAddresses(addresses: addresses.binding, postcode: searchResult.fetchPostcode, countryCode: searchResult.fetchCountryCode)
        addresses.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .loaded(searchResult.addresses)
            ], removing: [])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
    }
    
    func test_successfulFind_whenInDBTooOld_FetchNew() {
        
        let expiredDate = Calendar.current.date(byAdding: .hour, value: -12, to: AppV2Constants.Business.addressesCachedExpiry)
        
        let searchResult = AddressesSearch(
            addresses: AddressesSearch.mockedData.addresses,
            fetchPostcode: AddressesSearch.mockedData.fetchPostcode,
            fetchCountryCode: AddressesSearch.mockedData.fetchCountryCode,
            fetchTimestamp: expiredDate
        )
        
        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [
            .findAddresses(postcode: searchResult.fetchPostcode, countryCode: searchResult.fetchCountryCode)
        ])
        mockedDBRepo.actions = .init(expected: [
            .findAddressesFetch(postcode: searchResult.fetchPostcode, countryCode: searchResult.fetchCountryCode),
            .clearAddressesFetch(postcode: searchResult.fetchPostcode, countryCode: searchResult.fetchCountryCode),
            .store(addresses: searchResult.addresses, postcode: searchResult.fetchPostcode, countryCode: searchResult.fetchCountryCode)
        ])

        // Configuring responses from repositories

        mockedWebRepo.findAddressesResponse = .success(searchResult.addresses)
        mockedDBRepo.findAddressesFetchResult = .success(searchResult)
        mockedDBRepo.clearAddressesFetchResult = .success(true)
        mockedDBRepo.storeAddressesResult = .success(searchResult)
        
        let exp = XCTestExpectation(description: #function)
        let addresses = BindingWithPublisher(value: Loadable<[FoundAddress]?>.notRequested)
        sut.findAddresses(addresses: addresses.binding, postcode: searchResult.fetchPostcode, countryCode: searchResult.fetchCountryCode)
        addresses.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .loaded(searchResult.addresses)
            ], removing: [])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
        
    }
    
    func test_unsuccessfulFind_whenPostcodeFormatIncorrect_ThrowError() {
        
        let postcode = "BAD POSTCODE"
        let countryCode = "UK"
        
        appState.value.businessData.businessProfile = BusinessProfile.mockedDataFromAPI
        
        let exp = XCTestExpectation(description: #function)
        let addresses = BindingWithPublisher(value: Loadable<[FoundAddress]?>.notRequested)
        sut.findAddresses(addresses: addresses.binding, postcode: postcode, countryCode: countryCode)
        addresses.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .failed(AddressServiceError.postcodeFormatNotRecognised(postcode))
            ], removing: [])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
        
    }
    
}

// MARK: - func findAddressesAsync(postcode: String, countryCode: String)
final class FindAddressesAsyncTests: AddressServiceTests {
    
    func test_successfulFind_whenEmptyDB_thenFetchFromWeb() async {
        let searchResult = AddressesSearch.mockedData
        
        appState.value.businessData.businessProfile = BusinessProfile.mockedDataFromAPI
        
        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [
            .findAddresses(postcode: searchResult.fetchPostcode, countryCode: searchResult.fetchCountryCode)
        ])
        mockedDBRepo.actions = .init(expected: [
            .findAddressesFetch(postcode: searchResult.fetchPostcode, countryCode: searchResult.fetchCountryCode),
            .clearAddressesFetch(postcode: searchResult.fetchPostcode, countryCode: searchResult.fetchCountryCode),
            .store(addresses: searchResult.addresses, postcode: searchResult.fetchPostcode, countryCode: searchResult.fetchCountryCode)
        ])

        // Configuring responses from repositories

        mockedWebRepo.findAddressesResponse = .success(searchResult.addresses)
        mockedDBRepo.findAddressesFetchResult = .success(nil)
        mockedDBRepo.clearAddressesFetchResult = .success(true)
        mockedDBRepo.storeAddressesResult = .success(searchResult)
        
        do {
            let addresses = try await sut.findAddressesAsync(postcode: searchResult.fetchPostcode, countryCode: searchResult.fetchCountryCode)
            XCTAssertEqual(addresses, searchResult.addresses, file: #file, line: #line)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }
    
    func test_successfulFind_whenInDB_thenReturnDBResult() async {
        
        let searchResult = AddressesSearch(
            addresses: AddressesSearch.mockedData.addresses,
            fetchPostcode: AddressesSearch.mockedData.fetchPostcode,
            fetchCountryCode: AddressesSearch.mockedData.fetchCountryCode,
            fetchTimestamp: Date()
        )
        
        // Configuring expected actions on repositories

        mockedDBRepo.actions = .init(expected: [
            .findAddressesFetch(postcode: searchResult.fetchPostcode, countryCode: searchResult.fetchCountryCode)
        ])

        // Configuring responses from repositories

        mockedDBRepo.findAddressesFetchResult = .success(searchResult)
        
        do {
            let addresses = try await sut.findAddressesAsync(postcode: searchResult.fetchPostcode, countryCode: searchResult.fetchCountryCode)
            XCTAssertEqual(addresses, searchResult.addresses, file: #file, line: #line)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }
    
    func test_successfulFind_whenInDBTooOld_FetchNew() async {
        
        let expiredDate = Calendar.current.date(byAdding: .hour, value: -12, to: AppV2Constants.Business.addressesCachedExpiry)
        
        let searchResult = AddressesSearch(
            addresses: AddressesSearch.mockedData.addresses,
            fetchPostcode: AddressesSearch.mockedData.fetchPostcode,
            fetchCountryCode: AddressesSearch.mockedData.fetchCountryCode,
            fetchTimestamp: expiredDate
        )
        
        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [
            .findAddresses(postcode: searchResult.fetchPostcode, countryCode: searchResult.fetchCountryCode)
        ])
        mockedDBRepo.actions = .init(expected: [
            .findAddressesFetch(postcode: searchResult.fetchPostcode, countryCode: searchResult.fetchCountryCode),
            .clearAddressesFetch(postcode: searchResult.fetchPostcode, countryCode: searchResult.fetchCountryCode),
            .store(addresses: searchResult.addresses, postcode: searchResult.fetchPostcode, countryCode: searchResult.fetchCountryCode)
        ])

        // Configuring responses from repositories

        mockedWebRepo.findAddressesResponse = .success(searchResult.addresses)
        mockedDBRepo.findAddressesFetchResult = .success(searchResult)
        mockedDBRepo.clearAddressesFetchResult = .success(true)
        mockedDBRepo.storeAddressesResult = .success(searchResult)
        
        do {
            let addresses = try await sut.findAddressesAsync(postcode: searchResult.fetchPostcode, countryCode: searchResult.fetchCountryCode)
            XCTAssertEqual(addresses, searchResult.addresses, file: #file, line: #line)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
        
    }
    
    func test_unsuccessfulFind_whenPostcodeFormatIncorrect_ThrowError() async {
        
        let postcode = "BAD POSTCODE"
        let countryCode = "UK"
        
        appState.value.businessData.businessProfile = BusinessProfile.mockedDataFromAPI
        
        do {
            let addresses = try await sut.findAddressesAsync(postcode: postcode, countryCode: countryCode)
            XCTFail("Unexpected result: \(String(describing: addresses))", file: #file, line: #line)
        } catch {
            XCTAssertEqual(error as? AddressServiceError, AddressServiceError.postcodeFormatNotRecognised(postcode), file: #file, line: #line)
            mockedWebRepo.verify()
            mockedDBRepo.verify()
        }
        
    }
    
}

// MARK: - func getSelectionCountries(countries:)
final class GetSelectionCountriesTests: AddressServiceTests {
    
    func test_successfulFind_whenEmptyDB_thenFetchFromWeb() {
        let fetchResult = AddressSelectionCountriesFetch.mockedData
        
        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [
            .getCountries
        ])
        mockedDBRepo.actions = .init(expected: [
            .findAddressSelectionCountriesFetch(forLocaleCode: fetchResult.fetchLocaleCode),
            .clearAddressSelectionCountriesFetch(forLocaleCode: fetchResult.fetchLocaleCode),
            .store(countries: fetchResult.countries, forLocaleCode: fetchResult.fetchLocaleCode)
        ])

        // Configuring responses from repositories

        mockedWebRepo.getCountriesResponse = .success(fetchResult.countries)
        mockedDBRepo.findAddressSelectionCountriesFetchResult = .success(nil)
        mockedDBRepo.clearAddressSelectionCountriesFetchResult = .success(true)
        mockedDBRepo.storeSelectionCountriesResult = .success(fetchResult)
        
        let exp = XCTestExpectation(description: #function)
        let countries = BindingWithPublisher(value: Loadable<[AddressSelectionCountry]?>.notRequested)
        sut.getSelectionCountries(countries: countries.binding)
        countries.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .loaded(fetchResult.countries)
            ], removing: [])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
    }
    
    func test_successfulFind_whenInDB_thenReturnDBResult() {
        
        let fetchResult = AddressSelectionCountriesFetch(
            countries: AddressSelectionCountriesFetch.mockedData.countries,
            fetchLocaleCode: AddressSelectionCountriesFetch.mockedData.fetchLocaleCode,
            fetchTimestamp: Date()
        )
        
        // Configuring expected actions on repositories

        mockedDBRepo.actions = .init(expected: [
            .findAddressSelectionCountriesFetch(forLocaleCode: fetchResult.fetchLocaleCode)
        ])

        // Configuring responses from repositories

        mockedDBRepo.findAddressSelectionCountriesFetchResult = .success(fetchResult)
        
        let exp = XCTestExpectation(description: #function)
        let countries = BindingWithPublisher(value: Loadable<[AddressSelectionCountry]?>.notRequested)
        sut.getSelectionCountries(countries: countries.binding)
        countries.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .loaded(fetchResult.countries)
            ], removing: [])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
    }
    
    func test_successfulFind_whenInDBTooOld_FetchNew() {
        
        let expiredDate = Calendar.current.date(byAdding: .hour, value: -12, to: AppV2Constants.Business.addressesCachedExpiry)
        
        let fetchResult = AddressSelectionCountriesFetch(
            countries: AddressSelectionCountriesFetch.mockedData.countries,
            fetchLocaleCode: AddressSelectionCountriesFetch.mockedData.fetchLocaleCode,
            fetchTimestamp: expiredDate
        )
        
        // Configuring expected actions on repositories

        mockedWebRepo.actions = .init(expected: [
            .getCountries
        ])
        mockedDBRepo.actions = .init(expected: [
            .findAddressSelectionCountriesFetch(forLocaleCode: fetchResult.fetchLocaleCode),
            .clearAddressSelectionCountriesFetch(forLocaleCode: fetchResult.fetchLocaleCode),
            .store(countries: fetchResult.countries, forLocaleCode: fetchResult.fetchLocaleCode)
        ])

        // Configuring responses from repositories

        mockedWebRepo.getCountriesResponse = .success(fetchResult.countries)
        mockedDBRepo.findAddressSelectionCountriesFetchResult = .success(nil)
        mockedDBRepo.clearAddressSelectionCountriesFetchResult = .success(true)
        mockedDBRepo.storeSelectionCountriesResult = .success(fetchResult)
        
        let exp = XCTestExpectation(description: #function)
        let countries = BindingWithPublisher(value: Loadable<[AddressSelectionCountry]?>.notRequested)
        sut.getSelectionCountries(countries: countries.binding)
        countries.updatesRecorder.sink { updates in
            XCTAssertEqual(updates, [
                .notRequested,
                .isLoading(last: nil, cancelBag: CancelBag()),
                .loaded(fetchResult.countries)
            ], removing: [])
            self.mockedWebRepo.verify()
            self.mockedDBRepo.verify()
            exp.fulfill()
        }.store(in: &subscriptions)
        wait(for: [exp], timeout: 2)
    }
    
}
