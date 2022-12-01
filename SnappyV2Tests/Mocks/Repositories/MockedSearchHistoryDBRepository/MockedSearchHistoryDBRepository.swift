//
//  MockedSearchHistoryDBRepository.swift
//  SnappyV2Tests
//
//  Created by David Bage on 29/11/2022.
//

import XCTest
import Combine
@testable import SnappyV2

final class MockedSearchHistoryDBRepository: Mock, SearchHistoryDBRepositoryProtocol {
    
    enum Action: Equatable {
        case fetchPostcode(postcodeString: String)
        case store(postcode: String)
        case fetchAllPostcodes
    }
    
    var actions = MockActions<Action>(expected: [])
    
    var fetchPostcode: Result<Postcode?, Error> = .success(Postcode.mockedData)
    var storePostcode: Result<Postcode?, Error> = .failure(MockError.valueNotSet)
    var fetchPostcodes: [Postcode]?
    
    
    func fetchPostcode(using postcodeString: String) -> AnyPublisher<SnappyV2.Postcode?, Error> {
        register(.fetchPostcode(postcodeString: postcodeString))
        return fetchPostcode.publish()
    }
    
    func store(postcode: String) -> AnyPublisher<SnappyV2.Postcode?, Error> {
        register(.store(postcode: postcode))
        return storePostcode.publish()
    }
    
    func fetchAllPostcodes() -> [Postcode]? {
        register(.fetchAllPostcodes)
        return [.mockedData]
    }
}
