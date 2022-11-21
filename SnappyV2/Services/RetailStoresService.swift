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
import AppsFlyerLib

enum RetailStoresServiceError: Swift.Error, Equatable {
    case invalidParameters([String])
    case fulfilmentLocationRequired
    case cannotUseWhenFoundStores
    case postcodeFormatNotRecognised(String)
    case cannotSendStoreReview(String)
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
        case let .postcodeFormatNotRecognised(postcode):
            return Strings.General.Search.Customisable.postcodeFormatError.localizedFormat(postcode)
        case let .cannotSendStoreReview(message):
            return message
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
    
    func sendReview(for: RetailStoreReview, rating: Int, comments: String?) async throws -> String
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
        if
            let businessProfile = appState.value.businessData.businessProfile,
            let postcodeRules = businessProfile.postcodeRules,
            postcode.isPostcode(rules: postcodeRules) == false
        {
            return Future() { promise in
                promise(.failure(RetailStoresServiceError.postcodeFormatNotRecognised(postcode)))
            }
        }
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
                        if let error = result.error {
                            #warning("Sink logic to change as backend team working on different error format.")
                            // Current logic: error returned for invalid postcode is not in the APIErrorResult format.
                            // Therefore, if we cannot unwrap as? APRErrorResult we know postcode is likely invalid.
                            // If postcode is invalid, we do NOT want to update the appState search results because the user
                            // should still see their last results. Instead we just cancel loading.
                            // In future: we will switch this logic to check the error code instead and proceed accordingly
                            guaranteeMainThread {
                                if let error = error as? APIErrorResult {
                                    self.appState.value.userData.searchResult = result.unwrap()
                                    promise(.failure(error))
                                } else {
                                    self.appState.value.userData.searchResult.cancelLoading()
                                    promise(.failure(error))
                                }
                            }
                        } else {
                            let unwrappedResult = result.unwrap()
                        	guaranteeMainThread {
                            	self.appState.value.userData.searchResult = unwrappedResult
                        	}
                        	if let unwrapped = unwrappedResult.value {
                            	sendAppsFlyerStoreSearchEvent(searchResult: unwrapped)
                        	}
                                                 
                        	promise(.success(()))
                        }
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
                        if let error = result.error {
                            guaranteeMainThread {
                                self.appState.value.userData.searchResult = result.unwrap()
                            }
							promise(.failure(error))
                        } else {
                            let unwrappedResult = result.unwrap()
                        	guaranteeMainThread {
                            	self.appState.value.userData.searchResult = unwrappedResult
                        	}
                        	if let unwrapped = unwrappedResult.value {
                            	sendAppsFlyerStoreSearchEvent(searchResult: unwrapped)
                        	}
                            
                            promise(.success(()))
                        }
                    }
                    .store(in: cancelBag)
            }
        }
    }
    
    private func sendAppsFlyerStoreSearchEvent(searchResult: RetailStoresSearch) {
        
        var appsFlyerParams: [String: Any] = [:]
        appsFlyerParams[AFEventParamSearchString] = searchResult.fulfilmentLocation.postcode
        appsFlyerParams[AFEventParamLat] = searchResult.fulfilmentLocation.latitude
        appsFlyerParams[AFEventParamLong] = searchResult.fulfilmentLocation.longitude
        
        var deliveryStoreIds: [Int] = []
        var collectionStoreIds: [Int] = []
        
        if let stores = searchResult.stores {
            deliveryStoreIds = stores.filter { $0.orderMethods?[RetailStoreOrderMethodType.delivery.rawValue]?.name == .delivery }.map { $0.id }
            collectionStoreIds = stores.filter { $0.orderMethods?[RetailStoreOrderMethodType.collection.rawValue]?.name == .collection }.map { $0.id }

            appsFlyerParams["delivery_stores"] = deliveryStoreIds
            appsFlyerParams["num_delivery_stores"] = deliveryStoreIds.count
            appsFlyerParams["collection_stores"] = collectionStoreIds
            appsFlyerParams["num_collection_stores"] = collectionStoreIds.count
        }
        
        eventLogger.sendEvent(for: .storeSearch, with: .appsFlyer, params: appsFlyerParams)
        
        var iterableParams: [String: Any] = [:]
        iterableParams["postalCode"] = searchResult.fulfilmentLocation.postcode
        iterableParams["lat"] = searchResult.fulfilmentLocation.latitude
        iterableParams["long"] = searchResult.fulfilmentLocation.longitude
        iterableParams["totalDeliveryStoresFound"] = deliveryStoreIds.count
        iterableParams["deliveryStoreIdsFound"] = deliveryStoreIds
        iterableParams["totalCollectionStoresFound"] = collectionStoreIds.count
        iterableParams["collectionStoreIdsFound"] = collectionStoreIds
        
        eventLogger.sendEvent(for: .storeSearch, with: .iterable, params: iterableParams)
        
        var openStoreFound = false
        var closedStoreFound = false
        if let stores = searchResult.stores {
            outerLoop: for store in stores {
                if let orderMethods = store.orderMethods {
                    for orderMethod in orderMethods.values {
                        if orderMethod.status == .closed {
                            closedStoreFound = true
                        } else {
                            // preorder and open are considered "open"
                            openStoreFound = true
                            // once at least one open store is found
                            // no need to continue checking
                            break outerLoop
                        }
                    }
                }
            }
        }
        let firebaseParams: [String: Any] = [
            "store_search_result": openStoreFound ? "open" : (closedStoreFound ? "closed" : "no_store")
        ]
        
        eventLogger.sendEvent(for: .storeSearch, with: .firebaseAnalytics, params: firebaseParams)
    }
    
