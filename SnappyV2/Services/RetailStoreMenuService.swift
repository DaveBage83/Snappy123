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
}

extension RetailStoreMenuServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .unableToPersistResult:
            return "Unable to persist web fetch result"
        }
    }
}

protocol RetailStoreMenuServiceProtocol {
    
    func getRootCategories(menuFetch: LoadableSubject<RetailStoreMenuFetch>, storeId: Int)
    
    func getChildCategoriesAndItems(menuFetch: LoadableSubject<RetailStoreMenuFetch>, storeId: Int, categoryId: Int)
}

struct RetailStoreMenuService: RetailStoreMenuServiceProtocol {

    let webRepository: RetailStoreMenuWebRepositoryProtocol
    let dbRepository: RetailStoreMenuDBRepositoryProtocol
    
    // Example in the clean architecture Countries exampe of the appState
    // being passed to a service (but not used the code). Using this as
    // a justification to be an acceptable method to update the Basket
    // Henrik/Kevin: 2021-10-26
    let appState: Store<AppState>

    init(webRepository: RetailStoreMenuWebRepositoryProtocol, dbRepository: RetailStoreMenuDBRepositoryProtocol, appState: Store<AppState>) {
        self.webRepository = webRepository
        self.dbRepository = dbRepository
        self.appState = appState
    }
    
    func getRootCategories(menuFetch: LoadableSubject<RetailStoreMenuFetch>, storeId: Int) {
        getRootCategories(
            menuFetch: menuFetch,
            storeId: storeId,
            categoryId: nil,
            fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod,
            attemptNewFetch: true
        )
    }
    
    func getChildCategoriesAndItems(menuFetch: LoadableSubject<RetailStoreMenuFetch>, storeId: Int, categoryId: Int) {
        getRootCategories(
            menuFetch: menuFetch,
            storeId: storeId,
            categoryId: categoryId,
            fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod,
            attemptNewFetch: true
        )
    }
    
    private func getRootCategories(menuFetch: LoadableSubject<RetailStoreMenuFetch>, storeId: Int, categoryId: Int?, fulfilmentMethod: RetailStoreOrderMethodType, attemptNewFetch: Bool) {
        let cancelBag = CancelBag()
        menuFetch.wrappedValue.setIsLoading(cancelBag: cancelBag)

        // Flow:
        // - after a sucessful web fetch always want to remove a previously stored result
        // - option to check for recently stored result vs always attempting a search
        
        if attemptNewFetch {
            
            firstWebFetchBeforeCheckingStore(storeId: storeId, categoryId: categoryId, fulfilmentMethod: fulfilmentMethod)
                .sinkToLoadable { menuFetch.wrappedValue = $0 }
                .store(in: cancelBag)
            
        } else {
            
            firstCheckStoreBeforeFetchingFromWeb(storeId: storeId, categoryId: categoryId, fulfilmentMethod: fulfilmentMethod)
                .sinkToLoadable { menuFetch.wrappedValue = $0 }
                .store(in: cancelBag)
            
        }
    }
    
