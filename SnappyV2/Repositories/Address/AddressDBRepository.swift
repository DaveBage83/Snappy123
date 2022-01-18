//
//  AddressDBRepository.swift
//  SnappyV2
//
//  Created by Kevin Palser on 14/01/2022.
//

import CoreData
import Combine

protocol AddressDBRepositoryProtocol {
    func findAddressesFetch(postcode: String, countryCode: String) -> AnyPublisher<AddressesSearch?, Error>
    func clearAddressesFetch(postcode: String, countryCode: String) -> AnyPublisher<Bool, Error>
    func store(addresses: [FoundAddress]?, postcode: String, countryCode: String) -> AnyPublisher<AddressesSearch?, Error>
    
    func findAddressSelectionCountriesFetch(forLocaleCode: String) -> AnyPublisher<AddressSelectionCountriesFetch?, Error>
    func clearAddressSelectionCountriesFetch(forLocaleCode: String) -> AnyPublisher<Bool, Error>
    func store(countries: [AddressSelectionCountry]?, forLocaleCode: String) -> AnyPublisher<AddressSelectionCountriesFetch?, Error>
}

struct AddressDBRepository: AddressDBRepositoryProtocol {

    let persistentStore: PersistentStore
    
    func findAddressesFetch(postcode: String, countryCode: String) -> AnyPublisher<AddressesSearch?, Error> {
        let fetchRequest = AddressesSearchMO.addressesSearchFetchRequest(
            postcode: postcode,
            countryCode: countryCode
        )
        
        return persistentStore
            .fetch(fetchRequest) {
                AddressesSearch(managedObject: $0)
            }
            .map { $0.first }
            .eraseToAnyPublisher()
    }
    
    func clearAddressesFetch(postcode: String, countryCode: String) -> AnyPublisher<Bool, Error> {
        return persistentStore
            .update { context in
                
                try AddressesSearchMO.delete(
                    fetchRequest: AddressesSearchMO.fetchRequestResultForDeletion(
                        postcode: postcode,
                        countryCode: countryCode
                    ),
                    in: context
                )
                
                return true
            }
    }
    
    func store(addresses: [FoundAddress]?, postcode: String, countryCode: String) -> AnyPublisher<AddressesSearch?, Error> {
        return persistentStore
            .update { context in
                
                let addressSearch = AddressesSearch(
                    addresses: addresses,
                    fetchPostcode: postcode,
                    fetchCountryCode: countryCode,
                    fetchTimestamp: nil
                )
                
                guard let addressesSearchMO = addressSearch.store(in: context) else {
                    throw AddressServiceError.unableToPersistResult
                }
                
                return AddressesSearch(managedObject: addressesSearchMO)
            }
    }
    
    func findAddressSelectionCountriesFetch(forLocaleCode localeCode: String) -> AnyPublisher<AddressSelectionCountriesFetch?, Error> {
        let fetchRequest = AddressSelectionCountriesFetchMO.addressSelectionCountriesFetchRequest(
            forLocaleCode: localeCode
        )
        
        return persistentStore
            .fetch(fetchRequest) {
                AddressSelectionCountriesFetch(managedObject: $0)
            }
            .map { $0.first }
            .eraseToAnyPublisher()
    }
    
    func clearAddressSelectionCountriesFetch(forLocaleCode localeCode: String) -> AnyPublisher<Bool, Error> {
        return persistentStore
            .update { context in
                
                try AddressSelectionCountriesFetchMO.delete(
                    fetchRequest: AddressSelectionCountriesFetchMO.fetchRequestResultForDeletion(
                        forLocaleCode: localeCode
                    ),
                    in: context
                )
                
                return true
            }
    }
    
    func store(countries: [AddressSelectionCountry]?, forLocaleCode localeCode: String) -> AnyPublisher<AddressSelectionCountriesFetch?, Error> {
        return persistentStore
            .update { context in
                
                let countriesFetch = AddressSelectionCountriesFetch(
                    countries: countries,
                    fetchLocaleCode: localeCode,
                    fetchTimestamp: nil
                )
                
                guard let addressSelectionCountriesFetchMO = countriesFetch.store(in: context) else {
                    throw AddressServiceError.unableToPersistResult
                }
                
                return AddressSelectionCountriesFetch(managedObject: addressSelectionCountriesFetchMO)
            }
    }
    
}

// MARK: - Fetch Requests

extension AddressesSearchMO {
    
    static func fetchRequestResultForDeletion(
        postcode: String,
        countryCode: String
    ) -> NSFetchRequest<NSFetchRequestResult> {
        let request = newFetchRequestResult()
        
        // match this functions parameters and also delete any
        // records that have expired
        
        let query = "timestamp < %@ OR (fetchPostcode == %@ AND fetchCountryCode == %@)"
        let arguments: [Any] = [
            AppV2Constants.Business.addressesCachedExpiry as NSDate,
            postcode,
            countryCode
        ]
        
        request.predicate = NSPredicate(format: query, argumentArray: arguments)

        // no fetch limit because multiple expired records can be matched
        return request
    }
    
    static func addressesSearchFetchRequest(
        postcode: String,
        countryCode: String
    ) -> NSFetchRequest<AddressesSearchMO> {
        let request = newFetchRequest()

        // fields that will always be present
        let query = "fetchPostcode == %@ AND fetchCountryCode == %@"
        let arguments: [Any] = [
            postcode,
            countryCode
        ]
        
        request.predicate = NSPredicate(format: query, argumentArray: arguments)
        request.fetchLimit = 1
        
        return request
    }
    
}

extension AddressSelectionCountriesFetchMO {
    
    static func fetchRequestResultForDeletion(
        forLocaleCode localeCode: String
    ) -> NSFetchRequest<NSFetchRequestResult> {
        let request = newFetchRequestResult()
        
        // match this functions parameters and also delete any
        // records that have expired
        
        let query = "timestamp < %@ OR fetchLocaleCode == %@"
        let arguments: [Any] = [
            AppV2Constants.Business.addressesCachedExpiry as NSDate,
            localeCode
        ]
        
        request.predicate = NSPredicate(format: query, argumentArray: arguments)

        // no fetch limit because multiple expired records can be matched
        return request
    }

    static func addressSelectionCountriesFetchRequest(
        forLocaleCode localeCode: String
    ) -> NSFetchRequest<AddressSelectionCountriesFetchMO> {
        let request = newFetchRequest()

        // fields that will always be present
        let query = "fetchLocaleCode == %@"
        let arguments: [Any] = [
            localeCode
        ]
        
        request.predicate = NSPredicate(format: query, argumentArray: arguments)
        request.fetchLimit = 1
        
        return request
    }
    
}
