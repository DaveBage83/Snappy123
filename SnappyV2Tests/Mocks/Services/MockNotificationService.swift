//
//  MockNotificationService.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 14/04/2022.
//

import Foundation
@testable import SnappyV2

struct MockedNotificationService: Mock, NotificationServiceProtocol {
    enum Action: Equatable {
        case addingItemToBasket(itemName: String, qauntity: Int)
        case updateItemInBasket(itemName: String)
        case removeItemFromBasket(itemName: String)
    }
    
    var actions: MockActions<Action>
    
    init(expected: [Action] = []) {
        self.actions = .init(expected: expected)
    }
    
    func addItemToBasket(itemName: String, quantity: Int) {
        register(.addingItemToBasket(itemName: itemName, qauntity: quantity))
    }
    
    func updateItemInBasket(itemName: String) {
        register(.updateItemInBasket(itemName: itemName))
    }
    
    func removeItemFromBasket(itemName: String) {
        register(.removeItemFromBasket(itemName: itemName))
    }
}
