//
//  RetailStoreService.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 16/09/2021.
//

import Combine
import Foundation
import CoreLocation
import OSLog

enum RetailStoresServiceError: Swift.Error {
    case invalidParameters([String])
    case fulfilmentLocationRequired
    case cannotUseWhenFoundStores
}

extension RetailStoresServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .invalidParameters(parameters):
            return "Parameters Error: \(parameters.joined(separator: ", "))"
        case .fulfilmentLocationRequired:
            return "Fulfilment location required from search."
        case .cannotUseWhenFoundStores:
            return "Service layer operation should only be called when no store candidates."
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
    func searchRetailStores(postcode: String) -> Future<Void, Error>
    func searchRetailStores(location: CLLocationCoordinate2D) -> Future<Void, Error>
    
    // The app needs a way of repeating the last search when restarting
    // (or potentially periodic refreshes). This function consults the
    // persistent store to identify the last postcode / location used, and
    // attempts to fetch in the latest information for the same criteria.
    // If a result can be succesfully obtained from the API the previously
    // cached data in the persistent store is automatically cleared. A
    // Future is used because the loadable App State UserData.searchResult
    // cannot represent a nil result.
    func repeatLastSearch() async throws
    
    // After the retail store search results have been been returned
    // further information can be obtained for a specific store relative
    // to their postcode and the delivery / collection days.
    func getStoreDetails(storeId: Int, postcode: String) -> Future<Void, Error>
    
    func restoreLastSelectedStore(postcode: String) async throws
        
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
    func getStoreTimeSlots(storeId: Int, startDate: Date, endDate: Date, method: RetailStoreOrderMethodType, location: CLLocationCoordinate2D?, clearCache: Bool) async throws -> RetailStoreTimeSlots?
    // When a search result returns no stores the customer can send their
    // for a future request if the store opens up in their area.
    // TODO: Implementation will change: https://snappyshopper.atlassian.net/browse/OAPIV2-560
    func futureContactRequest(email: String) async throws -> String?
}

struct RetailStoresService: RetailStoresServiceProtocol {

    let webRepository: RetailStoresWebRepositoryProtocol
    let dbRepository: RetailStoresDBRepositoryProtocol
    
    // For the service functions that are expected to update the
    // data that belongs to the AppState.
    let appState: Store<AppState>
    
    let eventLogger: EventLoggerProtocol
    
    private var cancelBag = CancelBag()

    init(webRepository: RetailStoresWebRepositoryProtocol, dbRepository: RetailStoresDBRepositoryProtocol, appState: Store<AppState>, eventLogger: EventLoggerProtocol) {
        self.webRepository = webRepository
        self.dbRepository = dbRepository
        self.appState = appState
        self.eventLogger = eventLogger
    }

    // convenience functions to avoid passing clearCache, cache handling will be needed in future
    func searchRetailStores(postcode: String) -> Future<Void, Error> {
        return searchRetailStores(postcode: postcode, clearCache: true)
    }
    
    func searchRetailStores(location: CLLocationCoordinate2D) -> Future<Void, Error> {
        return searchRetailStores(location: location, clearCache: true)
    }
    
    func getStoreDetails(storeId: Int, postcode: String) -> Future<Void, Error> {
        getStoreDetails(storeId: storeId, postcode: postcode, clearCache: true)
    }
    
    private func getStoreTimeSlots(slots: LoadableSubject<RetailStoreTimeSlots>, storeId: Int, startDate: Date, endDate: Date, method: RetailStoreOrderMethodType, location: CLLocationCoordinate2D?) {
        getStoreTimeSlots(slots: slots, storeId: storeId, startDate: startDate, endDate: endDate, method: method, location: location, clearCache: true)
    }
    
    func getStoreDeliveryTimeSlots(slots: LoadableSubject<RetailStoreTimeSlots>, storeId: Int, startDate: Date, endDate: Date, location: CLLocationCoordinate2D) {
        getStoreDeliveryTimeSlots(slots: slots, storeId: storeId, startDate: startDate, endDate: endDate, location: location, clearCache: true)
    }
    
    func getStoreCollectionTimeSlots(slots: LoadableSubject<RetailStoreTimeSlots>, storeId: Int, startDate: Date, endDate: Date) {
        getStoreCollectionTimeSlots(slots: slots, storeId: storeId, startDate: startDate, endDate: endDate, clearCache: true)
    }
    
