//
//  MockedBasketWebRepository.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 07/02/2022.
//

import XCTest
import Combine
@testable import SnappyV2

final class MockedBasketWebRepository: TestWebRepository, Mock, AddressWebRepositoryProtocol {
    
    enum Action: Equatable {
        case findAddresses(postcode: String, countryCode: String)
        case getCountries
    }
    var actions = MockActions<Action>(expected: [])
    
    var findAddressesResponse: Result<[FoundAddress]?, Error> = .failure(MockError.valueNotSet)
    var getCountriesResponse: Result<[AddressSelectionCountry]?, Error> = .failure(MockError.valueNotSet)
    
    func findAddresses(postcode: String, countryCode: String) -> AnyPublisher<[FoundAddress]?, Error> {
        register(.findAddresses(postcode: postcode, countryCode: countryCode))
        return findAddressesResponse.publish()
    }
    
    func getCountries() -> AnyPublisher<[AddressSelectionCountry]?, Error> {
        register(.getCountries)
        return getCountriesResponse.publish()
    }

}
