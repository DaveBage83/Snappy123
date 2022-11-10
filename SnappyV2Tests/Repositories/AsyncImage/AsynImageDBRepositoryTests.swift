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
    
    override func setUp() {
        mockedStore = MockedPersistentStore()
        sut = AsyncImageDBRepository(persistentStore: mockedStore)
        mockedStore.verify()
    }
    
    override func tearDown() {
        sut = nil
        mockedStore = nil
    }
}

final class AsyncImageDBRepositoryProtocolTests: AsyncImageDBRepositoryTests {
    
    func test_fetchImage() async {
        let imageDetails = ImageDetails.mockedData
        
        mockedStore.actions = .init(expected: [
            .fetch(String(describing: CachedImageMO.self), .init(inserted: 0, updated: 0, deleted: 0))
        ])
        
        do {
            try await mockedStore.preloadData { context in
                imageDetails.store(in: context)
            }
        } catch {
            XCTFail("Failed to preload image")
        }
                
        do {
            let image = try await sut.fetchImage(urlString: imageDetails.fetchURLString).singleOutput()
            XCTAssertEqual(image?.fetchURLString, imageDetails.fetchURLString)
        } catch {
            XCTFail("Unable to fetch image")
        }
    }
    
    func test_clearImage() async {
        let imageDetails = ImageDetails.mockedDataExpiredCache

        mockedStore.actions = .init(expected: [
            .update(.init(
                inserted: 0,
                updated: 0,
                deleted: 1))
        ])

        do {
            try await mockedStore.preloadData { context in
                imageDetails.store(in: context, timeStamp: Calendar.current.date(byAdding: .hour, value: -10, to: Date())!)
            }
        } catch {
            XCTFail("Failed to preload data")
        }

        do {
            let result = try await sut.clearImageData(urlString: imageDetails.fetchURLString).singleOutput()
            XCTAssertTrue(result)
            self.mockedStore.verify()
        } catch {
            XCTFail("Failed to clear image")
        }
    }
    
    func test_clearAllImages() async {
        let imageDetails = ImageDetails.mockedDataExpiredCache
        
        mockedStore.actions = .init(expected: [
            .update(.init(
                inserted: 0,
                updated: 0,
                deleted: 1))
        ])
        
        do {
            try await mockedStore.preloadData { context in
                imageDetails.store(in: context, timeStamp: Calendar.current.date(byAdding: .hour, value: -10, to: Date())!)
            }
        } catch {
            XCTFail("Failed to preload data")
        }
        
        let _ = sut.clearAllStaleImageData()
        self.mockedStore.verify()
    }
    
    func test_storeImage() async {
        let imageDetails = ImageDetails.mockedData
        
        mockedStore.actions = .init(expected: [
            .update(.init(
                inserted: imageDetails.recordsCount,
                updated: 0,
                deleted: 0))
        ])
                
        do {
            let result = try await sut.store(image: UIImage(systemName: "star")!, urlString: imageDetails.fetchURLString).singleOutput()
            self.mockedStore.verify()
            XCTAssertEqual(imageDetails.fetchTimestamp?.dateOnlyString(storeTimeZone: nil), result.fetchTimestamp?.dateOnlyString(storeTimeZone: nil))
            XCTAssertEqual(imageDetails.fetchTimestamp?.timeString(storeTimeZone: nil), result.fetchTimestamp?.timeString(storeTimeZone: nil))
            XCTAssertEqual(imageDetails.fetchURLString, result.fetchURLString)
            XCTAssertNotNil(imageDetails.image?.size)
        } catch {
            XCTFail("Failed to get result")
        }
    }
}
