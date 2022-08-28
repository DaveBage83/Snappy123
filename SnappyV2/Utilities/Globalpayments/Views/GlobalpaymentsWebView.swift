//
//  GlobalpaymentsWebView.swift
//  SnappyV2
//
//  Created by Kevin Palser on 15/02/2022.
//

import WebKit
import SwiftUI

struct GlobalpaymentsWebView: UIViewRepresentable {
    typealias UIViewType = WKWebView

    @ObservedObject var viewModel: GlobalpaymentsHPPViewModel
    
    func makeUIView(context: Context) -> WKWebView {
        let viewScriptString = "var meta = document.createElement('meta');" +
            "meta.name = 'viewport';" +
            "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
            "var head = document.getElementsByTagName('head')[0];" +
            "head.appendChild(meta);"
        
        let viewScript = WKUserScript(source: viewScriptString,
                                      injectionTime: .atDocumentEnd,
                                      forMainFrameOnly: true)
        
        let userContentController = WKUserContentController()
        userContentController.addUserScript(viewScript)
        userContentController.add(viewModel, name: "callbackHandler")
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        webView.backgroundColor = .white
        webView.navigationDelegate = viewModel
        
        viewModel.loadHTMLString = { htmlString, baseURL in
            webView.loadHTMLString(htmlString, baseURL: baseURL)
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) { }
}
