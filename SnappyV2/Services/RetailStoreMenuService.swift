//
//  RetailStoreMenuService.swift
//  SnappyV2
//
//  Created by Kevin Palser on 28/09/2021.
//

import Combine
import Foundation

enum RetailStoreMenuServiceError: Swift.Error {
    case unableToPersistResult
    case noSelectedStore
    case invalidGetItemsCriteria
}

extension RetailStoreMenuServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .unableToPersistResult:
            return "Unable to persist web fetch result"
        case .noSelectedStore:
            return "Store needs to be selected to use this RetailStoreMenuService function"
        case .invalidGetItemsCriteria:
            return "menuItems (with at least one id) or discountId or discountSectionId required. Multiple criteria cannot be used."
        }
    }
}

protocol RetailStoreMenuServiceProtocol {
    
    // The following methods use the store id and the fulfilment
    // method in appState.value.userData. If no store is selected
    // then an error will be returned

    func getRootCategories(menuFetch: LoadableSubject<RetailStoreMenuFetch>)

    func getChildCategoriesAndItems(menuFetch: LoadableSubject<RetailStoreMenuFetch>, categoryId: Int)
    
    func globalSearch(
        searchFetch: LoadableSubject<RetailStoreMenuGlobalSearch>,
        searchTerm: String,
        scope: RetailStoreMenuGlobalSearchScope?,
        itemsPagination: (limit: Int, page: Int)?,
        categoriesPagination: (limit: Int, page: Int)?
    )
    
    func getItems(
        menuFetch: LoadableSubject<RetailStoreMenuFetch>,
        menuItemIds: [Int]?,
        discountId: Int?,
        discountSectionId: Int?
    )
}

struct RetailStoreMenuService: RetailStoreMenuServiceProtocol {
    
    let webRepository: RetailStoreMenuWebRepositoryProtocol
    let dbRepository: RetailStoreMenuDBRepositoryProtocol
    
    // Example in the clean architecture Countries exampe of the appState
    // being passed to a service (but not used the code). Using this as
    // a justification to be an acceptable method to update the Basket
    // Henrik/Kevin: 2021-10-26
    let appState: Store<AppState>
    
    let eventLogger: EventLoggerProtocol

    init(webRepository: RetailStoreMenuWebRepositoryProtocol, dbRepository: RetailStoreMenuDBRepositoryProtocol, appState: Store<AppState>, eventLogger: EventLoggerProtocol) {
        self.webRepository = webRepository
        self.dbRepository = dbRepository
        self.appState = appState
        self.eventLogger = eventLogger
    }
    
    func getRootCategories(menuFetch: LoadableSubject<RetailStoreMenuFetch>) {
        getMenu(
            menuFetch: menuFetch,
            categoryId: nil,
            fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod
        )
    }
    
    func getChildCategoriesAndItems(menuFetch: LoadableSubject<RetailStoreMenuFetch>, categoryId: Int) {
        getMenu(
            menuFetch: menuFetch,
            categoryId: categoryId,
            fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod
        )
    }
    
    func globalSearch(
        searchFetch: LoadableSubject<RetailStoreMenuGlobalSearch>,
        searchTerm: String,
        scope: RetailStoreMenuGlobalSearchScope?,
        itemsPagination: (limit: Int, page: Int)?,
        categoriesPagination: (limit: Int, page: Int)?
    ) {
        let cancelBag = CancelBag()
        searchFetch.wrappedValue.setIsLoading(cancelBag: cancelBag)
        
        guard let storeId = appState.value.userData.selectedStore.value?.id else {
            Fail(outputType: RetailStoreMenuGlobalSearch.self, failure: RetailStoreMenuServiceError.noSelectedStore)
                .eraseToAnyPublisher()
                .sinkToLoadable { searchFetch.wrappedValue = $0 }
                .store(in: cancelBag)
            return
        }
        
        if AppV2Constants.Business.attemptFreshMenuFetches {
            firstWebSearchBeforeCheckingStore(
                storeId: storeId,
                fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod,
                searchTerm: searchTerm,
                scope: scope,
                itemsPagination: itemsPagination,
                categoriesPagination: categoriesPagination
            )
                .sinkToLoadable { searchFetch.wrappedValue = $0 }
                .store(in: cancelBag)
        } else {
            firstCheckStoreBeforeSearchingFromWeb(
                storeId: storeId,
                fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod,
                searchTerm: searchTerm,
                scope: scope,
                itemsPagination: itemsPagination,
                categoriesPagination: categoriesPagination
            )
                .sinkToLoadable { searchFetch.wrappedValue = $0 }
                .store(in: cancelBag)
        }
    }
    
