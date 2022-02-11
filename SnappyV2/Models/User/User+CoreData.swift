//
//  User+CoreData.swift
//  SnappyV2
//
//  Created by Kevin Palser on 29/12/2021.
//

import Foundation
import CoreData

extension MemberProfileMO: ManagedEntity { }
extension UserMarketingOptionsFetchMO: ManagedEntity { }
extension UserMarketingOptionMO: ManagedEntity { }

extension MemberProfile {
    
    init(managedObject: MemberProfileMO) {
        self.init(
            firstName: managedObject.firstName ?? "",
            lastName: managedObject.lastName ?? "",
            emailAddress: managedObject.emailAddress ?? "",
            type: MemberType(rawValue: managedObject.type ?? "") ?? .customer
        )
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> MemberProfileMO? {
        
        guard let profile = MemberProfileMO.insertNew(in: context)
            else { return nil }
        
        profile.firstName = firstName
        profile.lastName = lastName
        profile.emailAddress = emailAddress
        profile.type = type.rawValue
        
        profile.timestamp = Date().trueDate

        return profile
    }
    
}

extension UserMarketingOptionsFetch {
    
    init(managedObject: UserMarketingOptionsFetchMO) {
        
        var marketingOptions: [UserMarketingOptionResponse]?
        if
            let optionsFound = managedObject.options,
            let optionsFoundArray = optionsFound.array as? [UserMarketingOptionMO]
        {
            marketingOptions = optionsFoundArray
                .reduce([], { (optionsArray, record) -> [UserMarketingOptionResponse] in
                    var array = optionsArray
                    array.append(UserMarketingOptionResponse(managedObject: record))
                    return array
                })
        }
        
        self.init(
            marketingPreferencesIntro: managedObject.marketingPreferencesIntro,
            marketingPreferencesGuestIntro: managedObject.marketingPreferencesGuestIntro,
            marketingOptions: marketingOptions,
            fetchIsCheckout: managedObject.fetchIsCheckout,
            fetchNotificationsEnabled: managedObject.fetchNotificationsEnabled,
            fetchBasketToken: managedObject.fetchBasketToken,
            fetchTimestamp: managedObject.timestamp
        )
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> UserMarketingOptionsFetchMO? {
        
        guard let fetch = UserMarketingOptionsFetchMO.insertNew(in: context)
            else { return nil }
        
        fetch.marketingPreferencesIntro = marketingPreferencesIntro
        fetch.marketingPreferencesGuestIntro = marketingPreferencesGuestIntro
        
        if
            let marketingOptions = marketingOptions,
            marketingOptions.count > 0
        {
            fetch.options = NSOrderedSet(array: marketingOptions.compactMap({ option -> UserMarketingOptionMO? in
                return option.store(in: context)
            }))
        }
        
        fetch.fetchIsCheckout = fetchIsCheckout ?? false
        fetch.fetchNotificationsEnabled = fetchNotificationsEnabled ?? false
        fetch.fetchBasketToken = fetchBasketToken
        fetch.timestamp = Date().trueDate

        return fetch
    }
    
}

extension UserMarketingOptionResponse {
    
    init(managedObject: UserMarketingOptionMO) {
        self.init(
            type: managedObject.type ?? "",
            text: managedObject.text ?? "",
            opted: UserMarketingOptionState(rawValue: managedObject.opted ?? "out") ?? .out
        )
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> UserMarketingOptionMO? {
        
        guard let option = UserMarketingOptionMO.insertNew(in: context)
            else { return nil }
        
        option.type = type
        option.text = text
        option.opted = opted.rawValue
        
        return option
    }
    
}