    func searchRetailStores(postcode: String, clearCache: Bool) -> Future<Void, Error> {
        return Future() { promise in
            let cancelBag = CancelBag()
            guaranteeMainThread {
                appState.value.userData.searchResult.setIsLoading(cancelBag: cancelBag)
            }

            if clearCache {
                // delete the searches and then fetch from the API and store the result
                dbRepository
                    .clearSearches()
                    .flatMap { _ -> AnyPublisher<RetailStoresSearch?, Error> in
                        return self.loadAndStoreSearchFromWeb(postcode: postcode)
                    }
                    .sinkToLoadable { result in
                        guaranteeMainThread {
                            self.appState.value.userData.searchResult = result.unwrap()
                        }
                        promise(.success(()))
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
                    .sinkToLoadable { result in
                        guaranteeMainThread {
                            self.appState.value.userData.searchResult = result.unwrap()
                        }
                        promise(.success(()))
                    }
                    .store(in: cancelBag)
            }
        }
    }
    
    func searchRetailStores(location: CLLocationCoordinate2D, clearCache: Bool) -> Future<Void, Error> {
        return Future() { promise in
            let cancelBag = CancelBag()
            guaranteeMainThread {
                appState.value.userData.searchResult.setIsLoading(cancelBag: cancelBag)
            }
            
            if clearCache {
                // delete the searches and then fetch from the API and store the result
                dbRepository
                    .clearSearches()
                    .flatMap { _ -> AnyPublisher<RetailStoresSearch?, Error> in
                        return self.loadAndStoreSearchFromWeb(location: location)
                    }
                    .sinkToLoadable { result in
                        guaranteeMainThread {
                            self.appState.value.userData.searchResult = result.unwrap()
                        }
                        promise(.success(()))
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
                    .sinkToLoadable { result in
                        guaranteeMainThread {
                            self.appState.value.userData.searchResult = result.unwrap()
                        }
                        promise(.success(()))
                    }
                    .store(in: cancelBag)
            }
        }
    }
    
    func repeatLastSearch() async throws {
        let lastStoreSearch = try await dbRepository.lastStoresSearch().singleOutput()
        
        guard let unwrappedSearch = lastStoreSearch else { return }
        
        let webSearch = try await loadAndStoreSearchFromWeb(location: unwrappedSearch.fulfilmentLocation.location, clearCacheAfterNewFetchedResult: true).singleOutput()
        
        let result = try await restoreCurrentFulfilmentLocation(whenStoresSearch: webSearch).singleOutput()
        
        guard let unwrappedResult = result else { return }
        
        await MainActor.run {
            self.appState.value.userData.searchResult = .loaded(unwrappedResult)
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
    
    func getStoreDetails(storeId: Int, postcode: String, clearCache: Bool) -> Future<Void, Error> {
        return Future() { promise in
            appState.value.userData.selectedStore.setIsLoading(cancelBag: cancelBag)
            if clearCache {
                // delete the searches and then fetch from the API and store the result
                dbRepository
                    .clearRetailStoreDetails()
                    .flatMap { _ -> AnyPublisher<RetailStoreDetails?, Error> in
                        return self.loadAndStoreRetailStoreDetailsFromWeb(forStoreId: storeId, postcode: postcode)
                    }
                    .flatMap({ storeDetails -> AnyPublisher<RetailStoreDetails?, Error> in
                        return self.saveCurrentFulfilmentLocation(whenStoreDetails: storeDetails)
                    })
                    .sinkToLoadable {
                        let unwrappedResult = $0.unwrap()
                        guaranteeMainThread {
                            appState.value.userData.selectedStore = unwrappedResult
                        }
                        if unwrappedResult.value != nil {
                            eventLogger.sendEvent(
                                for: .selectStore,
                                with: .appsFlyer,
                                params: ["fulfilment_method" : appState.value.userData.selectedFulfilmentMethod.rawValue]
                            )
                        }
                        promise(.success(()))
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
                        let unwrappedResult = $0.unwrap()
                        guaranteeMainThread {
                            appState.value.userData.selectedStore = unwrappedResult
                        }
                        if unwrappedResult.value != nil {
                            eventLogger.sendEvent(
                                for: .selectStore,
                                with: .appsFlyer,
                                params: ["fulfilment_method" : appState.value.userData.selectedFulfilmentMethod.rawValue]
                            )
                        }
                        promise(.success(()))
                    }
                    .store(in: cancelBag)
            }
        }
    }
    
    func restoreLastSelectedStore(postcode: String) async throws {
        let lastSelectedStore = try await dbRepository.lastSelectedStore()
        
        guard let unwrappedSelectedStore = lastSelectedStore else { return }
        
        let result = try await loadAndStoreRetailStoreDetailsFromWeb(forStoreId: unwrappedSelectedStore.id, postcode: postcode, clearCacheAfterNewFetchedResult: true).singleOutput()
        
        guard let unwrappedResult = result else { return }
        
        await MainActor.run {
            self.appState.value.userData.selectedStore = .loaded(unwrappedResult)
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
    
    func getStoreTimeSlots(storeId: Int, startDate: Date, endDate: Date, method: RetailStoreOrderMethodType, location: CLLocationCoordinate2D?, clearCache: Bool) async throws -> RetailStoreTimeSlots? {
        if clearCache {
            let _ = try await dbRepository.clearRetailStoreTimeSlots().singleOutput()
            
            return try await loadAndStoreRetailStoreTimeSlotsFromWeb(forStoreId: storeId, startDate: startDate, endDate: endDate, method: method, location: location).singleOutput()
        } else {
            let timeSlots = try await dbRepository.retailStoreTimeSlots(forStoreId: storeId, startDate: startDate, endDate: endDate, method: method, location: location).singleOutput()
            if timeSlots != nil {
                return timeSlots
            } else {
                return try await loadAndStoreRetailStoreTimeSlotsFromWeb(forStoreId: storeId, startDate: startDate, endDate: endDate, method: method, location: location).singleOutput()
            }
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
    
    // TODO: Implementation will change: https://snappyshopper.atlassian.net/browse/OAPIV2-560
    func futureContactRequest(email: String) async throws -> String? {
        // check that there was a search so that the postcode can be forwaded
        guard let fulfilmentLocation = appState.value.userData.searchResult.value?.fulfilmentLocation else {
            throw RetailStoresServiceError.fulfilmentLocationRequired
        }
        // check that no store results could be found
        guard
            let stores = appState.value.userData.searchResult.value?.stores,
            stores.count > 0
        else {
            throw RetailStoresServiceError.cannotUseWhenFoundStores
        }
        
        let result = try await webRepository.futureContactRequest(email: email, postcode: fulfilmentLocation.postcode)
        if
            let errors = result.result.errors,
            let emailMessage = errors["email"]?.first,
            result.result.status == false
        {
            return emailMessage
        }
        
        return nil
    }
    
    private var requestHoldBackTimeInterval: TimeInterval {
        return ProcessInfo.processInfo.isRunningTests ? 0 : 0.5
    }
}

struct StubRetailStoresService: RetailStoresServiceProtocol {
    func getStoreDetails(storeId: Int, postcode: String)  -> Future<Void, Error> {
        return Future { promise in
            promise(.success(()))
        }
    }

    func searchRetailStores(postcode: String) -> Future<Void, Error> {
        return Future { promise in
            promise(.success(()))
        }
    }
    
    func searchRetailStores(location: CLLocationCoordinate2D) -> Future<Void, Error> {
        return Future { promise in
            promise(.success(()))
        }
    }
    
    func repeatLastSearch() async throws {}
    
    func restoreLastSelectedStore(postcode: String) async throws {}
    
    func getStoreDeliveryTimeSlots(slots: LoadableSubject<RetailStoreTimeSlots>, storeId: Int, startDate: Date, endDate: Date, location: CLLocationCoordinate2D) {}
    
    func getStoreCollectionTimeSlots(slots: LoadableSubject<RetailStoreTimeSlots>, storeId: Int, startDate: Date, endDate: Date) {}
    
    func getStoreTimeSlots(storeId: Int, startDate: Date, endDate: Date, method: RetailStoreOrderMethodType, location: CLLocationCoordinate2D?, clearCache: Bool) async throws -> RetailStoreTimeSlots? { return nil }
    
    func futureContactRequest(email: String) async throws -> String? { return nil }
    
}
