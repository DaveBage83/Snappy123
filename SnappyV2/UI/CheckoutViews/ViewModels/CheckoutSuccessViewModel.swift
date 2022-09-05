//
//  CheckoutSuccessViewModel.swift
//  SnappyV2
//
//  Created by Kevin Palser on 01/07/2022.
//

import Foundation
import Combine
import UIKit
import OSLog

class CheckoutSuccessViewModel: ObservableObject {
    let container: DIContainer
    
    @Published var mentionMeButtonText: String?
    @Published var showMentionMeLoading = false
    @Published var showMentionMeWebView = false
    @Published var mentionMeOfferRequestResult = MentionMeRequestResult(success: false, type: .offer, webViewURL: nil, buttonText: nil, postMessageConstants: nil, applyCoupon: nil, openInBrowser: nil)
    @Published var webViewURL: URL?
    @Published var triggerBottomSheet: TriggerMentionMe?
    
    var storeNumber: String? {
        container.appState.value.userData.selectedStore.value?.telephone.telephoneNumber
    }
    
    var showCallStoreButton: Bool {
        storeNumber != nil && storeNumber?.isEmpty == false
    }
    
    var basket: Basket?
        
    init(container: DIContainer) {
        self.container = container
        self.basket = container.appState.value.userData.successCheckoutBasket
        setupMentionMe(with: container.appState)
    }
    
    func showMentionMeOffer() {
        if
            let offerResult = container.appState.value.staticCacheData.mentionMeOfferResult,
            let webViewURL = offerResult.webViewURL,
            offerResult.success
        {
            container.eventLogger.sendEvent(for: .mentionMeOfferView, with: .appsFlyer, params: [:])
            container.eventLogger.sendEvent(for: .mentionMeOfferView, with: .firebaseAnalytics, params: [:])
            if offerResult.openInBrowser ?? false {
                self.webViewURL = webViewURL
            } else {
                mentionMeOfferRequestResult = offerResult
                showMentionMeWebView = true
            }
        }
    }
    
    func mentionMeWebViewDismissed() {
        guaranteeMainThread { [weak self] in
            guard let self = self else { return }
            self.showMentionMeWebView = false
        }
    }
    
    private func setupMentionMe(with appState: Store<AppState>) {
        if appState.value.businessData.businessProfile?.mentionMeEnabled ?? false {
            if let cachedOfferResult = appState.value.staticCacheData.mentionMeOfferResult {
                self.updateMentionMeUI(with: cachedOfferResult)
            } else {
                self.mentionMeButtonText = nil
                self.showMentionMeLoading = true
                // attempt to fetch the result
                Task { [weak self] in
                    guard let self = self else { return }
                    do {
                        self.updateMentionMeUI(
                            with: try await MentionMeHandler(container: self.container).perform(
                                request: .offer,
                                businessOrderId: self.container.services.checkoutService.lastBusinessOrderIdInCurrentSession()
                            )
                        )
                    } catch {
                        // the error will have been logged by the perform method so
                        // only need to hide the progress view
                        guaranteeMainThread {
                            self.showMentionMeLoading = false
                        }
                    }
                }
            }
        }
    }
    
    private func updateMentionMeUI(with refereeResult: MentionMeRequestResult) {
        guaranteeMainThread { [weak self] in
            guard let self = self else { return }
            if
                let buttonText = refereeResult.buttonText,
                refereeResult.success,
                refereeResult.webViewURL != nil
            {
                self.mentionMeButtonText = buttonText
            } else {
                self.mentionMeButtonText = nil
            }
            self.showMentionMeLoading = false
            self.triggerBottomSheet = .init()
        }
    }
    
    func clearSuccessCheckoutBasket() {
        container.appState.value.userData.successCheckoutBasket = nil
    }
    
    func callStoreTapped() {
        let storeNumber = container.appState.value.userData.selectedStore.value?.telephone
        
        if let storeNumber = storeNumber {
            guard let url = URL(string: storeNumber.telephoneNumber) else { return }
            UIApplication.shared.open(url)
        } else {
            // We only show the call store button if a number is present, so no need to handle the error with a message here
            Logger.checkout.error("No store number present")
        }
    }
}

#warning("This object used as a hack to trigger the bottom sheet container mention me button. BottomSheet currently requires and Equatable and Identifiable object to trigger. Need to refactor bottom sheet modifier to take a binding Boolean as well")
struct TriggerMentionMe: Identifiable, Equatable {
    let id = UUID()
}
