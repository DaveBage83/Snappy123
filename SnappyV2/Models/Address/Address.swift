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

struct Address: Codable, Equatable, Identifiable {
    let id: Int?
    let isDefault: Bool?
    let addressName: String?
    let firstName: String? // optional for PlacedOrderFulfilmentMethod.address
    let lastName: String? // optional for PlacedOrderFulfilmentMethod.address
    let addressLine1: String
    let addressLine2: String?
    let town: String
    let postcode: String
    let county: String?
    let countryCode: String? // optional for PlacedOrderFulfilmentMethod.address
    let type: AddressType
    let location: Location?
    let email: String?
    let telephone: String?
}

enum AddressType: String, Codable, Equatable {
    case billing
    case delivery
    case card
}

/// FoundAddress represents a result matching a postcode search. It is not returned if neither addressline1 or addressline2 is set.
struct FoundAddress: Codable, Equatable, Hashable {
    let addressLine1: String
    let addressLine2: String
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

struct Name: Equatable {
    let firstName: String
    let secondName: String
}

extension Address {
    func singleLineAddress() -> String {
        let fields = [self.addressLine1, self.addressLine2 ?? "", self.town, self.county ?? "", self.postcode]
        
        let validAddressStrings = fields.filter {
            !$0.isEmpty
        }
        return validAddressStrings.joined(separator: ", ")
    }
    
    var fullName: String? {
        let firstName = firstName?.isEmpty == true ? nil : firstName
        let lastName = lastName?.isEmpty == true ? nil : lastName
        let name = [firstName, lastName].compactMap{ $0 }.joined(separator: " ")
        guard name.count > 0 else { return nil }
        return name
    }
}

extension Address {
    func mapToFoundAddress() -> FoundAddress {
        FoundAddress(
            addressLine1: self.addressLine1,
            addressLine2: self.addressLine2 ?? "",
            town: self.town,
            postcode: self.postcode,
            countryCode: self.countryCode ?? "",
            county: self.county ?? "",
            addressLineSingle: self.singleLineAddress())
    }
}

extension FoundAddress {
    func mapToAddress(isDefault: Bool? = nil, addressName: String? = nil, firstName: String? = nil, lastName: String? = nil, location: Location? = nil, type: AddressType, email: String? = nil, telephone: String? = nil) -> Address {
        Address(
            id: nil,
            isDefault: isDefault,
            addressName: addressName,
            firstName: firstName,
            lastName: lastName,
            addressLine1: addressLine1,
            addressLine2: addressLine2,
            town: town,
            postcode: postcode,
            county: county,
            countryCode: countryCode,
            type: type,
            location: location,
            email: email,
            telephone: telephone)
    }
}
