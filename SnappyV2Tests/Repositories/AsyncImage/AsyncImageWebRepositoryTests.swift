//
//  AsyncImageWebRepositoryTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 09/11/2022.
//

import XCTest
import Combine
@testable import SnappyV2

final class AsyncImageWebRepositoryTests: XCTestCase {
    private var sut: AsyncImageWebRepository!
    private var subscriptions = Set<AnyCancellable>()
    
    typealias Mock = RequestMocking.MockedResponse
    
    override func setUp() {
        subscriptions = Set<AnyCancellable>()
        sut = AsyncImageWebRepository(
            baseURL: "https://test.com/",
            networkHandler: .mockedResponsesOnly)
    }
    
    override func tearDown() {
        RequestMocking.removeAllMocks()
    }
    
    func test_when_then() {
        let data = ImageDetails.mockedData
        
        
    }
    
}