    func getItems(menuFetch: LoadableSubject<RetailStoreMenuFetch>, menuItemIds: [Int]?, discountId: Int?, discountSectionId: Int?) {
        let cancelBag = CancelBag()
        menuFetch.wrappedValue.setIsLoading(cancelBag: cancelBag)
        
        guard let storeId = appState.value.userData.selectedStore.value?.id else {
            Fail(outputType: RetailStoreMenuFetch.self, failure: RetailStoreMenuServiceError.noSelectedStore)
                .eraseToAnyPublisher()
                .sinkToLoadable { menuFetch.wrappedValue = $0 }
                .store(in: cancelBag)
            return
        }
        
        // check correct criteria and filter passing
        // down zero identifiers
        var validatedMenuItemIds: [Int]?
        var validatedDiscountId: Int?
        var validatedDiscountSectionId: Int?
        
        var validSearchCriteria: Int = 0
        if
            let menuItemIds = menuItemIds,
            menuItemIds.count > 0
        {
            validSearchCriteria = validSearchCriteria &+ 1
            validatedMenuItemIds = menuItemIds
        }
        if
            let discountId = discountId,
            discountId != 0
        {
            validSearchCriteria = validSearchCriteria &+ 1
            validatedDiscountId = discountId
        }
        if
            let discountSectionId = discountSectionId,
            discountSectionId != 0
        {
            validSearchCriteria = validSearchCriteria &+ 1
            validatedDiscountSectionId = discountSectionId
        }
        
        if validSearchCriteria != 1 {
            Fail(outputType: RetailStoreMenuFetch.self, failure: RetailStoreMenuServiceError.invalidGetItemsCriteria)
                .eraseToAnyPublisher()
                .sinkToLoadable { menuFetch.wrappedValue = $0 }
                .store(in: cancelBag)
            return
        }
        
        // Flow:
        // - after a sucessful web fetch always want to remove a previously stored result
        // - option to check for recently stored result vs always attempting a get
        
        if AppV2Constants.Business.attemptFreshMenuFetches {
            firstWebGetItemsBeforeCheckingStore(
                storeId: storeId,
                fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod,
                menuItemIds: validatedMenuItemIds,
                discountId: validatedDiscountId,
                discountSectionId: validatedDiscountSectionId
            )
                .sinkToLoadable { menuFetch.wrappedValue = $0 }
                .store(in: cancelBag)
        } else {
            firstCheckStoreBeforeGetItemsFromWeb(
                storeId: storeId,
                fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod,
                menuItemIds: validatedMenuItemIds,
                discountId: validatedDiscountId,
                discountSectionId: validatedDiscountSectionId
            )
                .sinkToLoadable { menuFetch.wrappedValue = $0 }
                .store(in: cancelBag)
        }
    }
    
