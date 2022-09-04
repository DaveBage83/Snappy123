//
//  CheckoutSuccessViewModel.swift
//  SnappyV2
//
//  Created by Kevin Palser on 01/07/2022.
//

import Foundation
import Combine
import SwiftUI

class CheckoutSuccessViewModel: ObservableObject {
    let container: DIContainer
    
    @Published var mentionMeButtonText: String?
    @Published var showMentionMeLoading = false
    @Published var showMentionMeWebView = false
    @Published var mentionMeOfferRequestResult = MentionMeRequestResult(success: false, type: .offer, webViewURL: nil, buttonText: nil, postMessageConstants: nil, applyCoupon: nil, openInBrowser: nil)
    @Published var webViewURL: URL?
    @Published var appStoreReviewScene: UIWindowScene?
    
    let lastAskedReviewVersionUserDefaultsKey = "lastAskedReviewVersion"
    let currentOrderCountUserDefaultsKey = "currentOrderCount"
    
    init(container: DIContainer) {
        self.container = container
        
        setupMentionMe(with: container.appState)
        checkAppStoreReview()
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
    
    func checkAppStoreReview() {
        if
            let minOrdersForAppReview = container.appState.value.businessData.businessProfile?.minOrdersForAppReview,
            let currentVersion = AppV2Constants.Client.appVersion
        {
            let userDefault = UserDefaults.standard
            let lastAskedReviewVersion = userDefault.string(forKey: lastAskedReviewVersionUserDefaultsKey)
            var currentOrderCount = userDefault.integer(forKey: currentOrderCountUserDefaultsKey)

            currentOrderCount += 1

            // avoid trying to ask them if they are still on the same version - typically Apple will not let
            // the review prompt show if already asked
            if currentOrderCount >= minOrdersForAppReview && (lastAskedReviewVersion == nil || currentVersion != lastAskedReviewVersion) {

                // try getting current scene
                if let currentScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    // Show review dialog - this will not neccessarily show the App Store review prompt
                    // as Apple has additional logic to prevent users being spammed with prompts. Apple
                    // also does not allow developers to determine whether the prompt was shown or ratings
                    // left because they do not want developers to have different behaviour towards
                    // user leaving or not leaving reviews
                    appStoreReviewScene = currentScene

                    userDefault.set(currentVersion, forKey: lastAskedReviewVersionUserDefaultsKey)
                    currentOrderCount = 0
                }

            }

            userDefault.set(currentOrderCount, forKey: currentOrderCountUserDefaultsKey)
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
