//
//  RetailStoreMenuDBRepository.swift
//  SnappyV2
//
//  Created by Kevin Palser on 19/10/2021.
//

import CoreData
import Combine

protocol RetailStoreMenuDBRepositoryProtocol {
    
    // adding a fetch result to the database
    func store(fetchResult: RetailStoreMenuFetch, forStoreId: Int, categoryId: Int, fulfilmentMethod: RetailStoreOrderMethodType) -> AnyPublisher<RetailStoreMenuFetch?, Error>
    func store(
        fetchResult: RetailStoreMenuGlobalSearch,
        forStoreId: Int,
        fulfilmentMethod: RetailStoreOrderMethodType,
        searchTerm: String,
        scope: RetailStoreMenuGlobalSearchScope?,
        itemsPagination: (limit: Int, page: Int)?,
        categoriesPagination: (limit: Int, page: Int)?
    ) -> AnyPublisher<RetailStoreMenuGlobalSearch?, Error>
    func store(
        fetchResult: RetailStoreMenuFetch,
        forStoreId: Int,
        menuItemIds: [Int]?,
        discountId: Int?,
        discountSectionId: Int?,
        fulfilmentMethod: RetailStoreOrderMethodType
    ) -> AnyPublisher<RetailStoreMenuFetch?, Error>
    
    // removing stored results
    func clearRetailStoreMenuFetch(forStoreId: Int, categoryId: Int, fulfilmentMethod: RetailStoreOrderMethodType) -> AnyPublisher<Bool, Error>
    func clearGlobalSearch(
        forStoreId: Int,
        fulfilmentMethod: RetailStoreOrderMethodType,
        searchTerm: String,
        scope: RetailStoreMenuGlobalSearchScope?,
        itemsPagination: (limit: Int, page: Int)?,
        categoriesPagination: (limit: Int, page: Int)?
    ) -> AnyPublisher<Bool, Error>
    func clearRetailStoreMenuItemsFetch(
        forStoreId: Int,
        menuItemIds: [Int]?,
        discountId: Int?,
        discountSectionId: Int?,
        fulfilmentMethod: RetailStoreOrderMethodType
    ) -> AnyPublisher<Bool, Error>
    
    // fetching stored results
    func retailStoreMenuFetch(forStoreId: Int, categoryId: Int, fulfilmentMethod: RetailStoreOrderMethodType) -> AnyPublisher<RetailStoreMenuFetch?, Error>
    func retailStoreMenuGlobalSearch(
        forStoreId: Int,
        fulfilmentMethod: RetailStoreOrderMethodType,
        searchTerm: String,
        scope: RetailStoreMenuGlobalSearchScope?,
        itemsPagination: (limit: Int, page: Int)?,
        categoriesPagination: (limit: Int, page: Int)?
    ) -> AnyPublisher<RetailStoreMenuGlobalSearch?, Error>
    func retailStoreMenuItemsFetch(
        forStoreId: Int,
        menuItemIds: [Int]?,
        discountId: Int?,
        discountSectionId: Int?,
        fulfilmentMethod: RetailStoreOrderMethodType
    ) -> AnyPublisher<RetailStoreMenuFetch?, Error>
}

struct RetailStoreMenuDBMenuDBRepository: RetailStoreMenuDBRepositoryProtocol {

    let persistentStore: PersistentStore
    
    func store(fetchResult: RetailStoreMenuFetch, forStoreId storeId: Int, categoryId: Int, fulfilmentMethod: RetailStoreOrderMethodType) -> AnyPublisher<RetailStoreMenuFetch?, Error> {
        return persistentStore
            .update { context in
                let fetch = fetchResult.store(in: context)
                fetch?.fetchStoreId = Int64(storeId)
                fetch?.fetchCategoryId = Int64(categoryId)
                fetch?.fetchFulfilmentMethod = fulfilmentMethod.rawValue
                return fetch.flatMap { RetailStoreMenuFetch(managedObject: $0) }
            }
    }
    
    func store(
        fetchResult: RetailStoreMenuGlobalSearch,
        forStoreId storeId: Int,
        fulfilmentMethod: RetailStoreOrderMethodType,
        searchTerm: String,
        scope: RetailStoreMenuGlobalSearchScope?,
        itemsPagination: (limit: Int, page: Int)?,
        categoriesPagination: (limit: Int, page: Int)?
    ) -> AnyPublisher<RetailStoreMenuGlobalSearch?, Error> {
        return persistentStore
            .update { context in
                let fetch = fetchResult.store(in: context)
                // required
                fetch?.fetchStoreId = Int64(storeId)
                fetch?.fetchFulfilmentMethod = fulfilmentMethod.rawValue
                fetch?.fetchSearchTerm = searchTerm
                // optional
                if let scope = scope {
                    fetch?.fetchSearchScope = scope.rawValue
                }
                if let itemsPagination = itemsPagination {
                    fetch?.fetchItemsLimit = Int16(itemsPagination.limit)
                    fetch?.fetchItemsPage = Int16(itemsPagination.page)
                }
                if let categoriesPagination = categoriesPagination {
                    fetch?.fetchCategoriesLimit = Int16(categoriesPagination.limit)
                    fetch?.fetchCategoryPage = Int16(categoriesPagination.page)
                }
                return fetch.flatMap { RetailStoreMenuGlobalSearch(managedObject: $0) }
            }
    }
    
