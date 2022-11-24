//
//  AsynImageDBRepositoryTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 09/11/2022.
//

import XCTest
import Combine
import CoreLocation
@testable import SnappyV2

class AsyncImageDBRepositoryTests: XCTestCase {
    var mockedStore: MockedPersistentStore!
    var sut: AsyncImageDBRepository!
    var cancelBag = CancelBag()
    
    override func setUp() {
        mockedStore = MockedPersistentStore()
        sut = AsyncImageDBRepository(persistentStore: mockedStore)
        mockedStore.verify()
    }
    
    override func tearDown() {
        cancelBag = CancelBag()
        sut = nil
        mockedStore = nil
    }
}

final class AsyncImageDBRepositoryProtocolTests: AsyncImageDBRepositoryTests {
    func test_storeImage() {
        let imageDetails = ImageDetails.mockedData
        
        mockedStore.actions = .init(expected: [
            .update(.init(
                inserted: imageDetails.recordsCount,
                updated: 0,
                deleted: 0))
        ])
        
        let exp = XCTestExpectation(description: #function)
        
        sut.store(image: UIImage(named: AppV2Constants.Business.placeholderImage)!, urlString: "testURLString")
            .sinkToResult { result in
//                result.assertSuccess(value: imageDetails)
                self.mockedStore.verify()
                exp.fulfill()
            }
            .store(in: cancelBag)
        
        wait(for: [exp], timeout: 2)
    }
    
//    func test_clearImage() {
//        let imageDetails = ImageDetails.mockedData
//
//        mockedStore.actions = .init(expected: [
//            .update(.init(
//                inserted: 0,
//                updated: 0,
//                deleted: 1))
//        ])
//
//        do {
//            try mockedStore.preloadData { context in
//                imageDetails.store(in: context)
//            }
//        } catch {
//            XCTFail("Failed to preload data")
//        }
//
//        let exp = XCTestExpectation(description: #function)
//        sut.clearImageData(urlString: "testURLString")
//            .sinkToResult { result in
//                result.assertSuccess(value: true)
//                self.mockedStore.verify()
//                exp.fulfill()
//            }
//            .store(in: cancelBag)
//        wait(for: [exp], timeout: 2)
//    }
}
