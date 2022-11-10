//
//  MockedAsyncImageService.swift
//  SnappyV2Tests
//
//  Created by David Bage on 31/01/2022.
//
//
import XCTest
import Combine
@testable import SnappyV2

struct MockedAsyncImageService: Mock, AsyncImageServiceProtocol {

    enum Action: Equatable {
        case loadImage
    }

    let actions: MockActions<Action>

    init(expected: [Action]) {
        self.actions = .init(expected: expected)
    }
    
    func loadImage(url: String) async -> UIImage {
        return UIImage(systemName: "star")!
    }
    
    func clearAllStaleData() {}
}
