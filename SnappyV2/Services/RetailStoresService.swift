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

    // This retail service was implemented with Snappy Shopper in mind.
    // If a user searches for stores we expect the app to always fetch
    // the latest information from the server. I.e. not return data cached
    // in a persistent store. However, for future functionality the entire
    // result set is saved to the persistent store. At the time of coding
    // the intended pattern is to alway have clearCache = true so that the
    // service layer instead fetches the latest information. Hence, the
    // extension below so that the parameter can/should be ommited and
    // true by default.
    
    // Note: If clearCache is false then the app will not delete any
    // cached data and will attempt to first match the previous searched
    // postcode/location criteria and return results from the persistent
    // store without connecting to the server. If there is no match then
    // it will connect to the server. All the search results will be kept
    // in the persistent store until clearCache is true or
    // repeatLastSearch() is called.
    func searchRetailStores(postcode: String)
    func searchRetailStores(location: CLLocationCoordinate2D)
    
    // The app needs a way of repeating the last search when restarting
    // (or potentially periodic refreshes). This function consults the
    // persistent store to identify the last postcode / location used, and
    // attempts to fetch in the latest information for the same criteria.
    // If a result can be succesfully obtained from the API the previously
    // cached data in the persistent store is automatically cleared. A
    // Future is used because the loadable App State UserData.searchResult
    // cannot represent a nil result.
    func repeatLastSearch() -> Future<Void, Error>
    
    // After the retail store search results have been been returned
    // further information can be obtained for a specific store relative
    // to their postcode and the delivery / collection days.
    func getStoreDetails(storeId: Int, postcode: String)
    
    // When a store has been selected a time slot needs to be chosen.
    // Notes:
    // (1) The startDate: and endDate: should be the begining and end of a
    // day based on its time zone. The RetailStoreFulfilmentDay structure
    // has the corresponding storeDateStart and storeDateEnd values
    // (2) The location: is the coordinate corresponding to the customers
    // location. The API devs will add a fulfilmentLocation object, which
    // will be added to the RetailStoresSearch result.
    func getStoreDeliveryTimeSlots(slots: LoadableSubject<RetailStoreTimeSlots>, storeId: Int, startDate: Date, endDate: Date, location: CLLocationCoordinate2D)
    func getStoreCollectionTimeSlots(slots: LoadableSubject<RetailStoreTimeSlots>, storeId: Int, startDate: Date, endDate: Date)
}

struct RetailStoresService: RetailStoresServiceProtocol {

    let webRepository: RetailStoresWebRepositoryProtocol
    let dbRepository: RetailStoresDBRepositoryProtocol
    
    // For the service functions that are expected to update the
    // data that belongs to the AppState.
    let appState: Store<AppState>
    
    private var cancelBag = CancelBag()

    init(webRepository: RetailStoresWebRepositoryProtocol, dbRepository: RetailStoresDBRepositoryProtocol, appState: Store<AppState>) {
        self.webRepository = webRepository
        self.dbRepository = dbRepository
        self.appState = appState
    }

    // convenience functions to avoid passing clearCache, cache handling will be needed in future
    func searchRetailStores(postcode: String) {
        searchRetailStores(postcode: postcode, clearCache: true)
    }
    
    func searchRetailStores(location: CLLocationCoordinate2D) {
        searchRetailStores(location: location, clearCache: true)
    }
    
