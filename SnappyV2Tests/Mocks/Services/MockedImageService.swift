//
//  MockedImageService.swift
//  SnappyV2Tests
//
//  Created by David Bage on 31/01/2022.
//

import XCTest
import Combine
@testable import SnappyV2

struct MockedImageService: Mock, ImageServiceProtocol {
    
    enum Action: Equatable {
        case load
    }
    
    let actions: MockActions<Action>
    
    init(expected: [Action]) {
        self.actions = .init(expected: expected)
    }
    
    func load(image: LoadableSubject<UIImage>, url: URL?) {
        register(.load)
    }
}
