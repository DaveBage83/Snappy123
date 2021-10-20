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
    
    func test_assignWeak() {
        
        let sut = Class2()
        
        sut.runAssignWeak()
        
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
        
        func runAssignWeak() {
            one.string
                .assignWeak(to: \.class1String, on: self)
                .store(in: &cancellables)
        }
    }
}
