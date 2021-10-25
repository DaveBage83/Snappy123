//
//  RetailStoreService.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 16/09/2021.
//

import Combine
import Foundation
import CoreLocation

enum RetailStoresServiceError: Swift.Error {
    case invalidParameters([String])
}

extension RetailStoresServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .invalidParameters(parameters):
            return "Parameters Error: \(parameters.joined(separator: ", "))"
        }
    }
}

protocol RetailStoresServiceProtocol {

    // This retail service was implemented with Snappy Shopper in mind. If a user searches for stores we expect
    // the app to always fetch the latest information from the server. I.e. not return data cached in a
    // persistent store. However, for future functionality the entire result set is saved to the persistent
    // store. At the time of coding the intended pattern is to alway have clearCache = true so that the
    // service layer instead fetches the latest information. Hence, the extension below so that the parameter
    // can/should be ommited and true by default.
    
    // Note: If clearCache is false then the app will not delete any cached data and will attempt to first match
    // the previous searched postcode/location criteria and return results from the persistent store without
    // connecting to the server. If there is no match then it will connect to the server. All the search results
    // will be kept in the persistent store until clearCache is true or repeatLastSearch(search:) is called.
    func searchRetailStores(search: LoadableSubject<RetailStoresSearch>, postcode: String)
    func searchRetailStores(search: LoadableSubject<RetailStoresSearch>, location: CLLocationCoordinate2D)
    
    // The app needs a way of repeating the last search when restarting (or potentially periodic refreshes).
    // This function consults the persistent store to identify the last postcode / location used, and
    // attempts to fetch in the latest information for the same criteria. If a result can be succesfully
    // obtained from the API the previously cached data in the persistent store is automatically cleared.
    func repeatLastSearch(search: LoadableSubject<RetailStoresSearch>)
    
    // After the retail store search results have been been returned further information can be obtained
    // for a specific store relative to their postcode and the delivery / collection days.
    func getStoreDetails(details: LoadableSubject<RetailStoreDetails>, storeId: Int, postcode: String)
    
    // When a store has been selected a time slot needs to be chosen. Notes:
    // (1) The startDate: and endDate: should be the begining and end of a day based on its time zone. The
    // RetailStoreFulfilmentDay structure has the corresponding storeDateStart and storeDateEnd values
    // (2) The location: is the coordinate corresponding to the customers location. The API devs will add
    // a fulfilmentLocation object, which will be added to the RetailStoresSearch result.
    func getStoreDeliveryTimeSlots(slots: LoadableSubject<RetailStoreTimeSlots>, storeId: Int, startDate: Date, endDate: Date, location: CLLocationCoordinate2D)
    func getStoreCollectionTimeSlots(slots: LoadableSubject<RetailStoreTimeSlots>, storeId: Int, startDate: Date, endDate: Date)
}

struct RetailStoresService: RetailStoresServiceProtocol {

    let webRepository: RetailStoresWebRepositoryProtocol
    let dbRepository: RetailStoresDBRepositoryProtocol

    init(webRepository: RetailStoresWebRepositoryProtocol, dbRepository: RetailStoresDBRepositoryProtocol) {
        self.webRepository = webRepository
        self.dbRepository = dbRepository
    }

    // convenience functions to avoid passing clearCache, cache handling will be needed in future
    func searchRetailStores(search: LoadableSubject<RetailStoresSearch>, postcode: String) {
        searchRetailStores(search: search, postcode: postcode, clearCache: true)
    }
    
    func searchRetailStores(search: LoadableSubject<RetailStoresSearch>, location: CLLocationCoordinate2D) {
        searchRetailStores(search: search, location: location, clearCache: true)
    }
    
    func getStoreDetails(details: LoadableSubject<RetailStoreDetails>, storeId: Int, postcode: String) {
        getStoreDetails(details: details, storeId: storeId, postcode: postcode, clearCache: true)
    }
    
    func getStoreTimeSlots(slots: LoadableSubject<RetailStoreTimeSlots>, storeId: Int, startDate: Date, endDate: Date, method: RetailStoreOrderMethodType, location: CLLocationCoordinate2D?) {
        getStoreTimeSlots(slots: slots, storeId: storeId, startDate: startDate, endDate: endDate, method: method, location: location, clearCache: true)
    }
    
