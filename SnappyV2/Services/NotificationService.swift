//
//  NotificationService.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 13/04/2022.
//

import Foundation

protocol NotificationServiceProtocol {
    func addItemToBasket(itemName: String, quantity: Int) async
    func updateItemInBasket(itemName: String) async
    func removeItemFromBasket(itemName: String) async
}

struct NotificationService: NotificationServiceProtocol {
    typealias NotificationStrings = Strings.ToastNotifications
    
    let appState: Store<AppState>
    
    func addItemToBasket(itemName: String, quantity: Int) async {
        await MainActor.run {
            appState.value.notifications.showAddItemToBasketToast = true
            let subTitleString = quantity > 1 ? NotificationStrings.BasketChangesItem.addedMoreItemsToBasket.localizedFormat(itemName, "\(quantity)") : NotificationStrings.BasketChangesItem.addedOneItemToBasket.localizedFormat(itemName)
            appState.value.notifications.addItemToBasketAlertToast = AlertToast(
                displayMode: .banner(.pop),
                type: .complete(.green),
                title: NotificationStrings.BasketChangeTitle.itemAdded.localized,
                subTitle: subTitleString)
        }
    }
    
    func updateItemInBasket(itemName: String) async  {
        await MainActor.run {
            appState.value.notifications.showAddItemToBasketToast = true
            appState.value.notifications.addItemToBasketAlertToast = AlertToast(
                displayMode: .banner(.pop),
                type: .complete(.green),
                title: NotificationStrings.BasketChangeTitle.itemUpdated.localized,
                subTitle: NotificationStrings.BasketChangesItem.updatedItemInBasket.localizedFormat(itemName))
        }
    }
    
    func removeItemFromBasket(itemName: String) async {
        await MainActor.run {
            appState.value.notifications.showAddItemToBasketToast = true
            appState.value.notifications.addItemToBasketAlertToast = AlertToast(
                displayMode: .banner(.pop),
                type: .complete(.green),
                title: NotificationStrings.BasketChangeTitle.itemRemoved.localized,
                subTitle: NotificationStrings.BasketChangesItem.removedItemFromBasket.localizedFormat(itemName))
        }
    }
}

struct StudNotificationService: NotificationServiceProtocol {
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
