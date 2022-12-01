//
//  PostcodeService.swift
//  SnappyV2
//
//  Created by David Bage on 26/11/2022.
//

import Foundation
import Combine
import OSLog

protocol SearchHistoryServiceProtocol {
    func getPostcode(postcodeString: String) async -> Postcode?
    func storePostcode(postcodeString: String) async
    func getAllPostcodes() async -> [Postcode]?
}

struct SearchHistoryService: SearchHistoryServiceProtocol {
    let dbRepository: SearchHistoryDBRepositoryProtocol
    
    var cancellables = Set<AnyCancellable>()
    
    func getPostcode(postcodeString: String) async -> Postcode? {
        
        do {
            let postcode = try await dbRepository.fetchPostcode(using: postcodeString).singleOutput()
            return postcode
        } catch {
            Logger.postcodeStorage.error("Failed to fetch postcode")
            return nil
        }
    }
    
    func getAllPostcodes() async -> [Postcode]? {
        return dbRepository.fetchAllPostcodes()
    }
    
    func storePostcode(postcodeString: String) async {
        do {
            let _ = try await dbRepository.store(postcode: postcodeString).singleOutput()
        } catch {
            Logger.postcodeStorage.error("Failed to store postcode")
        }
    }
}

struct StubPostcodeService: SearchHistoryServiceProtocol {
    func getAllPostcodes() async -> [Postcode]? {
        return nil
    }
    
    func getPostcode(postcodeString: String) async -> Postcode? {
        return nil
    }
    
    func storePostcode(postcodeString: String) async {}
}