    func getStoreDetails(storeId: Int, postcode: String) {
        getStoreDetails(storeId: storeId, postcode: postcode, clearCache: true)
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
    
    func searchRetailStores(postcode: String, clearCache: Bool) {
        let cancelBag = CancelBag()
        appState.value.userData.searchResult.setIsLoading(cancelBag: cancelBag)

        if clearCache {
            // delete the searches and then fetch from the API and store the result
            dbRepository
                .clearSearches()
                .flatMap { _ -> AnyPublisher<RetailStoresSearch?, Error> in
                    return self.loadAndStoreSearchFromWeb(postcode: postcode)
                }
                .sinkToLoadable {
                    self.appState.value.userData.searchResult = $0.unwrap()
                }
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
                .sinkToLoadable {
                    self.appState.value.userData.searchResult = $0.unwrap()
                }
                .store(in: cancelBag)
        }
        
    }
    
    func searchRetailStores(location: CLLocationCoordinate2D, clearCache: Bool) {
        let cancelBag = CancelBag()
        appState.value.userData.searchResult.setIsLoading(cancelBag: cancelBag)

        if clearCache {
            // delete the searches and then fetch from the API and store the result
            dbRepository
                .clearSearches()
                .flatMap { _ -> AnyPublisher<RetailStoresSearch?, Error> in
                    return self.loadAndStoreSearchFromWeb(location: location)
                }
                .sinkToLoadable {
                    self.appState.value.userData.searchResult = $0.unwrap()
                }
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
                .sinkToLoadable {
                    self.appState.value.userData.searchResult = $0.unwrap()
                }
                .store(in: cancelBag)
        }
    }
    
    func repeatLastSearch() -> Future<Void, Error> {
        return Future() { promise in
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
                .flatMap({ storesSearch -> AnyPublisher<RetailStoresSearch?, Error> in
                    self.restoreCurrentFulfilmentLocation(whenStoresSearch: storesSearch)
                })
                .sinkToResult { result in
                    switch result {
                    case let .success(resultValue):
                        if let searchResult = resultValue {
                            self.appState.value.userData.searchResult = .loaded(searchResult)
                        }
                        promise(.success(()))
                    case let .failure(error):
                        promise(.failure(error))
                    }
                }
                .store(in: cancelBag)
        }
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
            .receive(on: RunLoop.main)
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
    
    func getStoreDetails(storeId: Int, postcode: String, clearCache: Bool) {
        let cancelBag = CancelBag()
        appState.value.userData.selectedStore.setIsLoading(cancelBag: cancelBag)

        if clearCache {
            // delete the searches and then fetch from the API and store the result
            dbRepository
                .clearRetailStoreDetails()
                .flatMap { _ -> AnyPublisher<RetailStoreDetails?, Error> in
                    return self.loadAndStoreRetailStoreDetailsFromWeb(forStoreId: storeId, postcode: postcode)
                }
                .flatMap({ storeDetails -> AnyPublisher<RetailStoreDetails?, Error> in
                    self.saveCurrentFulfilmentLocation(whenStoreDetails: storeDetails)
                })
                .sinkToLoadable {
                    appState.value.userData.selectedStore = $0.unwrap()
                }
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
                .flatMap({ storeDetails -> AnyPublisher<RetailStoreDetails?, Error> in
                    self.saveCurrentFulfilmentLocation(whenStoreDetails: storeDetails)
                })
                .sinkToLoadable {
                    appState.value.userData.selectedStore = $0.unwrap()
                    
                }
                .store(in: cancelBag)
        }
    }
    
    private func saveCurrentFulfilmentLocation(whenStoreDetails store: RetailStoreDetails?) -> AnyPublisher<RetailStoreDetails?, Error> {
        if
            let store = store,
            let fulfilmentLocation = appState.value.userData.searchResult.value?.fulfilmentLocation
        {
            return dbRepository
                .clearFulfilmentLocation()
                .flatMap { _ -> AnyPublisher<FulfilmentLocation?, Error> in
                    dbRepository.store(fulfilmentLocation: fulfilmentLocation)
                }
                .flatMap { fulfilmentLocation -> AnyPublisher<RetailStoreDetails?, Error> in
                    if let fulfilmentLocation = fulfilmentLocation {
                        appState.value.userData.currentFulfilmentLocation = fulfilmentLocation
                    }
                    return Just<RetailStoreDetails?>.withErrorType(store, Error.self)
                }
                .eraseToAnyPublisher()
        } else {
            return Just<RetailStoreDetails?>.withErrorType(store, Error.self)
        }
    }
    
    private func restoreCurrentFulfilmentLocation(whenStoresSearch search: RetailStoresSearch?) -> AnyPublisher<RetailStoresSearch?, Error> {
        if let search = search {
            return dbRepository
                .currentFulfilmentLocation()
                .flatMap { fulfilmentLocation -> AnyPublisher<RetailStoresSearch?, Error> in
                    if let fulfilmentLocation = fulfilmentLocation {
                        appState.value.userData.currentFulfilmentLocation = fulfilmentLocation
                    }
                    return Just<RetailStoresSearch?>.withErrorType(search, Error.self)
                }
                .eraseToAnyPublisher()
        } else {
            return Just<RetailStoresSearch?>.withErrorType(search, Error.self)
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
            .receive(on: RunLoop.main)
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
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    private var requestHoldBackTimeInterval: TimeInterval {
        return ProcessInfo.processInfo.isRunningTests ? 0 : 0.5
    }
}

struct StubRetailStoresService: RetailStoresServiceProtocol {

    func getStoreDetails(storeId: Int, postcode: String) {}

    func searchRetailStores(postcode: String) {}
    
    func searchRetailStores(location: CLLocationCoordinate2D) {}
    
    func repeatLastSearch() -> Future<Void, Error> {
        return Future { promise in
            promise(.success(()))
        }
    }
    
    func getStoreDeliveryTimeSlots(slots: LoadableSubject<RetailStoreTimeSlots>, storeId: Int, startDate: Date, endDate: Date, location: CLLocationCoordinate2D) {}
    
    func getStoreCollectionTimeSlots(slots: LoadableSubject<RetailStoreTimeSlots>, storeId: Int, startDate: Date, endDate: Date) {}
    
}
