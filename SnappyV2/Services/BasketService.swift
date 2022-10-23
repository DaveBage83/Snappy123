//
//  BasketService.swift
//  SnappyV2
//
//  Created by Kevin Palser on 25/10/2021.
//

import Combine
import Foundation
import SwiftUI

// 3rd party
import AppsFlyerLib
import FBSDKCoreKit
import Firebase

enum BasketServiceError: Swift.Error {
    case storeSelectionRequired
    case fulfilmentLocationRequired
    case memberRequiredToBeSignedIn
    case unableToPersistResult
    case unableToProceedWithoutBasket // really should never get to this
    case unableToProceedWithoutPostcode // really should never get to this
}

extension BasketServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .storeSelectionRequired:
            return "Ordering location selection is required"
        case .fulfilmentLocationRequired:
            return "Fulfilment location is required"
        case .memberRequiredToBeSignedIn:
            return "function requires member to be signed in"
        case .unableToPersistResult:
            return "Unable to persist web fetch result"
        case .unableToProceedWithoutBasket:
            return "Unable to proceed because of missing basket information"
        case .unableToProceedWithoutPostcode:
            return "Unable to proceed because of missing postcode"
        }
    }
}

protocol BasketServiceProtocol {
    
    // TODO: isFirstOrder logic
    
    // Any of these functions will be placed in a queue and run in serial to ensure that the result of
    // the potentially mutated basket is received and the app has opportunity to react to each response
    // before the next operation.
    
    // When opening the app, we need to restore the basket. This function will load the basket from the
    // persistent store. If there is a basket it will use the token to get the basket from the server to
    // ensure that it still has a menu compatible version.
    func restoreBasket() async throws
    
    // Everytime the fulfilment method and/or store changes this method should be called. It is required
    // because the pricing can change, items cleared, deals or coupons have different incompatbile
    // criteria etc
    func updateFulfilmentMethodAndStore() async throws
    
    func reserveTimeSlot(timeSlotDate: String, timeSlotTime: String?) async throws
    func addItem(basketItemRequest: BasketItemRequest, item: RetailStoreMenuItem) async throws
    func updateItem(basketItemRequest: BasketItemRequest, basketItem: BasketItem) async throws
    func changeItemQuantity(basketItem: BasketItem, changeQuantity: Int) async throws
    func removeItem(basketLineId: Int, item: RetailStoreMenuItem) async throws
    func applyCoupon(code: String) async throws
    func removeCoupon() async throws
    func clearItems() async throws
    func setContactDetails(to: BasketContactDetailsRequest) async throws
    func setDeliveryAddress(to: BasketAddressRequest) async throws
    func setBillingAddress(to: BasketAddressRequest) async throws
    func updateTip(to: Double) async throws
    func populateRepeatOrder(businessOrderId: Int) async throws
    
    // All the above functions will check if a basket already exists. If a basket does not exist they
    // create a new basket before performing the action. Otherwise they continue by performing the action
    // on the existing basket. The getNewBasket() differs because it explicitly forgets the old basket
    // and fectches a new one. Its intended purpose is after checking out an order.
    func getNewBasket() async throws
    
    // Useful during development to add a delay before another operation in queuePublisher
    // in processed
    func test(delay: TimeInterval) async
}