    private func firstWebFetchBeforeCheckingStore(storeId: Int, categoryId: Int?, fulfilmentMethod: RetailStoreOrderMethodType) -> AnyPublisher<RetailStoreMenuFetch, Error> {
        
        let searchCategoryId: Int
        let publisher: AnyPublisher<RetailStoreMenuFetch, Error>
        
        // if the category is known a different end point is used
        if let categoryId = categoryId {
            publisher = webRepository
                .loadRetailStoreMenuSubCategoriesAndItems(
                    storeId: storeId,
                    categoryId: categoryId,
                    fulfilmentMethod: fulfilmentMethod
                )
            searchCategoryId = categoryId
        } else {
            publisher = webRepository
                .loadRootRetailStoreMenuCategories(
                    storeId: storeId,
                    fulfilmentMethod: fulfilmentMethod
                )
            searchCategoryId = 0
        }
        
        return publisher
            .ensureTimeSpan(requestHoldBackTimeInterval)
            // convert the result to include a Bool indicating the source of the data
            .flatMap({ storeFetch -> AnyPublisher<(Bool, RetailStoreMenuFetch), Error> in
                return Just<(Bool, RetailStoreMenuFetch)>.withErrorType((true, storeFetch), Error.self)
            })
            .catch({ error in
                // failed to fetch from the API so try to get a result from the persistent store
                return dbRepository.retailStoreMenuFetch(forStoreId: storeId, categoryId: searchCategoryId, fulfilmentMethod: fulfilmentMethod)
                    .flatMap { storeFetch -> AnyPublisher<(Bool, RetailStoreMenuFetch), Error> in
                        if
                            let storeFetch = storeFetch,
                            // check that the data is not too old
                            let fetchTimestamp = storeFetch.fetchTimestamp,
                            fetchTimestamp < AppV2Constants.Business.retailStoreMenuCachedExpiry
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
                        .clearRetailStoreMenuFetch(forStoreId: storeId, categoryId: searchCategoryId, fulfilmentMethod: fulfilmentMethod)
                        .flatMap { _ -> AnyPublisher<RetailStoreMenuFetch, Error> in
                            dbRepository
                                .store(fetchResult: fetch, forStoreId: storeId, categoryId: searchCategoryId, fulfilmentMethod: fulfilmentMethod)
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
    
    private func firstCheckStoreBeforeFetchingFromWeb(storeId: Int, categoryId: Int?, fulfilmentMethod: RetailStoreOrderMethodType) -> AnyPublisher<RetailStoreMenuFetch, Error> {
        
        let searchCategoryId: Int = categoryId ?? 0
        
        lazy var webFetchPublisher: AnyPublisher<RetailStoreMenuFetch, Error> = { () -> AnyPublisher<RetailStoreMenuFetch, Error> in
            
            let publisher: AnyPublisher<RetailStoreMenuFetch, Error>
            
            if let categoryId = categoryId {
                publisher = webRepository
                    .loadRetailStoreMenuSubCategoriesAndItems(
                        storeId: storeId,
                        categoryId: categoryId,
                        fulfilmentMethod: fulfilmentMethod
                    )
            } else {
                publisher = webRepository
                    .loadRootRetailStoreMenuCategories(
                        storeId: storeId,
                        fulfilmentMethod: fulfilmentMethod
                    )
            }
            
            return publisher
                .ensureTimeSpan(requestHoldBackTimeInterval)
                .flatMap { webFetch -> AnyPublisher<RetailStoreMenuFetch, Error> in
                    return dbRepository
                        .store(fetchResult: webFetch, forStoreId: storeId, categoryId: searchCategoryId, fulfilmentMethod: fulfilmentMethod)
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
        
        return dbRepository.retailStoreMenuFetch(forStoreId: storeId, categoryId: searchCategoryId, fulfilmentMethod: fulfilmentMethod)
            .flatMap { storeFetch -> AnyPublisher<RetailStoreMenuFetch, Error> in
                if
                    let storeFetch = storeFetch,
                    // check that the data is not too old
                    let fetchTimestamp = storeFetch.fetchTimestamp,
                    fetchTimestamp < AppV2Constants.Business.retailStoreMenuCachedExpiry
                {
                    return Just<RetailStoreMenuFetch>.withErrorType(storeFetch, Error.self)
                } else {
                    return dbRepository
                        // delete any previous entry
                        .clearRetailStoreMenuFetch(forStoreId: storeId, categoryId: searchCategoryId, fulfilmentMethod: fulfilmentMethod)
                        .flatMap { _ -> AnyPublisher<RetailStoreMenuFetch, Error> in
                            return webFetchPublisher
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
    
    func getRootCategories(menuFetch: LoadableSubject<RetailStoreMenuFetch>, storeId: Int) { }
    
    func getChildCategoriesAndItems(menuFetch: LoadableSubject<RetailStoreMenuFetch>, storeId: Int, categoryId: Int) {}
    
}
