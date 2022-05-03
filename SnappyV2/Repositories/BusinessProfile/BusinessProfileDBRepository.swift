//
//  BusinessProfileDBRepository.swift
//  SnappyV2
//
//  Created by Kevin Palser on 02/03/2022.
//

import CoreData
import Combine

protocol BusinessProfileDBRepositoryProtocol {
    func businessProfile(forLocaleCode: String) -> AnyPublisher<BusinessProfile?, Error>
    func clearBusinessProfile(forLocaleCode: String) -> AnyPublisher<Bool, Error>
    func store(businessProfile: BusinessProfile, forLocaleCode: String) -> AnyPublisher<BusinessProfile, Error>
}

struct BusinessProfileDBRepository: BusinessProfileDBRepositoryProtocol {
    
    let persistentStore: PersistentStore
    
    func businessProfile(forLocaleCode localeCode: String) -> AnyPublisher<BusinessProfile?, Error> {
        let fetchRequest = BusinessProfileMO.businessProfileRequest(
            forId: AppV2Constants.Business.id,
            forLocaleCode: localeCode
        )
        
        return persistentStore
            .fetch(fetchRequest) {
                BusinessProfile(managedObject: $0)
            }
            .map { $0.first }
            .eraseToAnyPublisher()
    }
    
    func clearBusinessProfile(forLocaleCode localeCode: String) -> AnyPublisher<Bool, Error> {
        return persistentStore
            .update { context in
                
                try BusinessProfileMO.delete(
                    fetchRequest: BusinessProfileMO.businessProfileResultForDeletion(
                        forId: AppV2Constants.Business.id,
                        forLocaleCode: localeCode
                    ),
                    in: context
                )
                
                return true
            }
    }
    
    func store(businessProfile: BusinessProfile, forLocaleCode localeCode: String) -> AnyPublisher<BusinessProfile, Error> {
        return persistentStore
            .update { context in
                
                let businessProfileToSave = BusinessProfile(
                    id: businessProfile.id,
                    checkoutTimeoutSeconds: businessProfile.checkoutTimeoutSeconds,
                    minOrdersForAppReview: businessProfile.minOrdersForAppReview,
                    privacyPolicyLink: businessProfile.privacyPolicyLink,
                    pusherClusterServer: businessProfile.pusherClusterServer,
                    pusherAppKey: businessProfile.pusherAppKey,
                    mentionMeEnabled: businessProfile.mentionMeEnabled,
                    iterableMobileApiKey: businessProfile.iterableMobileApiKey,
                    useDeliveryFirms: businessProfile.useDeliveryFirms,
                    driverTipIncrement: businessProfile.driverTipIncrement,
                    tipLimitLevels: businessProfile.tipLimitLevels,
                    facebook: businessProfile.facebook,
                    tikTok: businessProfile.tikTok,
                    fetchLocaleCode: localeCode,
                    fetchTimestamp: nil,
                    colors: businessProfile.colors
                )
                
                guard let businessProfileMO = businessProfileToSave.store(in: context) else {
                    throw AddressServiceError.unableToPersistResult
                }
                
                return BusinessProfile(managedObject: businessProfileMO)
            }
    }
    
}

// MARK: - Fetch Requests

extension BusinessProfileMO {
    
    static func businessProfileResultForDeletion(
        forId id: Int,
        forLocaleCode localeCode: String
    ) -> NSFetchRequest<NSFetchRequestResult> {
        let request = newFetchRequestResult()
        
        // match this functions parameters and also delete any
        // records that have expired
        
        let query = "timestamp < %@ OR (id == %i AND fetchLocaleCode == %@)"
        let arguments: [Any] = [
            AppV2Constants.Business.businessProfileCachedExpiry as NSDate,
            id,
            localeCode
        ]
        
        request.predicate = NSPredicate(format: query, argumentArray: arguments)

        // no fetch limit because multiple expired records can be matched
        return request
    }

    static func businessProfileRequest(
        forId id: Int,
        forLocaleCode localeCode: String
    ) -> NSFetchRequest<BusinessProfileMO> {
        let request = newFetchRequest()

        // fields that will always be present
        let query = "id == %i AND fetchLocaleCode == %@"
        let arguments: [Any] = [
            id,
            localeCode
        ]
        
        request.predicate = NSPredicate(format: query, argumentArray: arguments)
        request.fetchLimit = 1
        
        return request
    }
    
}
