//
//  MockedAsyncImageWebRepository.swift
//  SnappyV2Tests
//
//  Created by David Bage on 09/11/2022.
//

import XCTest
@testable import SnappyV2

final class MockedAsyncImageWebRepository: TestWebRepository, Mock, AsyncImageWebRepositoryProtocol {
    
    enum Action: Equatable {
        case fetchImageFromWeb(_ urlRequest: URLRequest)
    }
    
    var actions = MockActions<Action>(expected: [])
    
    func fetch(_ urlRequest: URLRequest) async throws -> UIImage? {
        return UIImage(systemName: "star")
    }
}
