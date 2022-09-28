//
//  DeepLinkHandlerTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 28/09/2022.
//

import XCTest
import Combine
@testable import SnappyV2

final class DeepLinkHandlerTests: XCTestCase {
    
    func test_setupRestoreFinishedBinding_givenRestoreFinishes_thenProcessPostponedActions() {
        
        let resetToken = "p6rGf6KLBD"
        guard let resetPasswordDeepLink = DeepLink(url: URL(string: "https://beta.snappyshopper.co.uk/member/reset-token/" + resetToken)!) else {
            XCTFail("Unable to initiate/match reset password deep link", file: #file, line: #line)
            return
        }
        
        let sut = makeSUT()
        sut.container.appState.value.postponedActions.deepLinks = [
            resetPasswordDeepLink
        ]
        
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: #function)
        
        sut.container.appState
            .map(\.postponedActions.deepLinks)
            .first(where: { $0.count == 0 })
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.container.appState.value.postponedActions.restoreFinished = true
        
        wait(for: [expectation], timeout: 2.0)

        XCTAssertEqual(sut.container.appState.value.passwordResetCode, resetToken)
    }
    
    func test_openDeepLink_givenRestoreNotFinished_thenAddDeepLinkToQueue() {
        
        let resetToken = "p6rGf6KLBD"
        guard let resetPasswordDeepLink = DeepLink(url: URL(string: "https://beta.snappyshopper.co.uk/member/reset-token/" + resetToken)!) else {
            XCTFail("Unable to initiate/match reset password deep link", file: #file, line: #line)
            return
        }
        
        let sut = makeSUT()
        sut.open(deepLink: resetPasswordDeepLink)
        
        XCTAssertEqual(sut.container.appState.value.postponedActions.deepLinks, [resetPasswordDeepLink], file: #file, line: #line)
    }
    
    func test_openDeepLink_givenRestoreFinished_thenUpdateAppState() {
        
        let resetToken = "p6rGf6KLBD"
        guard let resetPasswordDeepLink = DeepLink(url: URL(string: "https://beta.snappyshopper.co.uk/member/reset-token/" + resetToken)!) else {
            XCTFail("Unable to initiate/match reset password deep link", file: #file, line: #line)
            return
        }
        
        let sut = makeSUT()
        sut.container.appState.value.postponedActions.restoreFinished = true
        sut.open(deepLink: resetPasswordDeepLink)
        
        XCTAssertEqual(sut.container.appState.value.postponedActions.deepLinks.count, 0, file: #file, line: #line)
        XCTAssertEqual(sut.container.appState.value.passwordResetCode, resetToken, file: #file, line: #line)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())) -> DeepLinksHandler {
        let sut = DeepLinksHandler(container: container)
        trackForMemoryLeaks(sut)
        return sut
    }
}