    func store(
        fetchResult: RetailStoreMenuFetch,
        forStoreId storeId: Int,
        menuItemIds: [Int]?,
        discountId: Int?,
        discountSectionId: Int?,
        fulfilmentMethod: RetailStoreOrderMethodType
    ) -> AnyPublisher<RetailStoreMenuFetch?, Error> {
        return persistentStore
            .update { context in
                let fetch = fetchResult.store(in: context)
                fetch?.fetchStoreId = Int64(storeId)
                // always set non category fetching to negative
                // to avoid clashing
                fetch?.fetchCategoryId = -1
                fetch?.fetchFulfilmentMethod = fulfilmentMethod.rawValue
                
                if
                    let menuItemIds = menuItemIds,
                    menuItemIds.count > 0
                {
                    fetch?.fetchMenuIdsHash = RetailStoreMenuFetchMO.menuItemIdsSaveHash(from: menuItemIds)
                } else if let discountId = discountId {
                    fetch?.fetchDiscountId = Int64(discountId)
                } else if let discountSectionId = discountSectionId {
                    fetch?.fetchDiscountSectionId = Int64(discountSectionId)
                }
                
                return fetch.flatMap { RetailStoreMenuFetch(managedObject: $0) }
            }
    }
    
    func clearRetailStoreMenuFetch(forStoreId storeId: Int, categoryId: Int, fulfilmentMethod: RetailStoreOrderMethodType) -> AnyPublisher<Bool, Error> {

        // More efficient but unsuited to unit testing
//        return persistentStore.delete(
//            RetailStoreMenuFetchMO.fetchRequestResult(
//                forStoreId: storeId,
//                categoryId: categoryId,
//                fulfilmentMethod: fulfilmentMethod
//            )
//        )

        return persistentStore
            .update { context in
                
                try RetailStoreMenuFetchMO.delete(
                    fetchRequest: RetailStoreMenuFetchMO.fetchRequestResultForDeletion(
                        forStoreId: storeId,
                        categoryId: categoryId,
                        fulfilmentMethod: fulfilmentMethod
                    ),
                    in: context
                )
                
                return true
            }
    }
    
    func clearGlobalSearch(
        forStoreId storeId: Int,
        fulfilmentMethod: RetailStoreOrderMethodType,
        searchTerm: String,
        scope: RetailStoreMenuGlobalSearchScope?,
        itemsPagination: (limit: Int, page: Int)?,
        categoriesPagination: (limit: Int, page: Int)?
    ) -> AnyPublisher<Bool, Error> {
        
        return persistentStore
            .update { context in
                
                try RetailStoreMenuGlobalSearchMO.delete(
                    fetchRequest: RetailStoreMenuGlobalSearchMO.fetchRequestResultForDeletion(
                        forStoreId: storeId,
                        fulfilmentMethod: fulfilmentMethod,
                        searchTerm: searchTerm,
                        scope: scope,
                        itemsPagination: itemsPagination,
                        categoriesPagination: categoriesPagination
                    ),
                    in: context
                )
                
                return true
            }
        
    }
    
    func clearRetailStoreMenuItemsFetch(
        forStoreId storeId: Int,
        menuItemIds: [Int]?,
        discountId: Int?,
        discountSectionId: Int?,
        fulfilmentMethod: RetailStoreOrderMethodType
    ) -> AnyPublisher<Bool, Error> {
        
        return persistentStore
            .update { context in
                
                try RetailStoreMenuGlobalSearchMO.delete(
                    fetchRequest: RetailStoreMenuFetchMO.fetchRequestResultForDeletion(
                        forStoreId: storeId,
                        menuItemIds: menuItemIds,
                        discountId: discountId,
                        discountSectionId: discountSectionId,
                        fulfilmentMethod: fulfilmentMethod
                    ),
                    in: context
                )
                
                return true
            }
        
    }
    
