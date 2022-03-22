//
//  Address.swift
//  SnappyV2
//
//  Created by Kevin Palser on 14/01/2022.
//

import Foundation

/// AddressesSearch is used purely for internal management of the search results and is not returned by AddressService.
struct AddressesSearch: Equatable {
    // Populated for checking cached results not from
    // decoding an API response
    let addresses: [FoundAddress]?
    let fetchPostcode: String
    let fetchCountryCode: String
    let fetchTimestamp: Date?
}

struct Address: Codable, Equatable {
    let id: Int?
    let isDefault: Bool?
    let addressName: String?
    let firstName: String
    let lastName: String
    let addressline1: String
    let addressline2: String?
    let town: String
    let postcode: String
    let county: String?
    let countryCode: String
    let type: AddressType
    let location: Location?
}

enum AddressType: String, Codable, Equatable {
    case billing
    case delivery
}

/// FoundAddress represents a result matching a postcode search. It is not returned if neither addressline1 or addressline2 is set.
struct FoundAddress: Codable, Equatable, Hashable {
    let addressline1: String
    let addressline2: String
    let town: String
    let postcode: String
    let countryCode: String
    let county: String
    let addressLineSingle: String
}

/// AddressSelectionCountriesFetch is used purely for internal management of the countries fetch results and is not returned by AddressService.
struct AddressSelectionCountriesFetch: Equatable {
    // Populated for checking cached results not from
    // decoding an API response
    let countries: [AddressSelectionCountry]?
    let fetchLocaleCode: String
    let fetchTimestamp: Date?
}

/// AddressSelectionCountry represents a result in the countries fetch.
struct AddressSelectionCountry: Codable, Equatable, Hashable {
    let countryCode: String
    let countryName: String
    let billingEnabled: Bool
    let fulfilmentEnabled: Bool
}

/// SelectedAddress is used in the response returned by the post code search component's closure.
struct SelectedAddress: Equatable {
    let firstName: String
    let lastName: String
    let address: FoundAddress
    let country: AddressSelectionCountry?
}

struct Name: Equatable {
    let firstName: String
    let secondName: String
}

extension Address {
    func singleLineAddress() -> String {
        let fields = [self.addressline1, self.addressline2 ?? "", self.town, self.county ?? "", self.postcode]
        
        let validAddressStrings = fields.filter {
            !$0.isEmpty
        }
        return validAddressStrings.joined(separator: ", ")
    }
}
