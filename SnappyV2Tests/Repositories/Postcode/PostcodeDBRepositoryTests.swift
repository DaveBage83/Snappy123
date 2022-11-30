//
//  PostcodeDBRepositoryTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 30/11/2022.
//

import XCTest
import Combine
@testable import SnappyV2

final class PostcodeDBRepositoryTests: XCTestCase {
    var mockedStore: MockedPersistentStore!
    var sut: PostcodeDBRepository!
    var cancelBag = CancelBag()
    
    override func setUp() {
        mockedStore = MockedPersistentStore()
        sut = PostcodeDBRepository(persistentStore: mockedStore)
        mockedStore.verify()
    }
    
    override func tearDown() {
        cancelBag = CancelBag()
        sut = nil
        mockedStore = nil
    }
    
    func test_whenStorePostcode_thenPostcodeStored() throws {
        let postcode = Postcode.mockedData
        
        mockedStore.actions = .init(expected: [
            .update(.init(inserted: 1, updated: 0, deleted: 0))
        ])
        
        try mockedStore.preloadData { context in
            // this will also set the timestamp
            postcode.store(in: context)
        }
        
        let exp = XCTestExpectation(description: #function)
        sut.store(postcode: postcode.postcode)
            .sinkToResult { result in
                switch result {
                case .success(let resultValue):
                    XCTAssertNotNil(resultValue)
                case .failure(let error):
                    XCTFail("Expected success, error: \(error)", file: #file, line: #line)
                }
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_whenFetchPostcode_thenPostcodeFetched() throws {
        let postcode = Postcode.mockedData
        
        mockedStore.actions = .init(expected: [
            .fetch(String(describing: PostcodeMO.self), .init(inserted: 0, updated: 0, deleted: 0))
        ])
        
        try mockedStore.preloadData { context in
            // this will also set the timestamp
            postcode.store(in: context)
        }
        
        let exp = XCTestExpectation(description: #function)
        sut.fetchPostcode(using: postcode.postcode)
            .sinkToResult { result in
                switch result {
                case .success(let resultValue):
                    XCTAssertNotNil(resultValue)
                case .failure(let error):
                    XCTFail("Expected success, error: \(error)", file: #file, line: #line)
                }
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
    }
    
    func test_whenDeletePostcode_thenPostcodeDeleted() throws {
        let postcode = Postcode.mockedData
        
        mockedStore.actions = .init(expected: [
            .update(.init(inserted: 0, updated: 0, deleted: 1))
        ])
        
        try mockedStore.preloadData { context in
            // this will also set the timestamp
            postcode.store(in: context)
        }
        
        let exp = XCTestExpectation(description: #function)
        sut.deletePostcode(postcodeString: postcode.postcode)
            .sinkToResult { result in
                switch result {
                case .success(let resultValue):
                    XCTAssertNotNil(resultValue)
                case .failure(let error):
                    XCTFail("Expected success, error: \(error)", file: #file, line: #line)
                }
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        wait(for: [exp], timeout: 0.5)
    }
}
