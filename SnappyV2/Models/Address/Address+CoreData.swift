//
//  Address+CoreData.swift
//  SnappyV2
//
//  Created by Kevin Palser on 14/01/2022.
//

import Foundation
import CoreData

extension AddressesSearchMO: ManagedEntity { }
extension FoundAddressMO: ManagedEntity { }
extension AddressSelectionCountriesFetchMO: ManagedEntity { }
extension AddressSelectionCountryMO: ManagedEntity { }

extension AddressesSearch {
    init(managedObject: AddressesSearchMO) {
        
        var addresses: [FoundAddress]?
        if
            let foundAddresses = managedObject.addresses,
            let foundAddressesArray = foundAddresses.array as? [FoundAddressMO]
        {
            addresses = foundAddressesArray
                .reduce(nil, { (foundAddressesArray, record) -> [FoundAddress]? in
                    var array = foundAddressesArray ?? []
                    array.append(FoundAddress(managedObject: record))
                    return array
                })
        }
        
        self.init(
            addresses: addresses,
            fetchPostcode: managedObject.fetchPostcode ?? "",
            fetchCountryCode: managedObject.fetchCountryCode ?? "",
            fetchTimestamp: managedObject.timestamp
        )
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> AddressesSearchMO? {
        
        guard let search = AddressesSearchMO.insertNew(in: context)
            else { return nil }
        
        if
            let foundAddresses = addresses,
            foundAddresses.count > 0
        {
            search.addresses = NSOrderedSet(array: foundAddresses.compactMap({ address -> FoundAddressMO? in
                // if address line 1 is empty then discard result
                if !address.addressline1.isEmpty {
                    return address.store(in: context)
                } else {
                    return nil
                }
            }))
        }

        search.fetchPostcode = fetchPostcode
        search.fetchCountryCode = fetchCountryCode
        search.timestamp = Date().trueDate
        
        return search
    }
}

extension FoundAddress {
    init(managedObject: FoundAddressMO) {
        self.init(
            addressline1: managedObject.addressline1 ?? "",
            addressline2: managedObject.addressline2 ?? "",
            town: managedObject.town ?? "",
            postcode: managedObject.postcode ?? "",
            countryCode: managedObject.countryCode ?? "",
            county: managedObject.county ?? "",
            addressLineSingle: managedObject.addressLineSingle ?? ""
        )
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> FoundAddressMO? {
        
        guard let address = FoundAddressMO.insertNew(in: context)
            else { return nil }

        address.addressline1 = addressline1
        address.addressline2 = addressline2
        address.town = town
        address.postcode = postcode
        address.countryCode = countryCode
        address.county = county
        address.addressLineSingle = addressLineSingle
        
        return address
    }
}

extension AddressSelectionCountriesFetch {
    init(managedObject: AddressSelectionCountriesFetchMO) {
        
        var countries: [AddressSelectionCountry]?
        if
            let foundCountries = managedObject.countries,
            let foundCountriesArray = foundCountries.array as? [AddressSelectionCountryMO]
        {
            countries = foundCountriesArray
                .reduce(nil, { (foundCountriesArray, record) -> [AddressSelectionCountry]? in
                    var array = foundCountriesArray ?? []
                    array.append(AddressSelectionCountry(managedObject: record))
                    return array
                })
        }
        
        self.init(
            countries: countries,
            fetchLocaleCode: managedObject.fetchLocaleCode ?? "",
            fetchTimestamp: managedObject.timestamp
        )
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> AddressSelectionCountriesFetchMO? {
        
        guard let fetch = AddressSelectionCountriesFetchMO.insertNew(in: context)
            else { return nil }
        
        if
            let foundCountries = countries,
            foundCountries.count > 0
        {
            fetch.countries = NSOrderedSet(array: foundCountries.compactMap({ country -> AddressSelectionCountryMO? in
                return country.store(in: context)
            }))
        }

        fetch.fetchLocaleCode = fetchLocaleCode
        fetch.timestamp = Date().trueDate
        
        return fetch
    }
}

extension AddressSelectionCountry {
    init(managedObject: AddressSelectionCountryMO) {
        self.init(
            countryCode: managedObject.countryCode ?? "",
            countryName: managedObject.countryName ?? "",
            billingEnabled: managedObject.billingEnabled,
            fulfilmentEnabled: managedObject.fulfilmentEnabled
        )
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> AddressSelectionCountryMO? {
        
        guard let country = AddressSelectionCountryMO.insertNew(in: context)
            else { return nil }

        country.countryCode = countryCode
        country.countryName = countryName
        country.billingEnabled = billingEnabled
        country.fulfilmentEnabled = fulfilmentEnabled
        
        return country
    }
}
