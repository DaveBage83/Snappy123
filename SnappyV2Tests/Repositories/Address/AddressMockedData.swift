//
//  AddressMockedData.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 16/01/2022.
//

import Foundation
@testable import SnappyV2

extension AddressesSearch {

    static let mockedData = AddressesSearch(
        addresses: FoundAddress.mockedArrayData,
        fetchPostcode: "B38 9BB",
        fetchCountryCode: "UK",
        fetchTimestamp: nil
    )
    
    static let mockedDataWithNoAddresses = AddressesSearch(
        addresses: nil,
        fetchPostcode: "ZZ99 9ZZ",
        fetchCountryCode: "UK",
        fetchTimestamp: nil
    )
    
    static let mockedDataWithOneValidAddress = AddressesSearch(
        addresses: FoundAddress.mockedArrayDataWithMissingAddressLines,
        fetchPostcode: "B38 9BB",
        fetchCountryCode: "UK",
        fetchTimestamp: nil
    )
    
    static let mockedDataWithOneValidAddressAfterFiltering = AddressesSearch(
        addresses: FoundAddress.mockedArrayDataWithFilteredOutInvalidAddresses,
        fetchPostcode: "B38 9BB",
        fetchCountryCode: "UK",
        fetchTimestamp: nil
    )
    
    var recordsCount: Int {
        
        var count = 1
        
        if let addresses = addresses {
            count += addresses.count
        }
        
        return count
    }
}

extension FoundAddress {

    static let mockedArrayData = [
        FoundAddress(
            addressline1: "1 MARSH END",
            addressline2: "",
            town: "BIRMINGHAM",
            postcode: "B38 9BB",
            countryCode: "UK",
            county: "West Midlands",
            addressLineSingle: "1 MARSH END, BIRMINGHAM, West Midlands, B38 9BB"
        ),
        FoundAddress(
            addressline1: "2 MARSH END",
            addressline2: "",
            town: "BIRMINGHAM",
            postcode: "B38 9BB",
            countryCode: "UK",
            county: "West Midlands",
            addressLineSingle: "2 MARSH END, BIRMINGHAM, West Midlands, B38 9BB"
        ),
        FoundAddress(
            addressline1: "3 MARSH END",
            addressline2: "",
            town: "BIRMINGHAM",
            postcode: "B38 9BB",
            countryCode: "UK",
            county: "West Midlands",
            addressLineSingle: "3 MARSH END, BIRMINGHAM, West Midlands, B38 9BB"
        )
    ]
    
    // Only the last entry can be stored
    static let mockedArrayDataWithMissingAddressLines = [
        FoundAddress(
            addressline1: "3 MARSH END",
            addressline2: "",
            town: "BIRMINGHAM",
            postcode: "B38 9BB",
            countryCode: "UK",
            county: "West Midlands",
            addressLineSingle: "3 MARSH END, BIRMINGHAM, West Midlands, B38 9BB"
        )
    ]
    
    static let mockedArrayDataWithFilteredOutInvalidAddresses = [
        FoundAddress(
            addressline1: "3 MARSH END",
            addressline2: "",
            town: "BIRMINGHAM",
            postcode: "B38 9BB",
            countryCode: "UK",
            county: "West Midlands",
            addressLineSingle: "3 MARSH END, BIRMINGHAM, West Midlands, B38 9BB"
        )
    ]

}

extension AddressSelectionCountriesFetch {

    static let mockedData = AddressSelectionCountriesFetch(
        countries: AddressSelectionCountry.mockedArrayData,
        fetchLocaleCode: AppV2Constants.Client.languageCode,
        fetchTimestamp: nil
    )
    
    static let mockedDataWithNoCounties = AddressSelectionCountriesFetch(
        countries: nil,
        fetchLocaleCode: AppV2Constants.Client.languageCode,
        fetchTimestamp: nil
    )
    
    var recordsCount: Int {
        
        var count = 1
        
        if let countries = countries {
            count += countries.count
        }
        
        return count
    }
}

extension AddressSelectionCountry {
    
    static let mockedArrayData = [
        AddressSelectionCountry(
            countryCode: "AF",
            countryName: "Afghanistan",
            billingEnabled: false,
            fulfilmentEnabled: false
        ),
        AddressSelectionCountry(
            countryCode: "UK",
            countryName: "United Kingdom",
            billingEnabled: true,
            fulfilmentEnabled: true
        )
    ]
    
}

extension BasketTip {
    
    static let mackedDriverTip = BasketTip(type: "driver", ammount: 1.5)
    
    static let mockedArrayData = [
        BasketTip.mackedDriverTip
    ]
    
}
