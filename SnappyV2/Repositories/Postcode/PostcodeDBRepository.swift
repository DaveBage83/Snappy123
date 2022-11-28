//
//  PostcodeDBRepository.swift
//  SnappyV2
//
//  Created by David Bage on 26/11/2022.
//

import Foundation
import Combine

enum PostcodeError: Swift.Error, Equatable {
    case unableToSave
}

protocol PostcodeDBRepositoryProtocol {
    func fetchPostcode(using postcodeString: String) -> AnyPublisher<Postcode?, Error>
    func store(postcode: String) -> AnyPublisher<Postcode?, Error>
    func fetchAllPostcodes() -> [Postcode]?
}

struct PostcodeDBRepository: PostcodeDBRepositoryProtocol {
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
        let storedResults = persistentStore.fetch(fetchRequest)
        
        storedResults?.forEach { result in
            if let timestamp = result.timestamp, let postcode = result.postcode {
                postcodes.append(Postcode(timestamp: timestamp, postcode: postcode))
            }
            
        }
 
        return postcodes
    }
    
    // Store postcode
    func store(postcode: String) -> AnyPublisher<Postcode?, Error> {
        let postcodes = fetchAllPostcodes()
        
        let trimmedPostcodeStrings = postcodes?.compactMap({ $0.postcode.removeWhitespace() })
        
        let searchedTrimmedString = postcode.removeWhitespace()
        
        print(trimmedPostcodeStrings)
        print(searchedTrimmedString)
        
        if trimmedPostcodeStrings?.contains(searchedTrimmedString) == false
            
        {
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

extension String {
    func replace(string:String, replacement:String) -> String {
        return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }

    func removeWhitespace() -> String {
        return self.replace(string: " ", replacement: "")
    }
  }
