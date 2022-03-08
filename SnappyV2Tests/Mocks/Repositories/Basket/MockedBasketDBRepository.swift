//
//  MockedBasketDBRepository.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 07/02/2022.
//

import XCTest
import Combine
@testable import SnappyV2

final class MockedBasketDBRepository: Mock, BasketDBRepositoryProtocol {
    
    enum Action: Equatable {
        case clearBasket
        case store(basket: Basket)
        case fetchBasket
    }
    var actions = MockActions<Action>(expected: [])
    
    var clearBasketResult: Result<Bool, Error> = .failure(MockError.valueNotSet)
    var storeBasketResult: Result<Basket, Error> = .failure(MockError.valueNotSet)
    var fetchBasketResult: Result<Basket?, Error> = .failure(MockError.valueNotSet)
    
    func clearBasket() -> AnyPublisher<Bool, Error> {
        register(.clearBasket)
        return clearBasketResult.publish()
    }
    
    func store(basket: Basket) -> AnyPublisher<Basket, Error> {
        register(.store(basket: basket))
        return storeBasketResult.publish()
    }
    
    func fetchBasket() -> AnyPublisher<Basket?, Error> {
        register(.fetchBasket)
        return fetchBasketResult.publish()
    }

}
