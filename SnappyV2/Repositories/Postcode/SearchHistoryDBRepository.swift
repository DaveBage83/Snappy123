//
//  PostcodeDBRepository.swift
//  SnappyV2
//
//  Created by David Bage on 26/11/2022.
//

import Foundation
import Combine
import OSLog

enum PostcodeError: Swift.Error, Equatable {
    case unableToSave
}

protocol SearchHistoryDBRepositoryProtocol {
    func fetchPostcode(using postcodeString: String) -> AnyPublisher<Postcode?, Error>
    func store(postcode: String) -> AnyPublisher<Postcode?, Error>
    func fetchAllPostcodes() -> [Postcode]?
}

struct SearchHistoryDBRepository: SearchHistoryDBRepositoryProtocol {
    let persistentStore: PersistentStore
    
    // Fetch postcode
    func fetchPostcode(using postcodeString: String) -> AnyPublisher<Postcode?, Error> {
        let fetchRequest = PostcodeMO.fetchRequest(postcode: postcodeString)
        return persistentStore
            .fetch(fetchRequest) {
                Postcode(managedObject: $0)
            }
            .map { $0.first }
            .eraseToAnyPublisher()
    }
    
    func fetchAllPostcodes() -> [Postcode]? {
        let fetchRequest = PostcodeMO.fetchAllPostcodes()
        var postcodes = [Postcode]()
        
        do {
            let storedResults = try persistentStore.fetch(fetchRequest)
            
            storedResults?.forEach { result in
                if let timestamp = result.timestamp, let postcode = result.postcode {
                    postcodes.append(Postcode(timestamp: timestamp, postcode: postcode))
                }
                
            }
     
            return postcodes
        } catch {
            Logger.postcodeStorage.info("No postcodes fetched")
            return nil
        }
    }
    
    func deletePostcode(postcodeString: String) -> AnyPublisher<Bool, Error> {
        return persistentStore
            .update { context in
                try PostcodeMO.delete(
                    fetchRequest: PostcodeMO.fetchRequestForDeletion(postcode: postcodeString),
                    in: context)
                return true
            }
    }
    
    // Store postcode
    func store(postcode: String) -> AnyPublisher<Postcode?, Error> {
        let postcodes = fetchAllPostcodes()
        
        let trimmedPostcodeStrings = postcodes?.compactMap({ $0.postcode.removeWhitespace() })
        
        let searchedTrimmedString = postcode.removeWhitespace()
        
        // If there are no matching postcodes then we will save this one
        if trimmedPostcodeStrings?.contains(searchedTrimmedString) == false {
            // First check if we have more than the allowed number of postcodes in the db as specified by the AppConstants
            if let postcodes, postcodes.count > AppV2Constants.Business.maximumPostcodes {
                // If so, get the earliest saved one...
                let postcodeToDelete = postcodes.min(by: { $0.timestamp < $1.timestamp })?.postcode
                
                // ... and delete it
                if let postcodeToDelete {
                    let _ = deletePostcode(postcodeString: postcodeToDelete)
                }
            }
            
            return persistentStore
                .update { context in
                    let postcode = Postcode(timestamp: Date(), postcode: postcode)
                    return postcode.store(in: context).flatMap {
                        Postcode(managedObject: $0)
                    }
                }
        }
        return Fail(error: PostcodeError.unableToSave).eraseToAnyPublisher()
    }
}