    func retailStoreMenuFetch(forStoreId storeId: Int, categoryId: Int, fulfilmentMethod: RetailStoreOrderMethodType) -> AnyPublisher<RetailStoreMenuFetch?, Error> {
        
        let fetchRequest = RetailStoreMenuFetchMO.fetchRequest(forStoreId: storeId, categoryId: categoryId, fulfilmentMethod: fulfilmentMethod)
        
        return persistentStore
            .fetch(fetchRequest) {
                RetailStoreMenuFetch(managedObject: $0)
            }
            .map { $0.first }
            .eraseToAnyPublisher()
    }
    
    func retailStoreMenuGlobalSearch(
        forStoreId storeId: Int,
        fulfilmentMethod: RetailStoreOrderMethodType,
        searchTerm: String,
        scope: RetailStoreMenuGlobalSearchScope?,
        itemsPagination: (limit: Int, page: Int)?,
        categoriesPagination: (limit: Int, page: Int)?
    ) -> AnyPublisher<RetailStoreMenuGlobalSearch?, Error> {
        let fetchRequest = RetailStoreMenuGlobalSearchMO.fetchRequest(
            forStoreId: storeId,
            fulfilmentMethod: fulfilmentMethod,
            searchTerm: searchTerm,
            scope: scope,
            itemsPagination: itemsPagination,
            categoriesPagination: categoriesPagination
        )
        
        return persistentStore
            .fetch(fetchRequest) {
                RetailStoreMenuGlobalSearch(managedObject: $0)
            }
            .map { $0.first }
            .eraseToAnyPublisher()
    }
    
    func retailStoreMenuItemsFetch(
        forStoreId storeId: Int,
        menuItemIds: [Int]?,
        discountId: Int?,
        discountSectionId: Int?,
        fulfilmentMethod: RetailStoreOrderMethodType
    ) -> AnyPublisher<RetailStoreMenuFetch?, Error> {
        let fetchRequest = RetailStoreMenuFetchMO.fetchRequest(
            forStoreId: storeId,
            menuItemIds: menuItemIds,
            discountId: discountId,
            discountSectionId: discountSectionId,
            fulfilmentMethod: fulfilmentMethod
        )
        
        return persistentStore
            .fetch(fetchRequest) {
                RetailStoreMenuFetch(managedObject: $0)
            }
            .map { $0.first }
            .eraseToAnyPublisher()
    }
    
}

// MARK: - Fetch Requests

extension RetailStoreMenuFetchMO {
    
    static func fetchRequestResultForDeletion(forStoreId storeId: Int, categoryId: Int, fulfilmentMethod: RetailStoreOrderMethodType) -> NSFetchRequest<NSFetchRequestResult> {
        let request = newFetchRequestResult()
        
        // match this functions parameters and also delete any
        // records that have expired
        request.predicate = NSPredicate(
            format: "(fetchStoreId == %i AND fetchCategoryId == %i AND fetchFulfilmentMethod == %@) OR timestamp < %@",
            storeId,
            categoryId,
            fulfilmentMethod.rawValue,
            AppV2Constants.Business.retailStoreMenuCachedExpiry as NSDate
        )

        // no fetch limit because multiple expired records can be matched
        return request
    }
    
    static func fetchRequestResultForDeletion(
        forStoreId storeId: Int,
        menuItemIds: [Int]?,
        discountId: Int?,
        discountSectionId: Int?,
        fulfilmentMethod: RetailStoreOrderMethodType
    ) -> NSFetchRequest<NSFetchRequestResult> {
        let request = newFetchRequestResult()
        
        // match this functions parameters and also delete any
        // records that have expired
        
        var query = "timestamp < %@ OR (fetchStoreId == %i AND fetchCategoryId == %i AND fetchFulfilmentMethod == %@"
        var arguments: [Any] = [
            AppV2Constants.Business.retailStoreMenuCachedExpiry as NSDate,
            storeId,
            -1, // always negative to avoid clashing with standard menu fetching
            fulfilmentMethod.rawValue
        ]
        
        // optional fields
        if
            let menuItemIds = menuItemIds,
            menuItemIds.count > 0
        {
            query += " AND fetchMenuIdsHash == %@"
            arguments.append(menuItemIdsSaveHash(from: menuItemIds))
        } else if let discountId = discountId {
            query += " AND fetchDiscountId == %i"
            arguments.append(discountId)
        } else if let discountSectionId = discountSectionId {
            query += " AND fetchDiscountSectionId == %i"
            arguments.append(discountSectionId)
        }
        query += ")"
        
        request.predicate = NSPredicate(format: query, argumentArray: arguments)

        // no fetch limit because multiple expired records can be matched
        return request
    }
    
    static func fetchRequest(forStoreId storeId: Int, categoryId: Int, fulfilmentMethod: RetailStoreOrderMethodType) -> NSFetchRequest<RetailStoreMenuFetchMO> {
        let request = newFetchRequest()
        request.predicate = NSPredicate(format: "fetchStoreId == %i AND fetchCategoryId == %i AND fetchFulfilmentMethod == %@", storeId, categoryId, fulfilmentMethod.rawValue)
        request.fetchLimit = 1
        return request
    }
    