    private func getMenu(menuFetch: LoadableSubject<RetailStoreMenuFetch>, categoryId: Int?, fulfilmentMethod: RetailStoreOrderMethodType) {
        let cancelBag = CancelBag()
        menuFetch.wrappedValue.setIsLoading(cancelBag: cancelBag)
        
        guard let storeId = appState.value.userData.selectedStore.value?.id else {
            Fail(outputType: RetailStoreMenuFetch.self, failure: RetailStoreMenuServiceError.noSelectedStore)
                .eraseToAnyPublisher()
                .sinkToLoadable { menuFetch.wrappedValue = $0 }
                .store(in: cancelBag)
            return
        }

        // Flow:
        // - after a sucessful web fetch always want to remove a previously stored result
        // - option to check for recently stored result vs always attempting a search
        
        let fulfilmentDate = appState.value.userData.selectedStore.value?.date(
            from: appState.value.userData.basket?.selectedSlot?.start
        )
        
        if AppV2Constants.Business.attemptFreshMenuFetches {
            firstWebFetchBeforeCheckingStore(
                storeId: storeId,
                categoryId: categoryId,
                fulfilmentMethod: fulfilmentMethod,
                fulfilmentDate: fulfilmentDate
            )
                .sinkToLoadable { menuFetch.wrappedValue = $0 }
                .store(in: cancelBag)
        } else {
            firstCheckStoreBeforeFetchingFromWeb(
                storeId: storeId,
                categoryId: categoryId,
                fulfilmentMethod: fulfilmentMethod,
                fulfilmentDate: fulfilmentDate
            )
                .sinkToLoadable { menuFetch.wrappedValue = $0 }
                .store(in: cancelBag)
        }
    }
    
    private func firstWebFetchBeforeCheckingStore(
        storeId: Int,
        categoryId: Int?,
        fulfilmentMethod: RetailStoreOrderMethodType,
        fulfilmentDate: String?
    ) -> AnyPublisher<RetailStoreMenuFetch, Error> {
        
        let searchCategoryId: Int
        let publisher: AnyPublisher<RetailStoreMenuFetch, Error>
        
        // if the category is known a different end point is used
        if let categoryId = categoryId {
            publisher = webRepository
                .loadRetailStoreMenuSubCategoriesAndItems(
                    storeId: storeId,
                    categoryId: categoryId,
                    fulfilmentMethod: fulfilmentMethod,
                    fulfilmentDate: fulfilmentDate
                )
            searchCategoryId = categoryId
        } else {
            publisher = webRepository
                .loadRootRetailStoreMenuCategories(
                    storeId: storeId,
                    fulfilmentMethod: fulfilmentMethod,
                    fulfilmentDate: fulfilmentDate
                )
            searchCategoryId = 0
        }
        
        // whilst passing the date is optional for the API it is better practice
        // to store results with a date otherwise fringe cases like using
        // cached results just after midnight with the wrong values could ocurr
        let storedFulfilmentDate = fulfilmentDate ?? appState.value.userData.selectedStore.value?.storeDateToday()
        
        return publisher
            .ensureTimeSpan(requestHoldBackTimeInterval)
            // convert the result to include a Bool indicating the source of the data
            .flatMap({ storeFetch -> AnyPublisher<(Bool, RetailStoreMenuFetch), Error> in
                return Just<(Bool, RetailStoreMenuFetch)>.withErrorType((true, storeFetch), Error.self)
            })
            .catch({ error in
                // failed to fetch from the API so try to get a result from the persistent store
                return dbRepository.retailStoreMenuFetch(
                        forStoreId: storeId,
                        categoryId: searchCategoryId,
                        fulfilmentMethod: fulfilmentMethod,
                        fulfilmentDate: storedFulfilmentDate
                    )
                    .flatMap { storeFetch -> AnyPublisher<(Bool, RetailStoreMenuFetch), Error> in
                        if
                            let storeFetch = storeFetch,
                            // check that the data is not too old
                            let fetchTimestamp = storeFetch.fetchTimestamp,
                            fetchTimestamp > AppV2Constants.Business.retailStoreMenuCachedExpiry
                        {
                            return Just<(Bool, RetailStoreMenuFetch)>.withErrorType((false, storeFetch), Error.self)
                        } else {
                            return Fail(outputType: (Bool, RetailStoreMenuFetch).self, failure: error)
                                .eraseToAnyPublisher()
                        }
                    }
            })
            .flatMap({ (fromWeb, fetch) -> AnyPublisher<RetailStoreMenuFetch, Error> in
                if fromWeb {
                    // need to remove any previous result in the database and store a new value
                    return dbRepository
                        .clearRetailStoreMenuFetch(
                            forStoreId: storeId,
                            categoryId: searchCategoryId,
                            fulfilmentMethod: fulfilmentMethod,
                            fulfilmentDate: storedFulfilmentDate
                        )
                        .flatMap { _ -> AnyPublisher<RetailStoreMenuFetch, Error> in
                            dbRepository
                                .store(
                                    fetchResult: fetch,
                                    forStoreId: storeId,
                                    categoryId: searchCategoryId,
                                    fulfilmentMethod: fulfilmentMethod,
                                    fulfilmentDate: storedFulfilmentDate
                                )
                                // need to map from RetailStoreMenuFetch? to RetailStoreMenuFetch
                                .flatMap { fetch -> AnyPublisher<RetailStoreMenuFetch, Error> in
                                    if let fetch = fetch {
                                        return Just<RetailStoreMenuFetch>.withErrorType(fetch, Error.self)
                                    } else {
                                        return Fail<RetailStoreMenuFetch, Error>(error: RetailStoreMenuServiceError.unableToPersistResult)
                                            .eraseToAnyPublisher()
                                    }
                                }
                                .eraseToAnyPublisher()
                        }
                        .eraseToAnyPublisher()
                } else {
                    return Just<RetailStoreMenuFetch>.withErrorType(fetch, Error.self)
                }
            })
            .eraseToAnyPublisher()
    }
    
