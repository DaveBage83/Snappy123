//
//  MockedAddressDBRepository.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 18/01/2022.
//

import XCTest
import Combine
@testable import SnappyV2

final class MockedAddressDBRepository: Mock, AddressDBRepositoryProtocol {

    enum Action: Equatable {
        case findAddressesFetch(postcode: String, countryCode: String)
        case clearAddressesFetch(postcode: String, countryCode: String)
        case store(addresses: [FoundAddress]?, postcode: String, countryCode: String)
        case findAddressSelectionCountriesFetch(forLocaleCode: String)
        case clearAddressSelectionCountriesFetch(forLocaleCode: String)
        case store(countries: [AddressSelectionCountry]?, forLocaleCode: String)
    }
    var actions = MockActions<Action>(expected: [])
    
    var findAddressesFetchResult: Result<AddressesSearch?, Error> = .failure(MockError.valueNotSet)
    var clearAddressesFetchResult: Result<Bool, Error> = .failure(MockError.valueNotSet)
    var storeAddressesResult: Result<AddressesSearch?, Error> = .failure(MockError.valueNotSet)
    var findAddressSelectionCountriesFetchResult: Result<AddressSelectionCountriesFetch?, Error> = .failure(MockError.valueNotSet)
    var clearAddressSelectionCountriesFetchResult: Result<Bool, Error> = .failure(MockError.valueNotSet)
    var storeSelectionCountriesResult: Result<AddressSelectionCountriesFetch?, Error> = .failure(MockError.valueNotSet)
    
    func findAddressesFetch(postcode: String, countryCode: String) -> AnyPublisher<AddressesSearch?, Error> {
        register(.findAddressesFetch(postcode: postcode, countryCode: countryCode))
        return findAddressesFetchResult.publish()
    }
    
    func clearAddressesFetch(postcode: String, countryCode: String) -> AnyPublisher<Bool, Error> {
        register(.clearAddressesFetch(postcode: postcode, countryCode: countryCode))
        return clearAddressesFetchResult.publish()
    }
    
    func store(addresses: [FoundAddress]?, postcode: String, countryCode: String) -> AnyPublisher<AddressesSearch?, Error> {
        register(.store(addresses: addresses, postcode: postcode, countryCode: countryCode))
        return storeAddressesResult.publish()
    }
    
    func findAddressSelectionCountriesFetch(forLocaleCode localeCode: String) -> AnyPublisher<AddressSelectionCountriesFetch?, Error> {
        register(.findAddressSelectionCountriesFetch(forLocaleCode: localeCode))
        return findAddressSelectionCountriesFetchResult.publish()
    }
    
    func clearAddressSelectionCountriesFetch(forLocaleCode localeCode: String) -> AnyPublisher<Bool, Error> {
        register(.clearAddressSelectionCountriesFetch(forLocaleCode: localeCode))
        return clearAddressSelectionCountriesFetchResult.publish()
    }
    
    func store(countries: [AddressSelectionCountry]?, forLocaleCode localeCode: String) -> AnyPublisher<AddressSelectionCountriesFetch?, Error> {
        register(.store(countries: countries, forLocaleCode: localeCode))
        return storeSelectionCountriesResult.publish()
    }

}
