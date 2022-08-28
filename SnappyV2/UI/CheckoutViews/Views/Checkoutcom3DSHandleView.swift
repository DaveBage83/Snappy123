//
//  Checkoutcom3DSHandleView.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 08/08/2022.
//

import SwiftUI
import Frames

struct Checkoutcom3DSHandleView: UIViewControllerRepresentable {
    typealias UIViewControllerType = ThreedsWebViewController
    
    init(urls: CheckoutCom3DSURLs, delegate: ThreedsWebViewControllerDelegate) {
        self.delegate = delegate
        self.redirectURL = urls.redirectUrl
        self.successURL = urls.successUrl
        self.failURL = urls.failUrl
    }
    
    private let delegate: ThreedsWebViewControllerDelegate
    private let redirectURL: URL
    private let successURL: URL
    private let failURL: URL
    
    func makeUIViewController(context: Context) -> ThreedsWebViewController {
        let threeDSWebViewController = ThreedsWebViewController(successUrl: successURL, failUrl: failURL)
        threeDSWebViewController.authUrl = redirectURL
        threeDSWebViewController.delegate = delegate
        return threeDSWebViewController
    }
    
    func updateUIViewController(_ uiViewController: ThreedsWebViewController, context: Context) {}
}

extension Checkoutcom3DSHandleView {
    class Delegate: NSObject, ThreedsWebViewControllerDelegate {
        init(didSucceed: @escaping () -> (), didFail: @escaping () -> ()) {
            self.didSucceed = didSucceed
            self.didFail = didFail
        }
        
        private let didSucceed: () -> ()
        private let didFail: () -> ()
        
        func threeDSWebViewControllerAuthenticationDidSucceed(_ threeDSWebViewController: ThreedsWebViewController, token: String?) {
            didSucceed()
        }
        
        func threeDSWebViewControllerAuthenticationDidFail(_ threeDSWebViewController: ThreedsWebViewController) {
            didFail()
        }
    }
}
