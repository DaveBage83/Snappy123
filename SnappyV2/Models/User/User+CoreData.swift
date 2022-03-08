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
extension AddressMO: ManagedEntity { }

extension MemberProfile {
    
    init(managedObject: MemberProfileMO) {
        
        let billingAddress: Address?
        if let billingAddressMO = managedObject.defaultBillingDetails {
            billingAddress = Address(managedObject: billingAddressMO)
        } else {
            billingAddress = nil
        }
        
        var savedAddresses: [Address]?
        if
            let addressesFound = managedObject.savedAddresses,
            let addressesFoundArray = addressesFound.array as? [AddressMO]
        {
            savedAddresses = addressesFoundArray
                .reduce([], { (addresswsArray, record) -> [Address] in
                    var array = addresswsArray
                    array.append(Address(managedObject: record))
                    return array
                })
        }
        
        self.init(
            firstname: managedObject.firstName ?? "",
            lastname: managedObject.lastName ?? "",
            emailAddress: managedObject.emailAddress ?? "",
            type: MemberType(rawValue: managedObject.type ?? "") ?? .customer,
            referFriendCode: managedObject.referFriendCode,
            referFriendBalance: managedObject.referFriendBalance,
            numberOfReferrals: Int(managedObject.numberOfReferrals),
            mobileContactNumber: managedObject.mobileContactNumber,
            mobileValidated: managedObject.mobileValidated,
            acceptedMarketing: managedObject.acceptedMarketing, // legacy
            defaultBillingDetails: billingAddress,
            savedAddresses: savedAddresses,
            fetchTimestamp: managedObject.timestamp
        )
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext, forStoreId storeId: Int? = nil) -> MemberProfileMO? {
        
        guard let profile = MemberProfileMO.insertNew(in: context)
            else { return nil }
        
        profile.firstName = firstname
        profile.lastName = lastname
        profile.emailAddress = emailAddress
        profile.type = type.rawValue
        profile.referFriendCode = referFriendCode
        profile.referFriendBalance = referFriendBalance
        profile.numberOfReferrals = Int16(numberOfReferrals)
        profile.mobileContactNumber = mobileContactNumber
        profile.mobileValidated = mobileValidated
        profile.acceptedMarketing = acceptedMarketing
        
        if let defaultBillingDetails = defaultBillingDetails {
            profile.defaultBillingDetails = defaultBillingDetails.store(in: context)
        }
        
        if
            let savedAddresses = savedAddresses,
            savedAddresses.count > 0
        {
            profile.savedAddresses = NSOrderedSet(array: savedAddresses.compactMap({ address -> AddressMO? in
                return address.store(in: context)
            }))
        }
        
        profile.fetchedForStoreId = Int64(storeId ?? 0)
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

extension Address {
    
    init(managedObject: AddressMO) {
        
        let location: Location?
        if
            let latitude = managedObject.latitude?.doubleValue,
            let longitude = managedObject.longitude?.doubleValue
        {
            location = Location(latitude: latitude, longitude: longitude)
        } else {
            location = nil
        }
        
        self.init(
            id: managedObject.id?.intValue,
            isDefault: managedObject.isDefault?.boolValue,
            addressName: managedObject.addressName,
            firstName: managedObject.firstName ?? "",
            lastName: managedObject.lastName ?? "",
            addressline1: managedObject.addressLine1 ?? "",
            addressline2: managedObject.addressLine2,
            town: managedObject.town ?? "",
            postcode: managedObject.postcode ?? "",
            county: managedObject.county,
            countryCode: managedObject.countryCode ?? "",
            type: AddressType(rawValue: managedObject.type ?? "delivery") ?? .delivery,
            location: location
        )
    }
    
    @discardableResult
    func store(in context: NSManagedObjectContext) -> AddressMO? {
        
        guard let address = AddressMO.insertNew(in: context)
            else { return nil }

        if let id = id {
            address.id = NSNumber(value: id)
        }
        
        if let isDefault = isDefault {
            address.isDefault = NSNumber(value: isDefault)
        }
        
        address.addressName = addressName
        address.firstName = firstName
        address.lastName = lastName
        address.addressLine1 = addressline1
        address.addressLine2 = addressline2
        address.town = town
        address.postcode = postcode
        address.county = county
        address.countryCode = countryCode
        address.type = type.rawValue
        
        if let location = location {
            address.latitude = NSNumber(value: location.latitude)
            address.longitude = NSNumber(value: location.longitude)
        }
        
        return address
    }
    
}
