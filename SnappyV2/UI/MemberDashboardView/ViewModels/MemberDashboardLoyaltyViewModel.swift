//
//  LoyaltyViewModel.swift
//  SnappyV2
//
//  Created by David Bage on 20/03/2022.
//

import Foundation
import UIKit

@MainActor
class MemberDashboardLoyaltyViewModel: ObservableObject {
    
    let container: DIContainer
    let profile: MemberProfile?
    
    @Published var mentionMeButtonText: String?
    @Published var showMentionMeLoading = false
    @Published var showMentionMeWebView = false
    @Published var mentionMeDashboardRequestResult = MentionMeRequestResult(success: false, type: .dashboard, webViewURL: nil, buttonText: nil, postMessageConstants: nil, applyCoupon: nil, openInBrowser: nil)
    @Published var webViewURL: URL?
    
    var referralBalance: String {
        guard let profile = profile else { return "0" }

        // Not using store currency because a store might not be selected and this concept
        // is independent from any selected store.
        return profile.referFriendBalance.toCurrencyString(using: AppV2Constants.Business.defaultStoreCurrency)
    }
    
    init(container: DIContainer, profile: MemberProfile?) {
        self.container = container
        self.profile = profile
        
        setupMentionMe(with: container.appState)
    }
    
    func showMentionMeDashboard() {
        if
            let dashboardResult = container.appState.value.staticCacheData.mentionMeDashboardResult,
            let webViewURL = dashboardResult.webViewURL,
            dashboardResult.success
        {
            container.eventLogger.sendEvent(for: .mentionMeDashboardView, with: .appsFlyer, params: [:])
            container.eventLogger.sendEvent(for: .mentionMeDashboardView, with: .firebaseAnalytics, params: [:])
            if dashboardResult.openInBrowser ?? false {
                self.webViewURL = webViewURL
            } else {
                mentionMeDashboardRequestResult = dashboardResult
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
            if let cachedDashboardResult = appState.value.staticCacheData.mentionMeDashboardResult {
                self.updateMentionMeUI(with: cachedDashboardResult)
            } else {
                self.mentionMeButtonText = nil
                self.showMentionMeLoading = true
                // attempt to fetch the result
                Task { [weak self] in
                    guard let self = self else { return }
                    do {
                        self.updateMentionMeUI(
                            with: try await MentionMeHandler(container: self.container).perform(request: .dashboard)
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
//        guaranteeMainThread { [weak self] in
//            guard let self = self else { return }
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
//        }
    }
}
