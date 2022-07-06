//
//  CheckoutSuccessViewModel.swift
//  SnappyV2
//
//  Created by Kevin Palser on 01/07/2022.
//

import Combine
import UIKit

class CheckoutSuccessViewModel: ObservableObject {
    let container: DIContainer
    
    @Published var mentionMeButtonText: String?
    @Published var showMentionMeLoading = false
    @Published var showMentionMeWebView = false
    @Published var mentionMeOfferRequestResult = MentionMeRequestResult(success: false, type: .offer, webViewURL: nil, buttonText: nil, postMessageConstants: nil, applyCoupon: nil, openInBrowser: nil)
    
    init(container: DIContainer) {
        self.container = container
        
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
                UIApplication.shared.open(webViewURL, options: [:], completionHandler: nil)
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
        }
    }
}