    static func fetchRequest(forStoreId storeId: Int, menuItemIds: [Int]?, discountId: Int?, discountSectionId: Int?, fulfilmentMethod: RetailStoreOrderMethodType) -> NSFetchRequest<RetailStoreMenuFetchMO> {
        let request = newFetchRequest()
        
        var query = "fetchStoreId == %i AND fetchCategoryId == %i AND fetchFulfilmentMethod == %@"
        var arguments: [Any] = [
            storeId,
            -1,
            fulfilmentMethod.rawValue
        ]
        
        // optional fields
        if
            let menuItemIds = menuItemIds,
            menuItemIds.count > 0
        {
            query += " AND fetchMenuIdsHash == %@"
            arguments.append(menuItemIdsSaveHash(from: menuItemIds))
        } else if let discountId = discountId {
            query += " AND fetchDiscountId == %i"
            arguments.append(discountId)
        } else if let discountSectionId = discountSectionId {
            query += " AND fetchDiscountSectionId == %i"
            arguments.append(discountSectionId)
        }
        
        request.predicate = NSPredicate(format: query, argumentArray: arguments)
        request.fetchLimit = 1
        return request
    }
    
    static func menuItemIdsSaveHash(from array: [Int]) -> String {
        // simply combine the integers into a string separated by ":"
        return array.reduce("", { partialResult, itemId in
            var result = partialResult
            if result.isEmpty == false {
                result += ":"
            }
            return result + "\(itemId)"
        })
    }
    
}

extension RetailStoreMenuGlobalSearchMO {

    static func fetchRequestResultForDeletion(
        forStoreId storeId: Int,
        fulfilmentMethod: RetailStoreOrderMethodType,
        searchTerm: String,
        scope: RetailStoreMenuGlobalSearchScope?,
        itemsPagination: (limit: Int, page: Int)?,
        categoriesPagination: (limit: Int, page: Int)?
    ) -> NSFetchRequest<NSFetchRequestResult> {
        let request = newFetchRequestResult()
        
        // fields that will always be present
        var query = "timestamp < %@ OR (fetchStoreId == %i AND fetchFulfilmentMethod == %@ AND fetchSearchTerm == %@"
        var arguments: [Any] = [
            AppV2Constants.Business.retailStoreMenuCachedExpiry as NSDate,
            storeId,
            fulfilmentMethod.rawValue,
            searchTerm
        ]
        
        // optional fields
        if let scope = scope {
            query += " AND fetchSearchScope == %@"
            arguments.append(scope.rawValue)
        }
        if let itemsPagination = itemsPagination {
            query += " AND fetchItemsLimit == %i AND fetchItemsPage == %i"
            arguments.append(itemsPagination.limit)
            arguments.append(itemsPagination.page)
        }
        if let categoriesPagination = categoriesPagination {
            query += " AND fetchCategoriesLimit == %i AND fetchCategoryPage == %i"
            arguments.append(categoriesPagination.limit)
            arguments.append(categoriesPagination.page)
        }
        
        query += ")"
        
        request.predicate = NSPredicate(format: query, argumentArray: arguments)
        
        // no fetch limit because multiple expired records can be matched
        return request
    }
    
    static func fetchRequest(
        forStoreId storeId: Int,
        fulfilmentMethod: RetailStoreOrderMethodType,
        searchTerm: String,
        scope: RetailStoreMenuGlobalSearchScope?,
        itemsPagination: (limit: Int, page: Int)?,
        categoriesPagination: (limit: Int, page: Int)?
    ) -> NSFetchRequest<RetailStoreMenuGlobalSearchMO> {
        let request = newFetchRequest()

        // fields that will always be present
        var query = "fetchStoreId == %i AND fetchFulfilmentMethod == %@ AND fetchSearchTerm == %@"
        var arguments: [Any] = [
            storeId,
            fulfilmentMethod.rawValue,
            searchTerm
        ]
        
        // optional fields
        if let scope = scope {
            query += " AND fetchSearchScope == %@"
            arguments.append(scope.rawValue)
        }
        if let itemsPagination = itemsPagination {
            query += " AND fetchItemsLimit == %i AND fetchItemsPage == %i"
            arguments.append(itemsPagination.limit)
            arguments.append(itemsPagination.page)
        }
        if let categoriesPagination = categoriesPagination {
            query += " AND fetchCategoriesLimit == %i AND fetchCategoryPage == %i"
            arguments.append(categoriesPagination.limit)
            arguments.append(categoriesPagination.page)
        }
        
        return request
    }

}
