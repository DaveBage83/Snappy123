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
    // old
    //func searchRetailStores(postcode: String) -> AnyPublisher<Bool, Error>
    
    func searchRetailStores(search: LoadableSubject<RetailStoresSearch>, postcode: String)
    func searchRetailStores(search: LoadableSubject<RetailStoresSearch>, location: CLLocationCoordinate2D)
    func clearLastSearch() -> AnyPublisher<Bool, Error>
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
    
    func searchRetailStores(search: LoadableSubject<RetailStoresSearch>, postcode: String) {
        let cancelBag = CancelBag()
        search.wrappedValue.setIsLoading(cancelBag: cancelBag)

        dbRepository
            .retailStoresSearch(forPostcode: postcode)
            .flatMap { storesSearch -> AnyPublisher<RetailStoresSearch?, Error> in
                if storesSearch != nil {
                    return Just<RetailStoresSearch?>.withErrorType(storesSearch, Error.self)
                } else {
                    return self.loadAndStoreSearchFromWeb(postcode: postcode)
                }
            }
            .sinkToLoadable { search.wrappedValue = $0.unwrap() }
            .store(in: cancelBag)
    }
    
    func searchRetailStores(search: LoadableSubject<RetailStoresSearch>, location: CLLocationCoordinate2D) {
        let cancelBag = CancelBag()
        search.wrappedValue.setIsLoading(cancelBag: cancelBag)

        dbRepository
            .retailStoresSearch(forLocation: location)
            .flatMap { storesSearch -> AnyPublisher<RetailStoresSearch?, Error> in
                if storesSearch != nil {
                    return Just<RetailStoresSearch?>.withErrorType(storesSearch, Error.self)
                } else {
                    return self.loadAndStoreSearchFromWeb(location: location)
                }
            }
            .sinkToLoadable { search.wrappedValue = $0.unwrap() }
            .store(in: cancelBag)
    }
    
    func clearLastSearch() -> AnyPublisher<Bool, Error> {
        return dbRepository
            .clearSearches()
    }
    
    private func loadAndStoreSearchFromWeb(postcode: String) -> AnyPublisher<RetailStoresSearch?, Error> {
        return webRepository
            .loadRetailStores(postcode: postcode)
            .ensureTimeSpan(requestHoldBackTimeInterval)
            .flatMap { [dbRepository] in
                dbRepository.store(searchResult: $0, forPostode: postcode)
            }
            .eraseToAnyPublisher()
    }
    
    private func loadAndStoreSearchFromWeb(location: CLLocationCoordinate2D) -> AnyPublisher<RetailStoresSearch?, Error> {
        return webRepository
            .loadRetailStores(location: location)
            .ensureTimeSpan(requestHoldBackTimeInterval)
            .flatMap { [dbRepository] in
                dbRepository.store(searchResult: $0, location: location)
            }
            .eraseToAnyPublisher()
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
    
    func clearLastSearch() -> AnyPublisher<Bool, Error> {
        return Just(true)
              .setFailureType(to: Error.self)
              .eraseToAnyPublisher()
    }
    
}
