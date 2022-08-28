//
//  CountrySelectorViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 26/07/2022.
//

import XCTest
import Combine
@testable import SnappyV2

class CountrySelectorViewModelTests: XCTestCase {
    
    // Test on init get countries
    
    func test_whenInit_thenGetCountriesCalled() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(addressService: [.getSelectionCountries]))
        
        let sut = makeSUT(container: container, countrySelected: { _ in })
        
        let expectation = expectation(description: "callGetSelectionCountries")
        var cancellables = Set<AnyCancellable>()
        
        sut.$selectionCountriesRequest
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        container.services.verify(as: .address)
    }
    
    // Test when starter country included in init then countryText assigned
    
    func test_whenStarterCountryIncluded_thenCountryTextAssignedAccordingly() {
        let country = AddressSelectionCountry(
            countryCode: "FR",
            countryName: "France",
            billingEnabled: true,
            fulfilmentEnabled: true)
        
        let sut = makeSUT(starterCountry: country.countryCode, countrySelected: { _ in })
                
        let expectation = expectation(description: "countryTextSet")
        var cancellables = Set<AnyCancellable>()
        
        let countries = [
            AddressSelectionCountry(countryCode: "UK", countryName: "United Kingdom", billingEnabled: true, fulfilmentEnabled: true),
            AddressSelectionCountry(countryCode: "FR", countryName: "France", billingEnabled: true, fulfilmentEnabled: true),
            AddressSelectionCountry(countryCode: "ES", countryName: "Spain", billingEnabled: true, fulfilmentEnabled: true)
        ]
        
        sut.selectionCountriesRequest = .loaded(countries)
        
        sut.$selectedCountry
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
                
        XCTAssertEqual(sut.countryText, "France")
    }
    
    // Test if no starteCountry then use fulfilmentLocation to populate initial country
    
    func test_whenNoStarterCountry_thenUseFulfilmentLocationToPopulateCountry() {
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        
        container.appState.value.userData.currentFulfilmentLocation = FulfilmentLocation(country: "UK", latitude: 1, longitude: 1, postcode: "")
        
        let sut = makeSUT(container: container, countrySelected: { _ in })
        
        let countries = [
            AddressSelectionCountry(countryCode: "GB", countryName: "United Kingdom", billingEnabled: true, fulfilmentEnabled: true),
            AddressSelectionCountry(countryCode: "FR", countryName: "France", billingEnabled: true, fulfilmentEnabled: true),
            AddressSelectionCountry(countryCode: "ES", countryName: "Spain", billingEnabled: true, fulfilmentEnabled: true)
        ]
        
        sut.selectionCountriesRequest = .loaded(countries)
        
        let expectation = expectation(description: "countryTextSetToFulfilmentLocation")
        var cancellables = Set<AnyCancellable>()
        
        sut.$selectedCountry
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(sut.selectedCountry?.countryName, "United Kingdom")
        XCTAssertEqual(sut.countryText, "United Kingdom")
    }
    
    // Test when selectCountry called then selectedCountry set and text populated in field
    
    func test_whenSelectCountryCalled_thenSelectedCountrySetAndTextPopulated() {
        let country = AddressSelectionCountry(countryCode: "DE", countryName: "Germany", billingEnabled: true, fulfilmentEnabled: true)
        let sut = makeSUT(countrySelected: { _ in })
        
        let expectation = expectation(description: "selectedCountrySetAndTextPopulated")
        var cancellables = Set<AnyCancellable>()
        
        sut.selectCountry(country: country)

        XCTAssertEqual(sut.selectedCountry, country)
        
        sut.$selectedCountry
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(sut.countryText, country.countryName)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), starterCountry: String? = nil, countrySelected: @escaping (AddressSelectionCountry) -> ()) -> CountrySelectorViewModel {
        let sut = CountrySelectorViewModel(container: container, starterCountryCode: starterCountry, countrySelected: countrySelected)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
