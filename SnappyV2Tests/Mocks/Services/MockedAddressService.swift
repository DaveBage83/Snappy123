//
//  MockedAddressService.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 15/01/2022.
//

import XCTest
import Combine
@testable import SnappyV2

struct MockedAddressService: Mock, AddressServiceProtocol {

    enum Action: Equatable {
        case findAddresses(postcode: String, countryCode: String)
        case findAddressesAsync(postcode: String, countryCode: String)
        case getSelectionCountries
    }
    
    let actions: MockActions<Action>
    
    init(expected: [Action]) {
        self.actions = .init(expected: expected)
    }
    
    func findAddresses(addresses: LoadableSubject<[FoundAddress]?>, postcode: String, countryCode: String) {
        register(.findAddresses(postcode: postcode, countryCode: countryCode))
    }
    
    func getSelectionCountries(countries: LoadableSubject<[AddressSelectionCountry]?>) {
        register(.getSelectionCountries)
    }
    
    func findAddressesAsync(postcode: String, countryCode: String) async throws -> [FoundAddress]? {
        register(.findAddressesAsync(postcode: postcode, countryCode: countryCode))
        return nil
    }
}
