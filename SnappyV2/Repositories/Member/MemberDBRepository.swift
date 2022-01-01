//
//  MemberDBRepository.swift
//  SnappyV2
//
//  Created by Kevin Palser on 16/12/2021.
//

import CoreData
import Combine

protocol MemberDBRepositoryProtocol {
    
    func clearMemberProfile() -> AnyPublisher<Bool, Error>
    
    func store(memberProfile: MemberProfile) -> AnyPublisher<MemberProfile, Error>
    
}

struct MemberDBRepository: MemberDBRepositoryProtocol {

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
    
    func store(memberProfile: MemberProfile) -> AnyPublisher<MemberProfile, Error> {
        return persistentStore
            .update { context in
                
                guard let memberProfileMO = memberProfile.store(in: context) else {
                    throw RetailStoreMenuServiceError.unableToPersistResult
                }
                
                return MemberProfile(managedObject: memberProfileMO)
            }
    }
    
}

// MARK: - Fetch Requests

extension MemberProfileMO {

    static func fetchRequestResult() -> NSFetchRequest<NSFetchRequestResult> {
        let request = newFetchRequestResult()
        request.fetchLimit = 1
        return request
    }
    
//    static var fetchRequestLast: NSFetchRequest<memberProfileMO> {
//        let request = newFetchRequest()
//        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
//        request.fetchLimit = 1
//        request.returnsObjectsAsFaults = false
//        return request
//    }

}
