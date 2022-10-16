//
//  NotificationService.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 13/04/2022.
//

import Foundation

protocol NotificationServiceProtocol {
    func addItemToBasket(itemName: String, quantity: Int)
    func updateItemInBasket(itemName: String)
    func removeItemFromBasket(itemName: String)
}

struct NotificationService: NotificationServiceProtocol {
    typealias NotificationStrings = Strings.ToastNotifications
    
    let appState: Store<AppState>
    
    func addItemToBasket(itemName: String, quantity: Int) {
        guaranteeMainThread {
            appState.value.notifications.showAddItemToBasketToast = true
            let subTitleString = quantity > 1 ? NotificationStrings.BasketChangesItem.addedMoreItemsToBasket.localizedFormat(itemName, "\(quantity)") : NotificationStrings.BasketChangesItem.addedOneItemToBasket.localizedFormat(itemName)
            appState.value.notifications.addItemToBasketAlertToast = AlertToast(
                displayMode: .banner(.pop),
                type: .complete(.green),
                title: NotificationStrings.BasketChangeTitle.itemAdded.localized,
                subTitle: .constant(subTitleString), tapToDismiss: false)
        }
    }
    
    func updateItemInBasket(itemName: String) {
        guaranteeMainThread {
            appState.value.notifications.showAddItemToBasketToast = true
            appState.value.notifications.addItemToBasketAlertToast = AlertToast(
                displayMode: .banner(.pop),
                type: .complete(.green),
                title: NotificationStrings.BasketChangeTitle.itemUpdated.localized,
                subTitle: .constant(NotificationStrings.BasketChangesItem.updatedItemInBasket.localizedFormat(itemName)), tapToDismiss: false)
        }
    }
    
    func removeItemFromBasket(itemName: String) {
        guaranteeMainThread {
            appState.value.notifications.showAddItemToBasketToast = true
            appState.value.notifications.addItemToBasketAlertToast = AlertToast(
                displayMode: .banner(.pop),
                type: .complete(.green),
                title: NotificationStrings.BasketChangeTitle.itemRemoved.localized,
                subTitle: .constant(NotificationStrings.BasketChangesItem.removedItemFromBasket.localizedFormat(itemName)), tapToDismiss: false)
        }
    }
}

struct StubNotificationService: NotificationServiceProtocol {
    func addItemToBasket(itemName: String, quantity: Int) {
        //
    }
    
    func updateItemInBasket(itemName: String) {
        //
    }
    
    func removeItemFromBasket(itemName: String) {
        //
    }
}