    private func firstWebSearchBeforeCheckingStore(
        storeId: Int,
        fulfilmentMethod: RetailStoreOrderMethodType,
        searchTerm: String,
        scope: RetailStoreMenuGlobalSearchScope?,
        itemsPagination: (limit: Int, page: Int)?,
        categoriesPagination: (limit: Int, page: Int)?
    ) -> AnyPublisher<RetailStoreMenuGlobalSearch, Error> {
        
        return webRepository
            .globalSearch(
                storeId: storeId,
                fulfilmentMethod: fulfilmentMethod,
                searchTerm: searchTerm,
                scope: scope,
                itemsPagination: itemsPagination,
                categoriesPagination: categoriesPagination
            )
            .ensureTimeSpan(requestHoldBackTimeInterval)
            // convert the result to include a Bool indicating the
            // source of the data
            .flatMap({ globalSearch -> AnyPublisher<(Bool, RetailStoreMenuGlobalSearch), Error> in
                return Just<(Bool, RetailStoreMenuGlobalSearch)>.withErrorType((true, globalSearch), Error.self)
            })
            .catch({ error in
                // failed to fetch from the API so try to get a
                // result from the persistent store
                return dbRepository
                    .retailStoreMenuGlobalSearch(
                        forStoreId: storeId,
                        fulfilmentMethod: fulfilmentMethod,
                        searchTerm: searchTerm,
                        scope: scope,
                        itemsPagination: itemsPagination,
                        categoriesPagination: categoriesPagination
                    )
                    .flatMap { globalSearch -> AnyPublisher<(Bool, RetailStoreMenuGlobalSearch), Error> in
                        if
                            let globalSearch = globalSearch,
                            // check that the data is not too old
                            let fetchTimestamp = globalSearch.fetchTimestamp,
                            fetchTimestamp > AppV2Constants.Business.retailStoreMenuCachedExpiry
                        {
                            return Just<(Bool, RetailStoreMenuGlobalSearch)>.withErrorType((false, globalSearch), Error.self)
                        } else {
                            return Fail(outputType: (Bool, RetailStoreMenuGlobalSearch).self, failure: error)
                                .eraseToAnyPublisher()
                        }
                    }
            })
            .flatMap({ (fromWeb, fetch) -> AnyPublisher<RetailStoreMenuGlobalSearch, Error> in
                if fromWeb {
                    // need to remove any previous result in the
                    // database and store a new value
                    return dbRepository
                        .clearGlobalSearch(
                            forStoreId: storeId,
                            fulfilmentMethod: fulfilmentMethod,
                            searchTerm: searchTerm,
                            scope: scope,
                            itemsPagination: itemsPagination,
                            categoriesPagination: categoriesPagination
                        )
                        .flatMap { _ -> AnyPublisher<RetailStoreMenuGlobalSearch, Error> in
                            dbRepository
                                .store(
                                    fetchResult: fetch,
                                    forStoreId: storeId,
                                    fulfilmentMethod: fulfilmentMethod,
                                    searchTerm: searchTerm,
                                    scope: scope,
                                    itemsPagination: itemsPagination,
                                    categoriesPagination: categoriesPagination
                                )
                                // need to map from RetailStoreMenuGlobalSearch? to
                                // RetailStoreMenuGlobalSearch
                                .flatMap { fetch -> AnyPublisher<RetailStoreMenuGlobalSearch, Error> in
                                    if let fetch = fetch {
                                        return Just<RetailStoreMenuGlobalSearch>.withErrorType(fetch, Error.self)
                                    } else {
                                        return Fail<RetailStoreMenuGlobalSearch, Error>(error: RetailStoreMenuServiceError.unableToPersistResult)
                                            .eraseToAnyPublisher()
                                    }
                                }
                                .eraseToAnyPublisher()
                        }
                        .eraseToAnyPublisher()
                } else {
                    return Just<RetailStoreMenuGlobalSearch>.withErrorType(fetch, Error.self)
                }
            })
            .eraseToAnyPublisher()
    }
    
