//
//  MentionMeRepresentableWebView.swift
//  SnappyV2
//
//  Created by Kevin Palser on 20/06/2022.
//

import Foundation
import SwiftUI
import UIKit
import WebKit

struct MentionMeRepresentableWebView: UIViewRepresentable {
    
    @StateObject var viewModel: MentionMeRepresentableWebViewModel
    @Binding var showLoading: Bool
    
    func makeUIView(context: Context) -> some UIView {
        let coordinator = context.coordinator
        let webView = WKWebView(frame: .zero, configuration: viewModel.createWebViewConfiguration(for: coordinator))
        webView.navigationDelegate = coordinator
        if let htmlString = viewModel.createHTMLString() {
            webView.loadHTMLString(htmlString, baseURL: nil)
        }
        return webView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    func makeCoordinator() -> MentionMeRepresentableWebViewCoordinator {
        
        MentionMeRepresentableWebViewCoordinator(
            didStart: {
                showLoading = true
            },
            didFinish: {
                showLoading = false
            },
            didFail: { error in
                showLoading = false
            },
            decidePolicy: { navigationAction in
                viewModel.decideActionNavigationActionPolicy(navigationAction: navigationAction)
            },
            didReceiveScriptMessage: { scriptMessage in
                viewModel.processScriptMessage(message: scriptMessage)
            }
        )

    }
    
}

class MentionMeRepresentableWebViewCoordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
    
    private let didStart: (() -> Void)?
    private let didFinish: (() -> Void)?
    private let didFail: ((Error) -> Void)?
    private let decidePolicy: ((WKNavigationAction) -> WKNavigationActionPolicy)?
    private let didReceiveScriptMessage: ((WKScriptMessage) -> Void)?
    
    init(
        didStart: (() -> Void)?,
        didFinish: (() -> Void)?,
        didFail: ((Error) -> Void)?,
        decidePolicy: ((WKNavigationAction) -> WKNavigationActionPolicy)?,
        didReceiveScriptMessage: ((WKScriptMessage) -> Void)?
    ) {
        self.didStart = didStart
        self.didFinish = didFinish
        self.didFail = didFail
        self.decidePolicy = decidePolicy
        self.didReceiveScriptMessage = didReceiveScriptMessage
    }
    
    // MARK: - WKNavigationDelegate methods
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        didStart?()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        didFinish?()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        didFail?(error)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let decidePolicy = decidePolicy {
            decisionHandler(decidePolicy(navigationAction))
            return
        }
        decisionHandler(.allow)
    }
    
    // MARK: - WKScriptMessageHandler method
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        didReceiveScriptMessage?(message)
    }
    
}