//    func sendSearchStoresEvent(
//        matchedStoreIds: [Int],
//        matchingClosedDeliveryStoresIds: [Int],
//        lastOrderMode: LastOrderMode,
//        stores: OrderedDictionary<Int, Store>,
//        storesLocationData: OrderedDictionary<Int, StoreUserLocationData>,
//        postalCode: String?,
//        cordinates: CLLocation?
//    ) {
//        if initialised {
//
//            var dataFields: [AnyHashable: Any] = [:]
//
//            if let postalCode = postalCode {
//                dataFields["postalCode"] = postalCode
//            }
//
//            if let cordinates = cordinates {
//                dataFields["lat"] = cordinates.coordinate.latitude
//                dataFields["long"] = cordinates.coordinate.longitude
//            }
//
//            var deliveryStoreIdsFound: [Int] = []
//            var collectionStoreIdsFound: [Int] = []
//
//            for storeId in matchedStoreIds {
//                if
//                    let locationData: StoreUserLocationData = storesLocationData[storeId],
//                    let store: Store = stores[storeId]
//                {
//                    // review delivery
//                    var includeDeliveryStore = false
//                    if (store.useTimeTableSlots || store.indeterminateTimeText != nil) && locationData.canDeliver {
//                        includeDeliveryStore = true
//                    } else if store.earliestTimeForMethod(OrderMethodResult.deliver, withLocationData: locationData, lastOrderMode: lastOrderMode) != nil {
//                        includeDeliveryStore = true
//                    } else if locationData.nextOpenDelivery != nil && matchingClosedDeliveryStoresIds.contains(storeId) && locationData.canDeliver {
//                        includeDeliveryStore = true
//                    }
//
//                    if includeDeliveryStore {
//                        deliveryStoreIdsFound.append(storeId)
//                    }
//
//                    // review collection
//                    var includeCollectionStore = false
//                    if (store.useTimeTableSlots || store.indeterminateTimeText != nil) && store.hasCollections {
//                        includeCollectionStore = true
//                    } else if store.earliestTimeForMethod(OrderMethodResult.collect, withLocationData: locationData, lastOrderMode: lastOrderMode) != nil {
//                        includeCollectionStore = true
//                    }
//
//                    if includeCollectionStore {
//                        collectionStoreIdsFound.append(storeId)
//                    }
//                }
//            }
//
//            dataFields["totalDeliveryStoresFound"] = deliveryStoreIdsFound.count
//            dataFields["deliveryStoreIdsFound"] = deliveryStoreIdsFound
//            dataFields["totalCollectionStoresFound"] = collectionStoreIdsFound.count
//            dataFields["collectionStoreIdsFound"] = collectionStoreIdsFound
//
//            IterableAPI.track(
//                event: "searchStores",
//                dataFields: mergeWhiteLabelFields(dataFields)
//            )
//        }
//    }
    
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
                            clearStoreMenu()
                            appState.value.userData.selectedStore = unwrappedResult
                        }
                        if unwrappedResult.value != nil {
                            sendAppsFlyerStoreSelectEvent(storeId: storeId, fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod)
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
                            clearStoreMenu()
                            appState.value.userData.selectedStore = unwrappedResult
                        }
                        if unwrappedResult.value != nil {
                            sendAppsFlyerStoreSelectEvent(storeId: storeId, fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod)
                        }
                        promise(.success(()))
                    }
                    .store(in: cancelBag)
            }
        }
    }
    
    private func clearStoreMenu() {
        appState.value.storeMenu.rootCategories = []
        appState.value.storeMenu.subCategories = []
        appState.value.storeMenu.unsortedItems = []
        appState.value.storeMenu.specialOfferItems = []
    }
    
    private func sendAppsFlyerStoreSelectEvent(storeId: Int, fulfilmentMethod: RetailStoreOrderMethodType) {
        let params: [String: Any] = [
            "store_id": storeId,
            "fulfilment_method": fulfilmentMethod.rawValue
        ]
        eventLogger.sendEvent(for: .selectStore, with: .appsFlyer, params: params)
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
        guard (appState.value.userData.searchResult.value?.stores?.count ?? 0) == 0 else {
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
        
        if let searchResult = appState.value.userData.searchResult.value {
            sendFutureContactEvent(searchResult: searchResult)
        }
        
        return nil
    }
    
    private func sendFutureContactEvent(searchResult: RetailStoresSearch) {
        let appsFlyerParams: [String: Any] = [
            "contact_postcode": searchResult.fulfilmentLocation.postcode,
            AFEventParamLat: searchResult.fulfilmentLocation.latitude,
            AFEventParamLong: searchResult.fulfilmentLocation.longitude
        ]
        
        eventLogger.sendEvent(for: .futureContact, with: .appsFlyer, params: appsFlyerParams)
        
        let firebaseParams: [String: Any] = [
            "search_text": searchResult.fulfilmentLocation.postcode
        ]
        
        eventLogger.sendEvent(for: .futureContact, with: .firebaseAnalytics, params: firebaseParams)
    }
    
    func sendReview(for review: RetailStoreReview, rating: Int, comments: String?) async throws -> String {
        let result = try await webRepository.sendRetailStoreCustomerRating(
            orderId: review.orderId,
            hash: review.hash,
            rating: rating,
            comments: comments
        )
        if result.status == false {
            throw RetailStoresServiceError.cannotSendStoreReview(result.message)
        }
        return result.message
    }
    
    private var requestHoldBackTimeInterval: TimeInterval {
        return ProcessInfo.processInfo.isRunningTests ? 0 : 0.5
    }
}

struct StubRetailStoresService: RetailStoresServiceProtocol {
    func sendReview(for: RetailStoreReview, rating: Int, comments: String?) async throws -> String {
        return "Review Sent"
    }
    
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
