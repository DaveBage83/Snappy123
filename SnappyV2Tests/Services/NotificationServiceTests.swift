//
//  NotificationServiceTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 14/04/2022.
//

import Foundation
import Combine
@testable import SnappyV2
import XCTest

class NotificationServiceTests: XCTestCase {
    
    var appState = CurrentValueSubject<AppState, Never>(AppState())
    var sut: NotificationService!
    
    override func setUp() {
        sut = NotificationService(
            appState: appState
        )
    }
    
    override func tearDown() {
        sut = nil
    }
    
    func test_addingTwoItemsToBasket() {
        let itemName = "Absolut Vodka"
        let itemQuantity = 2
        sut.addItemToBasket(itemName: itemName, quantity: itemQuantity)
        
        XCTAssertTrue(appState.value.notifications.showAddItemToBasketToast, file: #file, line: #line)
        XCTAssertEqual(appState.value.notifications.addItemToBasketAlertToast, AlertToast(displayMode: .banner(.pop), type: .complete(.green), title: "Item Added", subTitle: "Absolut Vodka x 2 have been added to basket", tapToDismiss: false), file: #file, line: #line)
    }
    
    func test_addingOneItemToBasket() {
        let itemName = "Absolut Vodka"
        let itemQuantity = 1
        sut.addItemToBasket(itemName: itemName, quantity: itemQuantity)
        
        XCTAssertTrue(appState.value.notifications.showAddItemToBasketToast, file: #file, line: #line)
        XCTAssertEqual(appState.value.notifications.addItemToBasketAlertToast, AlertToast(displayMode: .banner(.pop), type: .complete(.green), title: "Item Added", subTitle: "Absolut Vodka has been added to basket", tapToDismiss: false), file: #file, line: #line)
    }
    
    func test_changingOneItemToBasket() {
        let itemName = "Absolut Vodka"
        let itemQuantity = 1
        sut.addItemToBasket(itemName: itemName, quantity: itemQuantity)
        
        XCTAssertTrue(appState.value.notifications.showAddItemToBasketToast, file: #file, line: #line)
        XCTAssertEqual(appState.value.notifications.addItemToBasketAlertToast, AlertToast(displayMode: .banner(.pop), type: .complete(.green), title: "Item Added", subTitle: "Absolut Vodka has been added to basket", tapToDismiss: false), file: #file, line: #line)
    }
}