    func getStoreDeliveryTimeSlots(slots: LoadableSubject<RetailStoreTimeSlots>, storeId: Int, startDate: Date, endDate: Date, location: CLLocationCoordinate2D) {
        getStoreDeliveryTimeSlots(slots: slots, storeId: storeId, startDate: startDate, endDate: endDate, location: location, clearCache: true)
    }
    
    func getStoreCollectionTimeSlots(slots: LoadableSubject<RetailStoreTimeSlots>, storeId: Int, startDate: Date, endDate: Date) {
        getStoreCollectionTimeSlots(slots: slots, storeId: storeId, startDate: startDate, endDate: endDate, clearCache: true)
    }
    
    func searchRetailStores(search: LoadableSubject<RetailStoresSearch>, postcode: String, clearCache: Bool) {
        let cancelBag = CancelBag()
        search.wrappedValue.setIsLoading(cancelBag: cancelBag)

        if clearCache {
            // delete the searches and then fetch from the API and store the result
            dbRepository
                .clearSearches()
                .flatMap { _ -> AnyPublisher<RetailStoresSearch?, Error> in
                    return self.loadAndStoreSearchFromWeb(postcode: postcode)
                }
                .sinkToLoadable { search.wrappedValue = $0.unwrap() }
                .store(in: cancelBag)
                
        } else {
            // look for a result in the database and if no matches then fetch from
            // the API and store the result
            dbRepository
                .retailStoresSearch(forPostcode: postcode)
                .flatMap { storesSearch -> AnyPublisher<RetailStoresSearch?, Error> in
                    if storesSearch != nil {
                        // return the result in the database
                        return Just<RetailStoresSearch?>.withErrorType(storesSearch, Error.self)
                    } else {
                        return self.loadAndStoreSearchFromWeb(postcode: postcode)
                    }
                }
                .sinkToLoadable { search.wrappedValue = $0.unwrap() }
                .store(in: cancelBag)
        }
        
    }
    
    func searchRetailStores(search: LoadableSubject<RetailStoresSearch>, location: CLLocationCoordinate2D, clearCache: Bool) {
        let cancelBag = CancelBag()
        search.wrappedValue.setIsLoading(cancelBag: cancelBag)

        if clearCache {
            // delete the searches and then fetch from the API and store the result
            dbRepository
                .clearSearches()
                .flatMap { _ -> AnyPublisher<RetailStoresSearch?, Error> in
                    return self.loadAndStoreSearchFromWeb(location: location)
                }
                .sinkToLoadable { search.wrappedValue = $0.unwrap() }
                .store(in: cancelBag)
                
        } else {
            // look for a result in the database and if no matches then fetch from
            // the API and store the result
            dbRepository
                .retailStoresSearch(forLocation: location)
                .flatMap { storesSearch -> AnyPublisher<RetailStoresSearch?, Error> in
                    if storesSearch != nil {
                        // return the result in the database
                        return Just<RetailStoresSearch?>.withErrorType(storesSearch, Error.self)
                    } else {
                        return self.loadAndStoreSearchFromWeb(location: location)
                    }
                }
                .sinkToLoadable { search.wrappedValue = $0.unwrap() }
                .store(in: cancelBag)
        }
    }
    
    func repeatLastSearch(search: LoadableSubject<RetailStoresSearch>) {
        let cancelBag = CancelBag()
        search.wrappedValue.setIsLoading(cancelBag: cancelBag)
        
        dbRepository
            .lastStoresSearch()
            .flatMap { storesSearch -> AnyPublisher<RetailStoresSearch?, Error> in
                guard let storesSearch = storesSearch else {
                    // no previous result to search
                    return Just<RetailStoresSearch?>.withErrorType(nil, Error.self)
                }
                
                // do not use loadAndStoreSearchFromWeb(postcode: clearCacheAfterNewFetchedResult:)
                // since the search may have been performed with the location services and
                // we do not want the repeated search to introduce approximation
                return loadAndStoreSearchFromWeb(
                    location: storesSearch.fulfilmentLocation.location,
                    clearCacheAfterNewFetchedResult: true
                )
            }
            .sinkToLoadable { search.wrappedValue = $0.unwrap() }
            .store(in: cancelBag)
    }

