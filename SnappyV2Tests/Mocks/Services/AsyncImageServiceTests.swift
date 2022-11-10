//
//  AsyncImageServiceTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 14/11/2022.
//

import XCTest
import Combine
@testable import SnappyV2

class AsyncImageServiceTests: XCTestCase {
    var appState = CurrentValueSubject<AppState, Never>(AppState())
    var mockedEventLogger: MockedEventLogger!
    var mockedWebRepo: MockedAsyncImageWebRepository!
    var mockedDBRepo: MockedAsyncImageDBRepository!
    var subscriptions = Set<AnyCancellable>()
    var sut: AsyncImageService!

    override func setUp() {
        
        mockedEventLogger = MockedEventLogger()
        mockedWebRepo = MockedAsyncImageWebRepository()
        mockedDBRepo = MockedAsyncImageDBRepository()
        sut = AsyncImageService(
            webRepository: mockedWebRepo,
            dbRepository: mockedDBRepo,
            eventLogger: mockedEventLogger)
    }
    
    func delay(_ closure: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: closure)
    }

    override func tearDown() {
        appState = CurrentValueSubject<AppState, Never>(AppState())
        subscriptions = Set<AnyCancellable>()
        mockedEventLogger = nil
        mockedWebRepo = nil
        mockedDBRepo = nil
        sut = nil
    }
}

final class LoadAsyncImageTests: AsyncImageServiceTests {
    func test_when_then() async {
        let imageDetails = ImageDetails.mockedData
        
        let loadedImage = await sut.loadImage(url: imageDetails.fetchURLString)
    }
}
