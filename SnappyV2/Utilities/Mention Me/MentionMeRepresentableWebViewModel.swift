//
//  MentionMeRepresentableWebViewModel.swift
//  SnappyV2
//
//  Created by Kevin Palser on 20/06/2022.
//

import Foundation
import WebKit

typealias MentionMeCouponAction = (couponCode: String, apply: Bool)

@MainActor
class MentionMeRepresentableWebViewModel: ObservableObject {

    private let container: DIContainer
    private let mentionMeResult: MentionMeRequestResult
    private let setCouponActionHandler: (MentionMeCouponAction?) -> Void
    private let dismissWebViewHandler: () -> Void
    
    init(container: DIContainer, mentionMeResult: MentionMeRequestResult, setCouponActionHandler: @escaping (MentionMeCouponAction?) -> Void, dismissWebViewHandler: @escaping () -> Void) {
        self.container = container
        self.mentionMeResult = mentionMeResult
        self.setCouponActionHandler = setCouponActionHandler
        self.dismissWebViewHandler = dismissWebViewHandler
    }
    
    func createWebViewConfiguration(for messageHandler: WKScriptMessageHandler) -> WKWebViewConfiguration {
        let viewScriptString = "var meta = document.createElement('meta');" +
            "meta.name = 'viewport';" +
            "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
            "var head = document.getElementsByTagName('head')[0];" +
            "head.appendChild(meta);"

        let viewScript = WKUserScript(
            source: viewScriptString,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        
        let userContentController = WKUserContentController()
        userContentController.addUserScript(viewScript)
        
        if mentionMeResult.postMessageConstants != nil {
            userContentController.add(messageHandler, name: "mentionMeCallbackHandler")
        }
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        
        return configuration
    }
    
    func createHTMLString() -> String? {
        if
            let requestURL = mentionMeResult.webViewURL,
            let path = Bundle.main.path(forResource: "mentionme", ofType: "html")
        {
            do {
                let htmlTemplateString = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
                let htmlString = htmlTemplateString.replacingOccurrences(of: "####", with: requestURL.absoluteString, options: NSString.CompareOptions.literal, range: nil)
                return htmlString
            } catch let error {
                let mentionMeErrorParams: [String: Any] = [
                    "type": mentionMeResult.type,
                    "error": error.localizedDescription
                ]
                container.eventLogger.sendEvent(for: .mentionMeError, with: .appsFlyer, params: mentionMeErrorParams)
                container.eventLogger.sendEvent(for: .mentionMeError, with: .firebaseAnalytics, params: mentionMeErrorParams)
                close()
            }
        }
        return nil
    }
    
    func decideActionNavigationActionPolicy(navigationAction: WKNavigationAction) -> WKNavigationActionPolicy {
        guard let url = navigationAction.request.url else {
            return .cancel
        }
        let string = url.absoluteString
        if string.contains("mailto:") || string.contains("whatsapp:") || string.contains("fb-messenger:") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return .cancel
        }
        return .allow
    }
    
    func processScriptMessage(message: WKScriptMessage) {
        guard let postMessageConstants = mentionMeResult.postMessageConstants else { return }

        if let resultDictionary = message.body as? [String: Any] {
            if let actionValue = resultDictionary[postMessageConstants.actionFieldName] as? String {
                let action = actionValue.lowercased()

                if
                    let refereeFulfilledAction = postMessageConstants.refereeFulfilledAction,
                    refereeFulfilledAction == action
                {
                    if
                        let couponFieldName = postMessageConstants.couponFieldName,
                        let couponCodeFieldName = postMessageConstants.couponCodeFieldName,
                        let coupon = resultDictionary[couponFieldName] as? [String: Any],
                        let couponCode = coupon[couponCodeFieldName] as? String
                    {
                        setCouponActionHandler(
                            MentionMeCouponAction(
                                couponCode: couponCode,
                                apply: mentionMeResult.applyCoupon ?? false
                            )
                        )
                    }
                }

                if postMessageConstants.closeActions.contains(action) {
                    close()
                }
            }

            if
                let clickTypeFieldName = postMessageConstants.clickTypeFieldName,
                let clickTypeCloseValues = postMessageConstants.clickTypeCloseValues,
                let clickTypeValue = resultDictionary[clickTypeFieldName] as? String
            {
                let clickType = clickTypeValue.lowercased()
                if clickTypeCloseValues.contains(clickType) {
                    close()
                }
            }
        }
    }
    
    private func close() {
        guaranteeMainThread { [weak self] in
            guard let self = self else { return }
            self.dismissWebViewHandler()
        }
    }

}
