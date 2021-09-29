//
//  RetailStoreService.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 16/09/2021.
//

import Combine
import Foundation
import CoreLocation

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
    func searchRetailStores(search: LoadableSubject<RetailStoresSearch>, postcode: String, clearCache: Bool)
    func searchRetailStores(search: LoadableSubject<RetailStoresSearch>, location: CLLocationCoordinate2D, clearCache: Bool)
    
    // The app needs a way of repeating the last search when restarting (or potentially periodic refreshes).
    // This function consults the persistent store to identify the last postcode / location used, and
    // attempts to fetch in the latest information for the same criteria. If a result can be succesfully
    // obtained from the API the previously cached data in the persistent store is automatically cleared.
    func repeatLastSearch(search: LoadableSubject<RetailStoresSearch>)
    
    // After the retail store search results have been been returned further information can be obtained
    // for a specific store relative to their postcode and the delivery / collection days.
    
    // Note: clearCache existings and follows the same patterns as above
    func getStoreDetails(details: LoadableSubject<RetailStoreDetails>, storeId: Int, postcode: String, clearCache: Bool)
}

// convenience functions to avoid passing clearCache:
extension RetailStoresServiceProtocol {
    
    func searchRetailStores(search: LoadableSubject<RetailStoresSearch>, postcode: String, clearCache: Bool = true) {
        searchRetailStores(search: search, postcode: postcode, clearCache: clearCache)
    }
    
    func searchRetailStores(search: LoadableSubject<RetailStoresSearch>, location: CLLocationCoordinate2D, clearCache: Bool = true) {
        searchRetailStores(search: search, location: location, clearCache: clearCache)
    }
    
    func getStoreDetails(details: LoadableSubject<RetailStoreDetails>, storeId: Int, postcode: String, clearCache: Bool = true) {
        getStoreDetails(details: details, storeId: storeId, postcode: postcode, clearCache: clearCache)
    }
}

struct RetailStoresService: RetailStoresServiceProtocol {
    
    let webRepository: RetailStoresWebRepositoryProtocol
    let dbRepository: RetailStoresDBRepositoryProtocol

    init(webRepository: RetailStoresWebRepositoryProtocol, dbRepository: RetailStoresDBRepositoryProtocol) {
        self.webRepository = webRepository
        self.dbRepository = dbRepository
    }
    
    // old
//    func searchRetailStores(postcode: String) -> AnyPublisher<Bool, Error> {
//        return webRepository.loadRetailStores(postcode: postcode)
//            .flatMap({ retailStoreResult -> AnyPublisher<Bool, Error> in
//
//                // populate the persitent store
//
//                // simply emit true if at least one store found
//                return Just(retailStoreResult.stores?.count ?? 0 != 0)
//                      .setFailureType(to: Error.self)
//                      .eraseToAnyPublisher()
//
//            }).eraseToAnyPublisher()
//    }
    
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
                if
                    let latitude = storesSearch.latitude,
                    let longitude = storesSearch.longitude
                {
                    let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    return loadAndStoreSearchFromWeb(location: location, clearCacheAfterNewFetchedResult: true)
                } else if let postcode = storesSearch.postcode {
                    return loadAndStoreSearchFromWeb(postcode: postcode, clearCacheAfterNewFetchedResult: true)
                }
                // should never get to this point as coordidinates or
                // postcode should always be present but if we do
                // then there was effectivily no search found
                return Just<RetailStoresSearch?>.withErrorType(nil, Error.self)
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
        
    }
    
    private var requestHoldBackTimeInterval: TimeInterval {
        return ProcessInfo.processInfo.isRunningTests ? 0 : 0.5
    }
}

struct StubRetailStoresService: RetailStoresServiceProtocol {
    
    // old
//    func searchRetailStores(postcode: String) -> AnyPublisher<Bool, Error> {
//        return Just(true)
//              .setFailureType(to: Error.self)
//              .eraseToAnyPublisher()
//    }
    
    func searchRetailStores(search: LoadableSubject<RetailStoresSearch>, postcode: String) {}
    
    func searchRetailStores(search: LoadableSubject<RetailStoresSearch>, location: CLLocationCoordinate2D) {}
    
    func repeatLastSearch(search: LoadableSubject<RetailStoresSearch>) {}
    
}
