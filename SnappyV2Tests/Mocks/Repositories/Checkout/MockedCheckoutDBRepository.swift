//
//  MockedCheckoutDBRepository.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 07/02/2022.
//

import XCTest
import Combine
@testable import SnappyV2

final class MockedCheckoutDBRepository: Mock, CheckoutDBRepositoryProtocol {

    enum Action: Equatable {
        case clearBasket
    }
    var actions = MockActions<Action>(expected: [])
    
    var clearBasketResult: Result<Bool, Error> = .failure(MockError.valueNotSet)
    
    func clearBasket() -> AnyPublisher<Bool, Error> {
        register(.clearBasket)
        return clearBasketResult.publish()
    }
    
}
