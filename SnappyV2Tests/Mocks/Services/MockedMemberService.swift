//
//  MockedMemberService.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 19/12/2021.
//

import XCTest
import Combine
@testable import SnappyV2

struct MockedMemberService: Mock, MemberServiceProtocol {

    enum Action: Equatable {
        case login(email: String, password: String)
    }
    
    let actions: MockActions<Action>
    
    init(expected: [Action]) {
        self.actions = .init(expected: expected)
    }
    
    func login(email: String, password: String) -> Future<Void, Error> {
        register(.login(email: email, password: password))
        return Future { $0(.success(())) }
    }
    
}
