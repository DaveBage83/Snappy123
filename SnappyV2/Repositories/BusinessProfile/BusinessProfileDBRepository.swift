//
//  BusinessProfileDBRepository.swift
//  SnappyV2
//
//  Created by Kevin Palser on 02/03/2022.
//

import CoreData
import Combine

protocol BusinessProfileDBRepositoryProtocol {
    func businessProfile(forLocaleCode localeCode: String) async throws -> BusinessProfile?
    func clearBusinessProfile(forLocaleCode localeCode: String) async throws
    func store(businessProfile: BusinessProfile, forLocaleCode localeCode: String) async throws
}

struct BusinessProfileDBRepository: BusinessProfileDBRepositoryProtocol {
    
    let persistentStore: PersistentStore
    
    func businessProfile(forLocaleCode localeCode: String) async throws -> BusinessProfile? {
        let fetchRequest = BusinessProfileMO.businessProfileRequest(
            forId: AppV2Constants.Business.id,
            forLocaleCode: localeCode
        )
        
        return try await persistentStore
            .fetch(fetchRequest) {
                BusinessProfile(managedObject: $0)
            }
            .map { $0.first }
            .singleOutput()
    }
    
    func clearBusinessProfile(forLocaleCode localeCode: String) async throws {
        try await persistentStore
            .update { context in
                try BusinessProfileMO.delete(
                    fetchRequest: BusinessProfileMO.businessProfileResultForDeletion(
                        forId: AppV2Constants.Business.id,
                        forLocaleCode: localeCode
                    ),
                    in: context
                )
            }
            .singleOutput()
    }
    
    func store(businessProfile: BusinessProfile, forLocaleCode localeCode: String) async throws {
        try await persistentStore
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
                    paymentGateways: businessProfile.paymentGateways,
                    postcodeRules: businessProfile.postcodeRules,
                    marketingText: nil,
                    fetchLocaleCode: localeCode,
                    fetchTimestamp: nil,
                    colors: businessProfile.colors,
                    orderingClientUpdateRequirements: businessProfile.orderingClientUpdateRequirements
                )
                
                if businessProfileToSave.store(in: context) == nil {
                    throw AddressServiceError.unableToPersistResult
                }
            }
            .singleOutput()
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
