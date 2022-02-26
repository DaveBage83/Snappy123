//
//  GlobalpaymentsWebViewModel.swift
//  SnappyV2
//
//  Created by Kevin Palser on 15/02/2022.
//

import WebKit
import Combine

enum GlobalpaymentsHPPViewInternalError: Swift.Error {
    case selfError
    case unexpectedAPIResult
    case unexpectedGlobalpaymentsAPIResult
}

enum GlobalpaymentsHPPServiceError: Swift.Error {
    case paymentFailed(String?)
}

public class GlobalpaymentsHPPViewModel: NSObject, ObservableObject {
    
    let container: DIContainer
    let fulfilmentDetails: DraftOrderFulfilmentDetailsRequest
    let instructions: String?
    
    @Published var viewDismissed: Bool = false
    @Published var isLoading: Bool = true
    
    private var realexHppManager: HPPManager?
    
    private var cancellables = Set<AnyCancellable>()
    
    var loadHTMLString: ((String, URL?) -> Void)?
    
    private let result: (Int?, Error?) -> ()
    
    private var businessOrderReceived = false
    
    init(
        container: DIContainer,
        fulfilmentDetails: DraftOrderFulfilmentDetailsRequest,
        instructions: String?,
        result: @escaping (Int?, Error?) -> ()
    ) {
        self.container = container
        self.fulfilmentDetails = fulfilmentDetails
        self.instructions = instructions
        self.result = result
        
        super.init()
        realexHppManager = HPPManager(globalpaymentsHPPViewModel: self)
        realexHppManager?.delegate = self
        realexHppManager?.networkActivityHandler = { [weak self] isLoading in
            DispatchQueue.main.async {
                self?.isLoading = isLoading
            }
        }
        
        let producerPath = AppV2Constants.API.baseURL + CheckoutWebRepository.API.createDraftOrder(nil).path
        let consumerPath = AppV2Constants.API.baseURL + CheckoutWebRepository.API.getRealexHPPProducerData(nil).path
        
        realexHppManager?.HPPRequestProducerURL = URL(string: producerPath)
        realexHppManager?.HPPResponseConsumerURL = URL(string: consumerPath)
        
        // Waiting on the folling settings to come from the store profile:
        // https://snappyshopper.atlassian.net/browse/OAPIV2-501
        
        // https://pay.realexpayments.com/pay
        // https://pay.sandbox.realexpayments.com/pay
        //realexHppManager?.HPPURL = URL(string: "https://pay.sandbox.realexpayments.com/pay")
        
        // encode only for v1 (not v2!) = self.useRealexHppVersion == .v1
        realexHppManager?.isEncoded = false
    }
    
    func dismissView(withError error: Error? = nil) {
        if let error = error {
            result(nil, error)
        }
        DispatchQueue.main.async { [weak self] in
            self?.viewDismissed = true
        }
    }
    
    func loadHPP() {
        
        // Waiting on https://snappyshopper.atlassian.net/browse/BGB-125 to remove some
        // the tagged fields below.
        container.services.checkoutService.createDraftOrder(
            fulfilmentDetails: fulfilmentDetails,
            paymentGateway: .realex,
            instructions: instructions,
            firstname: "Kevin", // remove
            lastname: "Palser", // remove
            emailAddress: "kevin.palser@me.com", // remove
            phoneNumber: "07923340512" //remove
        ).sinkToResult { [weak self] createDraftOrderResult in
            
            guard let self = self else { return }
            
            switch createDraftOrderResult {
            case let .success(resultValue):
                
                if resultValue.businessOrderId != nil {
                    self.dismissView(withError: GlobalpaymentsHPPViewInternalError.unexpectedAPIResult)
                    return
                }
                
                self.container.services.checkoutService.getRealexHPPProducerData()
                    .sinkToResult { getRealexHPPProducerDataResult in
                        
                        switch getRealexHPPProducerDataResult {
                        case let .success(resultValue):
                            self.realexHppManager?.getHPPRequest(with: resultValue)

                        case let .failure(error):
                            self.dismissView(withError: error)
                            
                        }
                        
                    }
                    .store(in: &self.cancellables)

            case let .failure(error):
                self.dismissView(withError: error)
            }
        }
        .store(in: &cancellables)
    }
    
}

// functionality originally in the HPPViewController has been brought into the following extension
extension GlobalpaymentsHPPViewModel: WKNavigationDelegate,  WKUIDelegate, WKScriptMessageHandler {
    
    /// Called if the user taps the cancel button.
    func cancelButtonTapped() {
        realexHppManager?.HPPViewControllerWillDismiss()
    }
    
