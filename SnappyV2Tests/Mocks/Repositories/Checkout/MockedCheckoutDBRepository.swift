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
        case clearLastDeliveryOrderOnDevice
        case store(lastDeliveryOrderOnDevice: LastDeliveryOrderOnDevice)
        case lastDeliveryOrderOnDevice
    }
    var actions = MockActions<Action>(expected: [])
    
    var lastDeliveryOrderOnDeviceResult: Result<LastDeliveryOrderOnDevice?, Error> = .failure(MockError.valueNotSet)
    
    func clearBasket() async throws {
        register(.clearBasket)
    }
    
    func clearLastDeliveryOrderOnDevice() async throws {
        register(.clearLastDeliveryOrderOnDevice)
    }
    
    func store(lastDeliveryOrderOnDevice: LastDeliveryOrderOnDevice) async throws {
        register(.lastDeliveryOrderOnDevice)
    }
    
    func lastDeliveryOrderOnDevice() async throws -> LastDeliveryOrderOnDevice? {
        register(.lastDeliveryOrderOnDevice)
        switch lastDeliveryOrderOnDeviceResult {
        case let .success(result):
            return result
        case let .failure(error):
            throw error
        }
    }
    
}
