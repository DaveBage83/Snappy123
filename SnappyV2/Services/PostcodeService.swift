//
//  PostcodeService.swift
//  SnappyV2
//
//  Created by David Bage on 26/11/2022.
//

import Foundation
import Combine

protocol PostcodeServiceProtocol {
    func getPostcode(postcodeString: String) async -> Postcode?
    func storePostcode(postcodeString: String) async
    func getAllPostcodes() async -> [Postcode]?
}

struct PostcodeService: PostcodeServiceProtocol {
    let dbRepository: PostcodeDBRepositoryProtocol
    
    var cancellables = Set<AnyCancellable>()
    
    func getPostcode(postcodeString: String) async -> Postcode? {
        
        do {
            let postcode = try await dbRepository.fetchPostcode(using: postcodeString).singleOutput()
            return postcode
        } catch {
            print("Unable to fetch results")
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
            print("Failed to store postcode")
        }
    }
}

struct StubPostcodeService: PostcodeServiceProtocol {
    func getAllPostcodes() async -> [Postcode]? {
        return nil
    }
    
    func getPostcode(postcodeString: String) async -> Postcode? {
        return nil
    }
    
    func storePostcode(postcodeString: String) async {
        print("Done")
    }
}