    /// Loads the network request and displays the result in the webview.
    /// - Parameter request: The network request to be loaded.
    func loadRequest(_ request: URLRequest) {
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false

                guard let data = data, data.count > 0 else {
                    self.realexHppManager?.HPPViewControllerFailedWithError(error)
                    self.dismissView()
                    return
                }
                let htmlString = String(data: data, encoding: String.Encoding.utf8)
                self.loadHTMLString?(htmlString!, request.url)
            }
        })
        
        dataTask.resume()
    }
    
    // MARK: - WKWebView Delegate Callbacks
    
    public func webView(_ webView: WKWebView,
                 didStartProvisionalNavigation navigation: WKNavigation) {

        self.isLoading = true
    }
    
    public func webView(_ webView: WKWebView,
                 didFinish navigation: WKNavigation) {

        self.isLoading = false
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        
        self.isLoading = false
        realexHppManager?.HPPViewControllerFailedWithError(error)
    }
    
    /// Allow all requests to be loaded
    public func webView(_ webView: WKWebView,
                 decidePolicyFor navigationResponse: WKNavigationResponse,
                 decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        decisionHandler(.allow)
    }
    
    /// Allow all navigation actions
    public func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        decisionHandler(.allow)
    }
    
    // MARK: - Javascript Message Callback
    
    /// Delegate callback which receives any massages from the Javascript bridge
    public func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        
        var displayError = false
        
        if
            let messageString = message.body as? String,
            let data = messageString.data(using: String.Encoding.utf8)
        {
            // need to parse the decode the
            do {
                if let dictonary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    
                    DispatchQueue.main.async { [weak self] in
                        self?.isLoading = true
                    }
                    
                    container.services.checkoutService.processRealexHPPConsumerData(hppResponse: dictonary)
                        .receive(on: RunLoop.main)
                        .sinkToResult { [weak self] processRealexHPPConsumerDataResult in
                            
                            guard let self = self else { return }
                            self.isLoading = false
                            
                            switch processRealexHPPConsumerDataResult {
                                
                            case let .success(resultValue):
                                
                                if
                                    let businessOrderId = resultValue.businessOrderId,
                                    resultValue.status
                                {
                                    // sucess
                                    self.businessOrderReceived = true
                                    self.result(businessOrderId, nil)
                                    self.dismissView()
                                } else {
                                    self.realexHppManager?.HPPViewControllerFailedWithError(GlobalpaymentsHPPServiceError.paymentFailed(resultValue.message))
                                }

                            case let .failure(error):
                                self.realexHppManager?.HPPViewControllerFailedWithError(error)
                                
                            }
                        
                        }
                        .store(in: &self.cancellables)
                    
                }
            } catch {
                displayError = true
            }

        } else {
            displayError = true
        }
        
        if displayError {
            realexHppManager?.HPPViewControllerFailedWithError(GlobalpaymentsHPPViewInternalError.unexpectedGlobalpaymentsAPIResult)
        }

    }
}

extension GlobalpaymentsHPPViewModel: HPPManagerDelegate {
    
    public func HPPManagerFailedWithError(_ error: Error?) {
        checkOrderWasNotProcessed(knownError: error)
    }
    
    public func HPPManagerCancelled() {
        checkOrderWasNotProcessed()
    }
    
    // There can be occassions where an error is recorded but the
    // order was successful. So we have a sanity check with the
    // server.
    private func checkOrderWasNotProcessed(knownError: Error? = nil) {
        
        if businessOrderReceived {
            // can close immediately as the order
            // was confirmed as paid
            dismissView()
            return
        }
            
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = true
        }
        
        // wait 1.5 seconds before checking with the server
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            
            if self.businessOrderReceived {
                self.dismissView()
                return
            }
            
            // still no order so check
            self.container.services.checkoutService.confirmPayment()
                .sinkToResult { [weak self] confirmPaymentResponse in
                    
                    guard let self = self else { return }
                    
                    DispatchQueue.main.async { [weak self] in
                        self?.isLoading = false
                    }
                    
                    if self.businessOrderReceived == false {
                    
                        switch confirmPaymentResponse {
                            
                        case let .success(resultValue):
                            
                            if let businessOrderId = resultValue.result.businessOrderId {
                                // sucess confirmed on the sever
                                self.businessOrderReceived = true
                                self.result(businessOrderId, nil)
                                
                            } else if knownError != nil {
                                self.result(nil, knownError)
                            }

                        case .failure:
                            
                            // unable to confirm from the server if the
                            // payment was charges so pass on the error
                            if knownError != nil {
                                self.result(nil, knownError)
                            }
                            
                        }
                        
                    }
                    
                    // whatever the outcomes above the view still needs to be dismissed
                    self.dismissView()
                }
                .store(in: &self.cancellables)
        }
        
    }
    
}
