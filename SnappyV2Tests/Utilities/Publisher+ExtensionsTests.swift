//
//  Publisher+ExtensionsTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 04/08/2021.
//

import XCTest
import Combine
@testable import SnappyV2

class Publisher_ExtensionsTests: XCTestCase {
    
    func test_assignNoRetain() {
        
        let sut = Class2()
        
        sut.runAssignNoRetain()
        
        trackForMemoryLeaks(sut)
    }
    
    class Class1 {
        private(set) var string: CurrentValueSubject<String, Never> = CurrentValueSubject<String, Never>("")
        
        init() {
            string.send("john")
        }
    }
    
    class Class2 {
        @Published var class1String: String = ""
        
        private let one = Class1()
        private var cancellables = Set<AnyCancellable>()
        
        func runAssignNoRetain() {
            one.string
                .assignNoRetain(to: \.class1String, on: self)
                .store(in: &cancellables)
        }
    }
}
