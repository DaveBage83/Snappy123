//
//  Member+CoreData.swift
//  SnappyV2
//
//  Created by Kevin Palser on 29/12/2021.
//

import Foundation
import CoreData

extension MemberProfileMO: ManagedEntity { }

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
        
        profile.timestamp = Date()

        return profile
    }
    
}