    private func firstWebGetItemsBeforeCheckingStore(
        storeId: Int,
        fulfilmentMethod: RetailStoreOrderMethodType,
        menuItemIds: [Int]?,
        discountId: Int?,
        discountSectionId: Int?
    ) -> AnyPublisher<RetailStoreMenuFetch, Error> {
        
        return webRepository
            .getItems(
                storeId: storeId,
                fulfilmentMethod: fulfilmentMethod,
                menuItemIds: menuItemIds,
                discountId: discountId,
                discountSectionId: discountSectionId
            )
            .ensureTimeSpan(requestHoldBackTimeInterval)
            // convert the result to include a Bool indicating the
            // source of the data
            .flatMap({ itemsResult -> AnyPublisher<(Bool, RetailStoreMenuFetch), Error> in
                return Just<(Bool, RetailStoreMenuFetch)>.withErrorType((true, itemsResult), Error.self)
            })
            .catch({ error in
                // failed to fetch from the API so try to get a
                // result from the persistent store
                return dbRepository
                    .retailStoreMenuItemsFetch(
                        forStoreId: storeId,
                        menuItemIds: menuItemIds,
                        discountId: discountId,
                        discountSectionId: discountSectionId,
                        fulfilmentMethod: fulfilmentMethod
                    )
                    .flatMap { itemsResult -> AnyPublisher<(Bool, RetailStoreMenuFetch), Error> in
                        if
                            let itemsResult = itemsResult,
                            // check that the data is not too old
                            let fetchTimestamp = itemsResult.fetchTimestamp,
                            fetchTimestamp > AppV2Constants.Business.retailStoreMenuCachedExpiry
                        {
                            return Just<(Bool, RetailStoreMenuFetch)>.withErrorType((false, itemsResult), Error.self)
                        } else {
                            return Fail(outputType: (Bool, RetailStoreMenuFetch).self, failure: error)
                                .eraseToAnyPublisher()
                        }
                    }
            })
            .flatMap({ (fromWeb, fetch) -> AnyPublisher<RetailStoreMenuFetch, Error> in
                if fromWeb {
                    // need to remove any previous result in the
                    // database and store a new value
                    return dbRepository
                        .clearRetailStoreMenuItemsFetch(
                            forStoreId: storeId,
                            menuItemIds: menuItemIds,
                            discountId: discountId,
                            discountSectionId: discountSectionId,
                            fulfilmentMethod: fulfilmentMethod
                        )
                        .flatMap { _ -> AnyPublisher<RetailStoreMenuFetch, Error> in
                            dbRepository
                                .store(
                                    fetchResult: fetch,
                                    forStoreId: storeId,
                                    menuItemIds: menuItemIds,
                                    discountId: discountId,
                                    discountSectionId: discountSectionId,
                                    fulfilmentMethod: fulfilmentMethod
                                )
                                // need to map from RetailStoreMenuGlobalSearch? to
                                // RetailStoreMenuGlobalSearch
                                .flatMap { fetch -> AnyPublisher<RetailStoreMenuFetch, Error> in
                                    if let fetch = fetch {
                                        return Just<RetailStoreMenuFetch>.withErrorType(fetch, Error.self)
                                    } else {
                                        return Fail<RetailStoreMenuFetch, Error>(error: RetailStoreMenuServiceError.unableToPersistResult)
                                            .eraseToAnyPublisher()
                                    }
                                }
                                .eraseToAnyPublisher()
                        }
                        .eraseToAnyPublisher()
                } else {
                    return Just<RetailStoreMenuFetch>.withErrorType(fetch, Error.self)
                }
            })
            .eraseToAnyPublisher()
    }
    
