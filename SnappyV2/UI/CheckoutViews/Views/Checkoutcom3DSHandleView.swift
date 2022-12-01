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
    
    private let container: DIContainer
    private let paymentEvironment: PaymentGatewayMode
    private let delegate: ThreedsWebViewControllerDelegate
    private let redirectURL: URL
    private let successURL: URL
    private let failURL: URL
    
    init(container: DIContainer, urls: CheckoutCom3DSURLs, delegate: ThreedsWebViewControllerDelegate) {
        self.container = container
        self.delegate = delegate
        self.redirectURL = urls.redirectUrl
        self.successURL = urls.successUrl
        self.failURL = urls.failUrl
        
        if let paymentGateway = self.container.appState.value.userData.selectedStore.value?.paymentGateways?.first(where: { $0.name ==  "checkoutcom"}) {
            self.paymentEvironment = paymentGateway.mode
        } else if let  paymentGateway = self.container.appState.value.businessData.businessProfile?.paymentGateways.first(where: { $0.name ==  "checkoutcom"}) {
            self.paymentEvironment = paymentGateway.mode
        } else {
            self.paymentEvironment = .sandbox
        }
    }
    
    func makeUIViewController(context: Context) -> ThreedsWebViewController {
        let threeDSWebViewController = ThreedsWebViewController(environment: paymentEvironment == .live ? .live : .sandbox, successUrl: successURL, failUrl: failURL)
        threeDSWebViewController.authURL = redirectURL
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