// We're using an actor here instead of a struct as it gives
// us a protected state from race conditions which in essence
// becomes a simplified queueing mechanism where each function
// cannot be triggered simultaneously. It is priority driven,
// so the functions should ideally be triggered from the main actor
// in order not to suspended when when a higher priority (i.e. UI)
// demands it.
actor BasketService: BasketServiceProtocol {
    let webRepository: BasketWebRepositoryProtocol
    let dbRepository: BasketDBRepositoryProtocol
    let notificationService: NotificationServiceProtocol
    
    // Example in the clean architecture Countries example of the appState
    // being passed to a service (but not used the code). Using this as
    // a justification to be an acceptable method to update the Basket
    // Henrik/Kevin: 2021-10-26
    nonisolated let appState: Store<AppState>
    
    let eventLogger: EventLoggerProtocol
    
    init(webRepository: BasketWebRepositoryProtocol, dbRepository: BasketDBRepositoryProtocol, notificationService: NotificationServiceProtocol, appState: Store<AppState>, eventLogger: EventLoggerProtocol) {
        self.webRepository = webRepository
        self.dbRepository = dbRepository
        self.notificationService = notificationService
        self.appState = appState
        self.eventLogger = eventLogger
    }
    
    private func basketTokenAndStoreIdCheck() throws -> (String?, Int?) {
        let basketToken = appState.value.userData.basket?.basketToken
        let storeId = appState.value.userData.selectedStore.value?.id
        
        if basketToken == nil && storeId == nil { throw BasketServiceError.storeSelectionRequired }
        
        return (basketToken, storeId)
    }
    
    private func conditionallyGetBasket(basketToken: String?, storeId: Int?) async throws {
        // Need to internally set the basket if:
        // (a) selected fulfilment does not match the current basket fulfilment
        // and updateFulfilmentMethodAndStore is not already being called to rectify
        // (b) there is no current basket and this is not a getBasket or restoreBasket
        // action
        guard let storeId = storeId else { return }
        guard appState.value.userData.selectedFulfilmentMethod != appState.value.userData.basket?.fulfilmentMethod.type || storeId != appState.value.userData.basket?.storeId else { return }
        guard let fulfilmentLocation = appState.value.userData.searchResult.value?.fulfilmentLocation else { throw BasketServiceError.fulfilmentLocationRequired }
        
        let basket = try await webRepository.getBasket(basketToken: basketToken, storeId: storeId, fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod, fulfilmentLocation: fulfilmentLocation, isFirstOrder: true)
        
        let _ = try await storeBasketAndUpdateAppState(fetchedBasket: basket)
    }
    
    private func storeBasketAndUpdateAppState(fetchedBasket: Basket) async throws {
        let _ = try await dbRepository.clearBasket().singleOutput()
        
        let basket = try await dbRepository.store(basket: fetchedBasket).singleOutput()
        
        await MainActor.run { [weak self] in
            guard let self = self else { return }
            self.appState.value.userData.basket = basket
        }
    }
    
    func restoreBasket() async throws {
        let (basketToken, storeId) = try basketTokenAndStoreIdCheck()
        
        if let storeId = storeId {
            if let basketToken = basketToken {
                let basket = try await webRepository.getBasket(basketToken: basketToken, storeId: storeId, fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod, fulfilmentLocation: nil, isFirstOrder: true)
                
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    self.appState.value.userData.basket = basket
                }
            } else {
                try await restoreSavedBasket(storeId: storeId)
            }
        } else {
            throw BasketServiceError.storeSelectionRequired
        }
    }
    
    private func restoreSavedBasket(storeId: Int) async throws {
        let dbBasket = try await dbRepository.fetchBasket().singleOutput()
        if let basket = dbBasket {
            await MainActor.run { [weak self] in
                guard let self = self else { return }
                self.appState.value.userData.basket = basket
            }
            
            let webBasket = try await webRepository.getBasket(basketToken: basket.basketToken, storeId: storeId, fulfilmentMethod: basket.fulfilmentMethod.type, fulfilmentLocation: nil, isFirstOrder: true)
            
            try await storeBasketAndUpdateAppState(fetchedBasket: webBasket)
        }
    }
    
    func updateFulfilmentMethodAndStore() async throws {
        let (basketToken, storeId) = try basketTokenAndStoreIdCheck()
        guard let fulfilmentLocation = appState.value.userData.searchResult.value?.fulfilmentLocation else { throw BasketServiceError.fulfilmentLocationRequired }
        guard let storeId = storeId else { throw BasketServiceError.storeSelectionRequired }
        
        let basket = try await webRepository.getBasket(basketToken: basketToken, storeId: storeId, fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod, fulfilmentLocation: fulfilmentLocation, isFirstOrder: true)
        
        try await storeBasketAndUpdateAppState(fetchedBasket: basket)    }
    
    func reserveTimeSlot(timeSlotDate: String, timeSlotTime: String?) async throws {
        let (basketToken, storeId) = try basketTokenAndStoreIdCheck()
        try await conditionallyGetBasket(basketToken: basketToken, storeId: storeId)
        
        guard let storeId = storeId else { throw BasketServiceError.storeSelectionRequired }
        guard let basketToken = appState.value.userData.basket?.basketToken else { throw BasketServiceError.unableToProceedWithoutBasket }
        guard let postcode = appState.value.userData.selectedStore.value?.searchPostcode else { throw BasketServiceError.unableToProceedWithoutPostcode }

        let basket = try await webRepository.reserveTimeSlot(basketToken: basketToken, storeId: storeId, timeSlotDate: timeSlotDate, timeSlotTime: timeSlotTime, postcode: postcode, fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod)
            
        try await storeBasketAndUpdateAppState(fetchedBasket: basket)
    }
    
    func addItem(basketItemRequest: BasketItemRequest, item: RetailStoreMenuItem) async throws {
        let (basketToken, storeId) = try basketTokenAndStoreIdCheck()
        
        if let basketToken = basketToken {
            do {
                let basket = try await webRepository.addItem(basketToken: basketToken, item: basketItemRequest, fulfilmentMethod: .delivery)
                
                try await storeBasketAndUpdateAppState(fetchedBasket: basket)
                
                sendAddToBasketEvents(item: item, quantity: basketItemRequest.quantity ?? 1)
                
                notificationService.addItemToBasket(itemName: String(basketItemRequest.menuItemId), quantity: basketItemRequest.quantity ?? 1)
            } catch {
                throw error
            }
        } else {
            if let storeId = storeId {
                do {
                    try await conditionallyGetBasket(basketToken: basketToken, storeId: storeId)
                    
                    if let existingBasket = appState.value.userData.basket {
                        let basket = try await webRepository.addItem(basketToken: existingBasket.basketToken, item: basketItemRequest, fulfilmentMethod: .delivery)
                        
                        try await storeBasketAndUpdateAppState(fetchedBasket: basket)
                        
                        sendAddToBasketEvents(item: item, quantity: basketItemRequest.quantity ?? 1)
                        
                        notificationService.addItemToBasket(itemName: String(basketItemRequest.menuItemId), quantity: basketItemRequest.quantity ?? 1)
                    }
                } catch {
                    throw error
                }
            }
        }
    }
    
    private func sendAddToBasketEvents(item: RetailStoreMenuItem, quantity: Int) {
        
        let contentId = AppV2Constants.EventsLogging.analyticsItemIdPrefix + "\(item.id)"
        let currencyCode = appState.value.userData.selectedStore.value?.currency.currencyCode ?? AppV2Constants.Business.currencyCode
        
        let appsFlyerParams: [String: Any] = [
            AFEventParamPrice:          item.price.price,
            AFEventParamContent:        item.eposCode ?? "",
            AFEventParamContentId:      item.id,
            AFEventParamContentType:    item.mainCategory.name,
            AFEventParamCurrency:       currencyCode,
            AFEventParamQuantity:       quantity,
            "product_name":             item.name
        ]
        
        eventLogger.sendEvent(for: .addToBasket, with: .appsFlyer, params: appsFlyerParams)
        
        let facebookParams: [AppEvents.ParameterName: Any] = [
            .description: item.name,
            .contentID: contentId,
            .contentType: "product",
            .numItems: quantity,
            .currency: currencyCode
        ]

        eventLogger.sendEvent(for: .addToBasket, with: .facebook, params: [
            "valueToSum": item.price.price,
            "facebookParams": facebookParams
        ])
        
        let addedItem: [String: Any] = [
            AnalyticsParameterItemID: contentId,
            AnalyticsParameterQuantity: quantity,
            AnalyticsParameterPrice: NSDecimalNumber(value: item.price.price).rounding(accordingToBehavior: EventLogger.decimalBehavior).doubleValue
        ]

        let firebaseParams: [String: Any] = [
            AnalyticsParameterCurrency: currencyCode,
            AnalyticsParameterItems: [addedItem],
            AnalyticsParameterValue: NSDecimalNumber(value: item.price.price * Double(quantity)).rounding(accordingToBehavior: EventLogger.decimalBehavior).doubleValue
        ]

        eventLogger.sendEvent(for: .addToBasket, with: .firebaseAnalytics, params: firebaseParams)
    }
    
    func updateItem(basketItemRequest: BasketItemRequest, basketItem: BasketItem) async throws {
        let (basketToken, storeId) = try basketTokenAndStoreIdCheck()
        try await conditionallyGetBasket(basketToken: basketToken, storeId: storeId)
        
        if let basketToken = appState.value.userData.basket?.basketToken {
            let basket = try await webRepository.updateItem(basketToken: basketToken, basketLineId: basketItem.basketLineId, item: basketItemRequest)
            
            try await storeBasketAndUpdateAppState(fetchedBasket: basket)
            
            if let quantity = basketItemRequest.quantity {
                sendRemoveFromOrUpdateCartEvents(
                    removeFromCart: false,
                    item: basketItem.menuItem,
                    quantity: quantity,
                    previousQuantity: basketItem.quantity
                )
            }
        } else {
            throw BasketServiceError.unableToProceedWithoutBasket
        }
        
    }
    
    func changeItemQuantity(basketItem: BasketItem, changeQuantity: Int) async throws {
        let (basketToken, storeId) = try basketTokenAndStoreIdCheck()
        try await conditionallyGetBasket(basketToken: basketToken, storeId: storeId)
        
        if let basketToken = appState.value.userData.basket?.basketToken {
            let basket = try await webRepository.changeItemQuantity(basketToken: basketToken, basketLineId: basketItem.basketLineId, changeQuantity: changeQuantity)
            
            try await storeBasketAndUpdateAppState(fetchedBasket: basket)
            
            sendRemoveFromOrUpdateCartEvents(removeFromCart: false, item: basketItem.menuItem, quantity: changeQuantity, previousQuantity: basketItem.quantity)
        } else {
            throw BasketServiceError.unableToProceedWithoutBasket
        }
    }
    
    func removeItem(basketLineId: Int, item: RetailStoreMenuItem) async throws {
        let (basketToken, storeId) = try basketTokenAndStoreIdCheck()
        try await conditionallyGetBasket(basketToken: basketToken, storeId: storeId)
        
        if let currentBasket = appState.value.userData.basket {
            
            var previousQuantity = 0
            for item in currentBasket.items where item.basketLineId == basketLineId {
                previousQuantity = item.quantity
                break
            }
            
            let basket = try await webRepository.removeItem(basketToken: currentBasket.basketToken, basketLineId: basketLineId)
            
            try await storeBasketAndUpdateAppState(fetchedBasket: basket)
            
            sendRemoveFromOrUpdateCartEvents(removeFromCart: true, item: item, previousQuantity: previousQuantity)
        } else {
            throw BasketServiceError.unableToProceedWithoutBasket
        }
    }
    
    // Observed behaviour:
    // - when removeFromCart is true then quantity = 0
    // - otherwise quanity is negative when reducing the quantity but leaving a basket line
    func sendRemoveFromOrUpdateCartEvents(removeFromCart: Bool, item: RetailStoreMenuItem, quantity: Int = 0, previousQuantity: Int = 0) {
        
        let contentId = AppV2Constants.EventsLogging.analyticsItemIdPrefix + "\(item.id)"
        let currencyCode = appState.value.userData.selectedStore.value?.currency.currencyCode ?? AppV2Constants.Business.currencyCode
        
        var params: [String: Any] = [
            AFEventParamPrice:          removeFromCart ? 0.0 : item.price.price,
            AFEventParamContentId:      item.id,
            AFEventParamContentType:    item.mainCategory.name,
            AFEventParamCurrency:       currencyCode,
            AFEventParamQuantity:       quantity,
            "product_name":             item.name
        ]
        if let eposCode = item.eposCode {
            params[AFEventParamContent] = eposCode
        }
        eventLogger.sendEvent(for: removeFromCart ? .removeFromBasket : .updateCart, with: .appsFlyer, params: params)
        
        let quantityChange: Int
        if removeFromCart && quantity == 0 {
            quantityChange = -previousQuantity
        } else {
            quantityChange = quantity
        }
        
        let facebookParams: [AppEvents.ParameterName: Any] = [
            .description: item.name,
            .contentID: contentId,
            .contentType: "product",
            .numItems: quantityChange,
            .currency: appState.value.userData.selectedStore.value?.currency.currencyCode ?? AppV2Constants.Business.currencyCode
        ]

        eventLogger.sendEvent(for: removeFromCart ? .removeFromBasket : .updateCart, with: .facebook, params: [
            "valueToSum": quantityChange > 0 ? item.price.price : -item.price.price,
            "facebookParams": facebookParams
        ])
        
        // no update for event for Firebase
        if quantityChange != 0 {
            
            // use an absolute value for quantity because even the remove event expects a non negative value
            
            let itemParams: [String: Any] = [
                AnalyticsParameterItemID: contentId,
                AnalyticsParameterQuantity: abs(quantityChange),
                AnalyticsParameterPrice: NSDecimalNumber(value: item.price.price).rounding(accordingToBehavior: EventLogger.decimalBehavior).doubleValue
            ]

            let firebaseParams: [String: Any] = [
                AnalyticsParameterCurrency: currencyCode,
                AnalyticsParameterItems: [itemParams],
                AnalyticsParameterValue: NSDecimalNumber(value: item.price.price * Double(abs(quantityChange))).rounding(accordingToBehavior: EventLogger.decimalBehavior).doubleValue
            ]

            eventLogger.sendEvent(for: quantityChange > 0 ? .addToBasket : .removeFromBasket, with: .firebaseAnalytics, params: firebaseParams)
        }
    }
    
    func applyCoupon(code: String) async throws {
        let (basketToken, storeId) = try basketTokenAndStoreIdCheck()
        try await conditionallyGetBasket(basketToken: basketToken, storeId: storeId)

        if let basketToken = appState.value.userData.basket?.basketToken {
            let basket = try await webRepoApplyCoupon(basketToken: basketToken, code: code)
            
            try await storeBasketAndUpdateAppState(fetchedBasket: basket)
            
            sendAppsFlyerApplyCouponEvent(basket: basket)
        } else {
            throw BasketServiceError.unableToProceedWithoutBasket
        }
    }
    
    private func webRepoApplyCoupon(basketToken: String, code: String) async throws -> Basket {
        do {
            return try await webRepository.applyCoupon(basketToken: basketToken, code: code)
        } catch {
            sendAppsFlyerCouponRejectEvent(code: code, error: error)
            throw error
        }
    }
    
    private func sendAppsFlyerCouponRejectEvent(code: String, error: Error) {
        var params: [String: Any] = [
            "coupon_code":code
        ]
        if let error = error as? APIErrorResult {
            params["reject_message"] = error.errorText
        }
        if let uuid = appState.value.userData.memberProfile?.uuid {
            params["member_id"] = uuid
        }
        eventLogger.sendEvent(for: .couponReject, with: .appsFlyer, params: params)
    }
    
    private func sendAppsFlyerApplyCouponEvent(basket: Basket) {
        if let coupon = basket.coupon {
            var params: [String: Any] = [
                "coupon_code": coupon.code,
                "coupon_name":coupon.name,
                "coupon_discount_applied": coupon.deductCost,
                "coupon_type": coupon.type,
                "coupon_value": coupon.value,
                "coupon_free_delivery": coupon.freeDelivery
            ]
            
            if let campaignId = coupon.iterableCampaignId {
                params["campaign_id"] = campaignId
            }
            
            eventLogger.sendEvent(for: .applyCoupon, with: .appsFlyer, params: params)
        }
    }
    
    func removeCoupon() async throws {
        let (basketToken, storeId) = try basketTokenAndStoreIdCheck()
        try await conditionallyGetBasket(basketToken: basketToken, storeId: storeId)
        
        if let basketToken = appState.value.userData.basket?.basketToken {
            let basket = try await webRepository.removeCoupon(basketToken: basketToken)
            
            try await storeBasketAndUpdateAppState(fetchedBasket: basket)
        } else {
            throw BasketServiceError.unableToProceedWithoutBasket
        }
    }
    
    func clearItems() async throws {
        let (basketToken, storeId) = try basketTokenAndStoreIdCheck()
        try await conditionallyGetBasket(basketToken: basketToken, storeId: storeId)
        
        if let basketToken = appState.value.userData.basket?.basketToken {
            let basket = try await webRepository.clearItems(basketToken: basketToken)
            
            try await storeBasketAndUpdateAppState(fetchedBasket: basket)
        } else {
            throw BasketServiceError.unableToProceedWithoutBasket
        }
    }
    
    func setContactDetails(to: BasketContactDetailsRequest) async throws {
        let (basketToken, storeId) = try basketTokenAndStoreIdCheck()
        try await conditionallyGetBasket(basketToken: basketToken, storeId: storeId)
        
        if let basketToken = appState.value.userData.basket?.basketToken {
            let basket = try await webRepository.setContactDetails(basketToken: basketToken, details: to)
            
            try await storeBasketAndUpdateAppState(fetchedBasket: basket)
            
            // invalidate the cached results
            guaranteeMainThread {
                self.appState.value.staticCacheData.mentionMeRefereeResult = nil
            }
        } else {
            throw BasketServiceError.unableToProceedWithoutBasket
        }
    }
    
    func setDeliveryAddress(to: BasketAddressRequest) async throws {
        let (basketToken, storeId) = try basketTokenAndStoreIdCheck()
        try await conditionallyGetBasket(basketToken: basketToken, storeId: storeId)
        
        if let basketToken = appState.value.userData.basket?.basketToken {
            do {
                let basket = try await webRepository.setDeliveryAddress(basketToken: basketToken, address: to)
                try await storeBasketAndUpdateAppState(fetchedBasket: basket)
            } catch {
                #warning("400 seems too generic - backend team might change the error code")
                if
                    let error = error as? APIErrorResult,
                    error.errorCode == 400
                {
                    eventLogger.sendEvent(for: .cannotDeliverToAddress, with: .firebaseAnalytics, params: [:])
                }
                throw error
            }
        } else {
            throw BasketServiceError.unableToProceedWithoutBasket
        }
    }
    
    func setBillingAddress(to: BasketAddressRequest) async throws {
        let (basketToken, storeId) = try basketTokenAndStoreIdCheck()
        try await conditionallyGetBasket(basketToken: basketToken, storeId: storeId)
        
        if let basketToken = appState.value.userData.basket?.basketToken {
            let basket = try await webRepository.setBillingAddress(basketToken: basketToken, address: to)
            
            try await storeBasketAndUpdateAppState(fetchedBasket: basket)
            
            eventLogger.sendEvent(for: .addBillingInfo, with: .appsFlyer, params: [:])
            // invalidate the cached results
            guaranteeMainThread {
                self.appState.value.staticCacheData.mentionMeRefereeResult = nil
            }
        } else {
            throw BasketServiceError.unableToProceedWithoutBasket
        }
    }
    
    func updateTip(to: Double) async throws {
        let (basketToken, storeId) = try basketTokenAndStoreIdCheck()
        try await conditionallyGetBasket(basketToken: basketToken, storeId: storeId)
        
        if let basketToken = appState.value.userData.basket?.basketToken {
            let basket = try await webRepository.updateTip(basketToken: basketToken, tip: to)
            
            try await storeBasketAndUpdateAppState(fetchedBasket: basket)
        } else {
            throw BasketServiceError.unableToProceedWithoutBasket
        }
    }
    
    func populateRepeatOrder(businessOrderId: Int) async throws {
        let (basketToken, storeId) = try basketTokenAndStoreIdCheck()
        try await conditionallyGetBasket(basketToken: basketToken, storeId: storeId)
        
        if appState.value.userData.memberProfile == nil { throw BasketServiceError.memberRequiredToBeSignedIn }
        
        if let basketToken = appState.value.userData.basket?.basketToken {
            let basket = try await webRepository.populateRepeatOrder(basketToken: basketToken, businessOrderId: businessOrderId, fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod)
            
            try await storeBasketAndUpdateAppState(fetchedBasket: basket)
        } else {
            throw BasketServiceError.unableToProceedWithoutBasket
        }
    }
    
    func getNewBasket() async throws {
        guard let fulfilmentLocation = appState.value.userData.searchResult.value?.fulfilmentLocation else { throw BasketServiceError.fulfilmentLocationRequired }
        guard let storeId = appState.value.userData.selectedStore.value?.id else { throw BasketServiceError.storeSelectionRequired }
        
        let basket = try await webRepository.getBasket(basketToken: nil, storeId: storeId, fulfilmentMethod: appState.value.userData.selectedFulfilmentMethod, fulfilmentLocation: fulfilmentLocation, isFirstOrder: true)
        
        try await storeBasketAndUpdateAppState(fetchedBasket: basket)
    }
    
    func test(delay: TimeInterval) async {
        //
    }
}

struct StubBasketService: BasketServiceProtocol {

    func restoreBasket() async throws { }

    func updateFulfilmentMethodAndStore() async throws {}
    
    func reserveTimeSlot(timeSlotDate: String, timeSlotTime: String?) async throws {}
    
    func addItem(basketItemRequest: BasketItemRequest, item: RetailStoreMenuItem) async throws {}
    
    func updateItem(basketItemRequest: BasketItemRequest, basketItem: BasketItem) async throws {}
    
    func changeItemQuantity(basketItem: BasketItem, changeQuantity: Int) async throws {}
    
    func removeItem(basketLineId: Int, item: RetailStoreMenuItem) async throws {}
    
    func applyCoupon(code: String) async throws {}
    
    func removeCoupon() async throws {}
    
    func clearItems() async throws {}
    
    func setContactDetails(to: BasketContactDetailsRequest) async throws {}
    
    func setDeliveryAddress(to: BasketAddressRequest) async throws {}
    
    func setBillingAddress(to: BasketAddressRequest) async throws {}
    
    func updateTip(to: Double) async throws {}
    
    func populateRepeatOrder(businessOrderId: Int) async throws {}
    
    func getNewBasket() async throws {}
    
    func test(delay: TimeInterval) {}
}