    private func firstCheckStoreBeforeFetchingFromWeb(
        storeId: Int,
        categoryId: Int?,
        fulfilmentMethod: RetailStoreOrderMethodType,
        fulfilmentDate: String?
    ) -> AnyPublisher<RetailStoreMenuFetch, Error> {
        
        let searchCategoryId: Int = categoryId ?? 0
        
        // whilst passing the date is optional for the API it is better practice
        // to store results with a date otherwise fringe cases like using
        // cached results just after midnight with the wrong values could ocurr
        let storedFulfilmentDate = fulfilmentDate ?? appState.value.userData.selectedStore.value?.storeDateToday()
        
        lazy var webFetchPublisher: AnyPublisher<RetailStoreMenuFetch, Error> = { () -> AnyPublisher<RetailStoreMenuFetch, Error> in
            
            let publisher: AnyPublisher<RetailStoreMenuFetch, Error>
            
            if let categoryId = categoryId {
                publisher = webRepository
                    .loadRetailStoreMenuSubCategoriesAndItems(
                        storeId: storeId,
                        categoryId: categoryId,
                        fulfilmentMethod: fulfilmentMethod,
                        fulfilmentDate: fulfilmentDate
                    )
            } else {
                publisher = webRepository
                    .loadRootRetailStoreMenuCategories(
                        storeId: storeId,
                        fulfilmentMethod: fulfilmentMethod,
                        fulfilmentDate: fulfilmentDate
                    )
            }
            
            return publisher
                .ensureTimeSpan(requestHoldBackTimeInterval)
                .flatMap { webFetch -> AnyPublisher<RetailStoreMenuFetch, Error> in
                    return dbRepository
                        .store(
                            fetchResult: webFetch,
                            forStoreId: storeId,
                            categoryId: searchCategoryId,
                            fulfilmentMethod: fulfilmentMethod,
                            fulfilmentDate: storedFulfilmentDate
                        )
                        // need to map from RetailStoreMenuFetch? to RetailStoreMenuFetch
                        .flatMap { fetch -> AnyPublisher<RetailStoreMenuFetch, Error> in
                            if let fetch = fetch {
                                return Just<RetailStoreMenuFetch>.withErrorType(fetch, Error.self)
                            } else {
                                return Fail<RetailStoreMenuFetch, Error>(error: RetailStoreMenuServiceError.unableToPersistResult)
                                    .eraseToAnyPublisher()
                            }
                        }
                        .eraseToAnyPublisher()
                        
                }.eraseToAnyPublisher()
        }()
        
        return dbRepository.retailStoreMenuFetch(
                forStoreId: storeId,
                categoryId: searchCategoryId,
                fulfilmentMethod: fulfilmentMethod,
                fulfilmentDate: storedFulfilmentDate
            )
            .flatMap { storeFetch -> AnyPublisher<RetailStoreMenuFetch, Error> in
                if
                    let storeFetch = storeFetch,
                    // check that the data is not too old
                    let fetchTimestamp = storeFetch.fetchTimestamp,
                    fetchTimestamp > AppV2Constants.Business.retailStoreMenuCachedExpiry
                {
                    return Just<RetailStoreMenuFetch>.withErrorType(storeFetch, Error.self)
                } else {
                    return dbRepository
                        // delete any previous entry
                        .clearRetailStoreMenuFetch(
                            forStoreId: storeId,
                            categoryId: searchCategoryId,
                            fulfilmentMethod: fulfilmentMethod,
                            fulfilmentDate: storedFulfilmentDate
                        )
                        .flatMap { _ -> AnyPublisher<RetailStoreMenuFetch, Error> in
                            return webFetchPublisher
                        }
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
        
    }
    
    private func firstCheckStoreBeforeSearchingFromWeb(
        storeId: Int,
        fulfilmentMethod: RetailStoreOrderMethodType,
        searchTerm: String,
        scope: RetailStoreMenuGlobalSearchScope?,
        itemsPagination: (limit: Int, page: Int)?,
        categoriesPagination: (limit: Int, page: Int)?
    ) -> AnyPublisher<RetailStoreMenuGlobalSearch, Error> {
        
        return dbRepository
            .retailStoreMenuGlobalSearch(
                forStoreId: storeId,
                fulfilmentMethod: fulfilmentMethod,
                searchTerm: searchTerm,
                scope: scope,
                itemsPagination: itemsPagination,
                categoriesPagination: categoriesPagination
            )
            .flatMap { globalSearch -> AnyPublisher<RetailStoreMenuGlobalSearch, Error> in
                if
                    let globalSearch = globalSearch,
                    // check that the data is not too old
                    let fetchTimestamp = globalSearch.fetchTimestamp,
                    fetchTimestamp > AppV2Constants.Business.retailStoreMenuCachedExpiry
                {
                    return Just<RetailStoreMenuGlobalSearch>.withErrorType(globalSearch, Error.self)
                } else {
                    return dbRepository
                        // delete any previous entry
                        .clearGlobalSearch(
                            forStoreId: storeId,
                            fulfilmentMethod: fulfilmentMethod,
                            searchTerm: searchTerm,
                            scope: scope,
                            itemsPagination: itemsPagination,
                            categoriesPagination: categoriesPagination
                        )
                        .flatMap { _ -> AnyPublisher<RetailStoreMenuGlobalSearch, Error> in
                            return webRepository
                                .globalSearch(
                                    storeId: storeId,
                                    fulfilmentMethod: fulfilmentMethod,
                                    searchTerm: searchTerm,
                                    scope: scope,
                                    itemsPagination: itemsPagination,
                                    categoriesPagination: categoriesPagination
                                )
                                .ensureTimeSpan(requestHoldBackTimeInterval)
                                .flatMap { webFetch -> AnyPublisher<RetailStoreMenuGlobalSearch, Error> in
                                    return dbRepository
                                        .store(
                                            fetchResult: webFetch,
                                            forStoreId: storeId,
                                            fulfilmentMethod: fulfilmentMethod,
                                            searchTerm: searchTerm,
                                            scope: scope,
                                            itemsPagination: itemsPagination,
                                            categoriesPagination: categoriesPagination
                                        )
                                        // need to map from RetailStoreMenuGlobalSearch?
                                        // to RetailStoreMenuGlobalSearch
                                        .flatMap { fetch -> AnyPublisher<RetailStoreMenuGlobalSearch, Error> in
                                            if let fetch = fetch {
                                                return Just<RetailStoreMenuGlobalSearch>.withErrorType(fetch, Error.self)
                                            } else {
                                                return Fail<RetailStoreMenuGlobalSearch, Error>(error: RetailStoreMenuServiceError.unableToPersistResult)
                                                    .eraseToAnyPublisher()
                                            }
                                        }
                                        .eraseToAnyPublisher()
                                        
                                }.eraseToAnyPublisher()
                        }
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
        
    }
    
    private func firstCheckStoreBeforeGetItemsFromWeb(
        storeId: Int,
        fulfilmentMethod: RetailStoreOrderMethodType,
        menuItemIds: [Int]?,
        discountId: Int?,
        discountSectionId: Int?
    ) -> AnyPublisher<RetailStoreMenuFetch, Error> {
        
        return dbRepository
            .retailStoreMenuItemsFetch(
                forStoreId: storeId,
                menuItemIds: menuItemIds,
                discountId: discountId,
                discountSectionId: discountSectionId,
                fulfilmentMethod: fulfilmentMethod
            )
            .flatMap { itemsResult -> AnyPublisher<RetailStoreMenuFetch, Error> in
                if
                    let itemsResult = itemsResult,
                    // check that the data is not too old
                    let fetchTimestamp = itemsResult.fetchTimestamp,
                    fetchTimestamp > AppV2Constants.Business.retailStoreMenuCachedExpiry
                {
                    return Just<RetailStoreMenuFetch>.withErrorType(itemsResult, Error.self)
                } else {
                    return dbRepository
                        // delete any previous entry
                        .clearRetailStoreMenuItemsFetch(
                            forStoreId: storeId,
                            menuItemIds: menuItemIds,
                            discountId: discountId,
                            discountSectionId: discountSectionId,
                            fulfilmentMethod: fulfilmentMethod
                        )
                        .flatMap { _ -> AnyPublisher<RetailStoreMenuFetch, Error> in
                            return webRepository
                                .getItems(
                                    storeId: storeId,
                                    fulfilmentMethod: fulfilmentMethod,
                                    menuItemIds: menuItemIds,
                                    discountId: discountId,
                                    discountSectionId: discountSectionId
                                )
                                .ensureTimeSpan(requestHoldBackTimeInterval)
                                .flatMap { webFetch -> AnyPublisher<RetailStoreMenuFetch, Error> in
                                    return dbRepository
                                        .store(
                                            fetchResult: webFetch,
                                            forStoreId: storeId,
                                            menuItemIds: menuItemIds,
                                            discountId: discountId,
                                            discountSectionId: discountSectionId,
                                            fulfilmentMethod: fulfilmentMethod
                                        )
                                        // need to map from RetailStoreMenuGlobalSearch?
                                        // to RetailStoreMenuGlobalSearch
                                        .flatMap { fetch -> AnyPublisher<RetailStoreMenuFetch, Error> in
                                            if let fetch = fetch {
                                                return Just<RetailStoreMenuFetch>.withErrorType(fetch, Error.self)
                                            } else {
                                                return Fail<RetailStoreMenuFetch, Error>(error: RetailStoreMenuServiceError.unableToPersistResult)
                                                    .eraseToAnyPublisher()
                                            }
                                        }
                                        .eraseToAnyPublisher()
                                        
                                }.eraseToAnyPublisher()
                        }
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    private var requestHoldBackTimeInterval: TimeInterval {
        return ProcessInfo.processInfo.isRunningTests ? 0 : 0.5
    }
    
}

struct StubRetailStoreMenuService: RetailStoreMenuServiceProtocol {
    
    func globalSearch(searchFetch: LoadableSubject<RetailStoreMenuGlobalSearch>, searchTerm: String, scope: RetailStoreMenuGlobalSearchScope?, itemsPagination: (limit: Int, page: Int)?, categoriesPagination: (limit: Int, page: Int)?) {}
    
    func getRootCategories(menuFetch: LoadableSubject<RetailStoreMenuFetch>) {}
    
    func getChildCategoriesAndItems(menuFetch: LoadableSubject<RetailStoreMenuFetch>, categoryId: Int) {}
    
    func getItems(menuFetch: LoadableSubject<RetailStoreMenuFetch>, menuItemIds menuItems: [Int]?, discountId: Int?, discountSectionId: Int?) {}
    
}