    private func loadAndStoreSearchFromWeb(postcode: String, clearCacheAfterNewFetchedResult: Bool = false) -> AnyPublisher<RetailStoresSearch?, Error> {
        return webRepository
            .loadRetailStores(postcode: postcode)
            .ensureTimeSpan(requestHoldBackTimeInterval)
            .flatMap { storesSearch -> AnyPublisher<RetailStoresSearch?, Error> in
                if clearCacheAfterNewFetchedResult {
                    return dbRepository
                        .clearSearches()
                        .flatMap { _ -> AnyPublisher<RetailStoresSearch?, Error> in
                            dbRepository.store(searchResult: storesSearch, forPostode: postcode)
                        }
                        .eraseToAnyPublisher()
                } else {
                    return dbRepository.store(searchResult: storesSearch, forPostode: postcode)
                }
            }
            .eraseToAnyPublisher()
    }
    
    private func loadAndStoreSearchFromWeb(location: CLLocationCoordinate2D, clearCacheAfterNewFetchedResult: Bool = false) -> AnyPublisher<RetailStoresSearch?, Error> {
        return webRepository
            .loadRetailStores(location: location)
            .ensureTimeSpan(requestHoldBackTimeInterval)
            .flatMap { storesSearch -> AnyPublisher<RetailStoresSearch?, Error> in
                if clearCacheAfterNewFetchedResult {
                    return dbRepository
                        .clearSearches()
                        .flatMap { _ -> AnyPublisher<RetailStoresSearch?, Error> in
                            dbRepository.store(searchResult: storesSearch, location: location)
                        }
                        .eraseToAnyPublisher()
                } else {
                    return dbRepository.store(searchResult: storesSearch, location: location)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func getStoreDetails(details: LoadableSubject<RetailStoreDetails>, storeId: Int, postcode: String, clearCache: Bool) {
        let cancelBag = CancelBag()
        details.wrappedValue.setIsLoading(cancelBag: cancelBag)

        if clearCache {
            // delete the searches and then fetch from the API and store the result
            dbRepository
                .clearRetailStoreDetails()
                .flatMap { _ -> AnyPublisher<RetailStoreDetails?, Error> in
                    return self.loadAndStoreRetailStoreDetailsFromWeb(forStoreId: storeId, postcode: postcode)
                }
                .sinkToLoadable { details.wrappedValue = $0.unwrap() }
                .store(in: cancelBag)
                
        } else {
            // look for a result in the database and if no matches then fetch from
            // the API and store the result
            dbRepository
                .retailStoreDetails(forStoreId: storeId, postcode: postcode)
                .flatMap { storeDetails -> AnyPublisher<RetailStoreDetails?, Error> in
                    if storeDetails != nil {
                        // return the result in the database
                        return Just<RetailStoreDetails?>.withErrorType(storeDetails, Error.self)
                    } else {
                        return self.loadAndStoreRetailStoreDetailsFromWeb(forStoreId: storeId, postcode: postcode)
                    }
                }
                .sinkToLoadable { details.wrappedValue = $0.unwrap() }
                .store(in: cancelBag)
        }
    }
    
    private func loadAndStoreRetailStoreDetailsFromWeb(forStoreId storeId: Int, postcode: String, clearCacheAfterNewFetchedResult: Bool = false) -> AnyPublisher<RetailStoreDetails?, Error> {
        return webRepository
            .loadRetailStoreDetails(storeId: storeId, postcode: postcode)
            .ensureTimeSpan(requestHoldBackTimeInterval)
            .flatMap { detailsResult -> AnyPublisher<RetailStoreDetails?, Error> in
                if clearCacheAfterNewFetchedResult {
                    return dbRepository
                        .clearRetailStoreDetails()
                        .flatMap { _ -> AnyPublisher<RetailStoreDetails?, Error> in
                            dbRepository.store(storeDetails: detailsResult, forPostode: postcode)
                        }
                        .eraseToAnyPublisher()
                } else {
                    return dbRepository.store(storeDetails: detailsResult, forPostode: postcode)
                }
            }
            .eraseToAnyPublisher()
    }
    
    // if the method: is delivery then the location: should not be nil
    func getStoreDeliveryTimeSlots(slots: LoadableSubject<RetailStoreTimeSlots>, storeId: Int, startDate: Date, endDate: Date, location: CLLocationCoordinate2D, clearCache: Bool) {
        getStoreTimeSlots(
            slots: slots,
            storeId: storeId,
            startDate: startDate,
            endDate: endDate,
            method: .delivery,
            location: location, // API would return an error if not passed for delivery
            clearCache: clearCache
        )
    }
    
    func getStoreCollectionTimeSlots(slots: LoadableSubject<RetailStoreTimeSlots>, storeId: Int, startDate: Date, endDate: Date, clearCache: Bool) {
        getStoreTimeSlots(
            slots: slots,
            storeId: storeId,
            startDate: startDate,
            endDate: endDate,
            method: .collection,
            location: nil,
            clearCache: clearCache
        )
    }
    
    private func getStoreTimeSlots(slots: LoadableSubject<RetailStoreTimeSlots>, storeId: Int, startDate: Date, endDate: Date, method: RetailStoreOrderMethodType, location: CLLocationCoordinate2D?, clearCache: Bool) {
        let cancelBag = CancelBag()
        slots.wrappedValue.setIsLoading(cancelBag: cancelBag)

        if clearCache {
            // delete the searches and then fetch from the API and store the result
            dbRepository
                .clearRetailStoreTimeSlots()
                .flatMap { _ -> AnyPublisher<RetailStoreTimeSlots?, Error> in
                    return self.loadAndStoreRetailStoreTimeSlotsFromWeb(
                        forStoreId: storeId,
                        startDate: startDate,
                        endDate: endDate,
                        method: method,
                        location: location
                    )
                }
                .sinkToLoadable { slots.wrappedValue = $0.unwrap() }
                .store(in: cancelBag)
                
        } else {
            // look for a result in the database and if no matches then fetch from
            // the API and store the result
            dbRepository
                .retailStoreTimeSlots(forStoreId: storeId, startDate: startDate, endDate: endDate, method: method, location: location)
                .flatMap { timeSlots -> AnyPublisher<RetailStoreTimeSlots?, Error> in
                    if timeSlots != nil {
                        // return the result in the database
                        return Just<RetailStoreTimeSlots?>.withErrorType(timeSlots, Error.self)
                    } else {
                        return self.loadAndStoreRetailStoreTimeSlotsFromWeb(
                            forStoreId: storeId,
                            startDate: startDate,
                            endDate: endDate,
                            method: method,
                            location: location
                        )
                    }
                }
                .sinkToLoadable { slots.wrappedValue = $0.unwrap() }
                .store(in: cancelBag)
        }
    }
    
    private func loadAndStoreRetailStoreTimeSlotsFromWeb(forStoreId storeId: Int, startDate: Date, endDate: Date, method: RetailStoreOrderMethodType, location: CLLocationCoordinate2D?, clearCacheAfterNewFetchedResult: Bool = false) -> AnyPublisher<RetailStoreTimeSlots?, Error> {
        return webRepository
            .loadRetailStoreTimeSlots(storeId: storeId, startDate: startDate, endDate: endDate, method: method, location: location)
            .ensureTimeSpan(requestHoldBackTimeInterval)
            .flatMap { timeSlotsResult -> AnyPublisher<RetailStoreTimeSlots?, Error> in
                if clearCacheAfterNewFetchedResult {
                    return dbRepository
                        .clearRetailStoreTimeSlots()
                        .flatMap { _ -> AnyPublisher<RetailStoreTimeSlots?, Error> in
                            dbRepository.store(storeTimeSlots: timeSlotsResult, forStoreId: storeId, location: location)
                        }
                        .eraseToAnyPublisher()
                } else {
                    return dbRepository.store(storeTimeSlots: timeSlotsResult, forStoreId: storeId, location: location)
                }
            }
            .eraseToAnyPublisher()
    }
    
    private var requestHoldBackTimeInterval: TimeInterval {
        return ProcessInfo.processInfo.isRunningTests ? 0 : 0.5
    }
}

struct StubRetailStoresService: RetailStoresServiceProtocol {
    
    func getStoreDetails(details: LoadableSubject<RetailStoreDetails>, storeId: Int, postcode: String) {}

    func searchRetailStores(search: LoadableSubject<RetailStoresSearch>, postcode: String) {}
    
    func searchRetailStores(search: LoadableSubject<RetailStoresSearch>, location: CLLocationCoordinate2D) {}
    
    func repeatLastSearch(search: LoadableSubject<RetailStoresSearch>) {}
    
    func getStoreDeliveryTimeSlots(slots: LoadableSubject<RetailStoreTimeSlots>, storeId: Int, startDate: Date, endDate: Date, location: CLLocationCoordinate2D) {}
    
    func getStoreCollectionTimeSlots(slots: LoadableSubject<RetailStoreTimeSlots>, storeId: Int, startDate: Date, endDate: Date) {}
    
}
