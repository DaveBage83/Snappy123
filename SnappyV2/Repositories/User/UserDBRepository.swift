//
//  UserDBRepository.swift
//  SnappyV2
//
//  Created by Kevin Palser on 16/12/2021.
//

import CoreData
import Combine

protocol UserDBRepositoryProtocol {
    // profile
    func clearMemberProfile() -> AnyPublisher<Bool, Error>
    func store(memberProfile: MemberProfile, forStoreId: Int?) -> AnyPublisher<MemberProfile, Error>
    func memberProfile(storeId: Int?) -> AnyPublisher<MemberProfile?, Error>
    // marketing options
    func clearAllFetchedUserMarketingOptions() -> AnyPublisher<Bool, Error>
    func clearFetchedUserMarketingOptions(isCheckout: Bool, notificationsEnabled: Bool, basketToken: String?) async throws -> Bool
    func store(marketingOptionsFetch: UserMarketingOptionsFetch, isCheckout: Bool, notificationsEnabled: Bool, basketToken: String?) async throws -> UserMarketingOptionsFetch
    func userMarketingOptionsFetch(isCheckout: Bool, notificationsEnabled: Bool, basketToken: String?) async throws -> UserMarketingOptionsFetch?
}

struct UserDBRepository: UserDBRepositoryProtocol {

    let persistentStore: PersistentStore
    
    func clearMemberProfile() -> AnyPublisher<Bool, Error> {
        return persistentStore
            .update { context in
                try MemberProfileMO.delete(
                    fetchRequest: MemberProfileMO.fetchRequestResult(),
                    in: context
                )
                return true
            }
    }
    
    func store(memberProfile: MemberProfile, forStoreId storeId: Int?) -> AnyPublisher<MemberProfile, Error> {
        return persistentStore
            .update { context in
                guard let memberProfileMO = memberProfile.store(in: context, forStoreId: storeId) else {
                    throw RetailStoreMenuServiceError.unableToPersistResult
                }
                return MemberProfile(managedObject: memberProfileMO)
            }
    }
    
    func memberProfile(storeId: Int?) -> AnyPublisher<MemberProfile?, Error> {
        let fetchRequest = MemberProfileMO.fetchRequestLast(forStoreId: storeId)
        
        return persistentStore
            .fetch(fetchRequest) {
                MemberProfile(managedObject: $0)
            }
            .map { $0.first }
            .eraseToAnyPublisher()
    }
    
    func clearAllFetchedUserMarketingOptions() -> AnyPublisher<Bool, Error> {
        return persistentStore
            .update { context in
                try UserMarketingOptionsFetchMO.delete(
                    fetchRequest: UserMarketingOptionsFetchMO.newFetchRequestResult(),
                    in: context
                )
                return true
            }
    }
    
    func clearFetchedUserMarketingOptions(isCheckout: Bool, notificationsEnabled: Bool, basketToken: String?) async throws -> Bool {
        return try await persistentStore
            .update { context in
                try UserMarketingOptionsFetchMO.delete(
                    fetchRequest: UserMarketingOptionsFetchMO.fetchRequestResultForDeletion(
                        isCheckout: isCheckout,
                        notificationsEnabled: notificationsEnabled,
                        basketToken: basketToken
                    ),
                    in: context
                )
                return true
            }
            .singleOutput()
    }
    
    func store(marketingOptionsFetch: UserMarketingOptionsFetch, isCheckout: Bool, notificationsEnabled: Bool, basketToken: String?) async throws -> UserMarketingOptionsFetch {
        return try await persistentStore
            .update { context in
                guard let fetchMO = marketingOptionsFetch.store(in: context) else {
                    throw UserServiceError.unableToPersistResult
                }
                // required
                fetchMO.fetchIsCheckout = isCheckout
                fetchMO.fetchNotificationsEnabled = notificationsEnabled
                // optional
                if let basketToken = basketToken {
                    fetchMO.fetchBasketToken = basketToken
                }
                return UserMarketingOptionsFetch(managedObject: fetchMO)
            }
            .singleOutput()
    }
    
    func userMarketingOptionsFetch(isCheckout: Bool, notificationsEnabled: Bool, basketToken: String?) async throws -> UserMarketingOptionsFetch? {
        
        let fetchRequest = UserMarketingOptionsFetchMO.fetchRequest(
            isCheckout: isCheckout,
            notificationsEnabled: notificationsEnabled,
            basketToken: basketToken
        )
        
        return try await persistentStore
            .fetch(fetchRequest) {
                UserMarketingOptionsFetch(managedObject: $0)
            }
            .map { $0.first }
            .singleOutput()
    }
    
}

// MARK: - Fetch Requests

extension MemberProfileMO {

    static func fetchRequestResult() -> NSFetchRequest<NSFetchRequestResult> {
        let request = newFetchRequestResult()
        request.fetchLimit = 1
        return request
    }
    
    static func fetchRequestLast(forStoreId storeId: Int?) -> NSFetchRequest<MemberProfileMO> {
        let request = newFetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        request.predicate = NSPredicate(
            format: "fetchedForStoreId == %i",
            argumentArray: [ storeId ?? 0 ]
        )
        request.fetchLimit = 1
        request.returnsObjectsAsFaults = false
        return request
    }

}

extension UserMarketingOptionsFetchMO {

    static func fetchRequestResultForDeletion(
        isCheckout: Bool,
        notificationsEnabled: Bool,
        basketToken: String?
    ) -> NSFetchRequest<NSFetchRequestResult> {
        let request = newFetchRequestResult()
        
        // fields that will always be present
        var query = "timestamp < %@ OR (fetchIsCheckout == %@ AND fetchNotificationsEnabled == %@"
        var arguments: [Any] = [
            AppV2Constants.Business.userCachedExpiry as NSDate,
            NSNumber(value: isCheckout),
            NSNumber(value: notificationsEnabled)
        ]
        
        // optional fields
        if let basketToken = basketToken {
            query += " AND fetchBasketToken == %@"
            arguments.append(basketToken)
        }
        
        query += ")"
        
        request.predicate = NSPredicate(format: query, argumentArray: arguments)
        
        // no fetch limit because multiple expired records can be matched
        return request
    }

    static func fetchRequest(
        isCheckout: Bool,
        notificationsEnabled: Bool,
        basketToken: String?
    ) -> NSFetchRequest<UserMarketingOptionsFetchMO> {
        let request = newFetchRequest()
        
        var query = "fetchIsCheckout == %@ AND fetchNotificationsEnabled == %@"
        var arguments: [Any] = [
            NSNumber(value: isCheckout),
            NSNumber(value: notificationsEnabled)
        ]
        
        // optional fields
        if let basketToken = basketToken {
            query += " AND fetchBasketToken == %@"
            arguments.append(basketToken)
        }
        
        request.predicate = NSPredicate(format: query, argumentArray: arguments)
        request.fetchLimit = 1
        return request
    }
    
}
