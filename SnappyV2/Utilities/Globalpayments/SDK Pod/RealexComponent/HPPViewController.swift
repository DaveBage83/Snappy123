// Most of this original file from the Pod SDK is commented out because the bulk of the code has been moved
// into GlobalpaymentsHPPViewModel. It has been left for reference so if Globalpayments updates their SDK we
// can more easily orientate ourselves to update our code.

import UIKit
import WebKit

/// The delegate callbacks which allow the HPPManager to receive back the results from the WKWebView.
@objc protocol HPPViewControllerDelegate: AnyObject {
    @objc func HPPViewControllerWillDismiss()
    //@objc func HPPViewControllerCompletedWithResult(_ result: String)
    @objc func HPPViewControllerFailedWithError(_ error: Error?)
}

///// The Web View Controller which encapsulates the management of the webivew and the interaction with the HPP web page.
//class HPPViewController: UIViewController, WKNavigationDelegate,  WKUIDelegate, WKScriptMessageHandler {
//    
//    var webView: WKWebView?
//    var delegate: HPPViewControllerDelegate?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        initialiseWebView()
//
//        let cancelButton = UIBarButtonItem(
//            title: "Cancel",
//            style: UIBarButtonItem.Style.plain,
//            target: self,
//            action: #selector(HPPViewController.closeView)
//        )
//        navigationItem.leftBarButtonItem = cancelButton
//    }
//
//    /// Initialises the WKWebview.
//    private func initialiseWebView() {
//
//        // Globalpayments version where
//        // let viewScriptString = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
//
//        // Snappy Fix
//        let viewScriptString = "var meta = document.createElement('meta');" +
//            "meta.name = 'viewport';" +
//            "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
//            "var head = document.getElementsByTagName('head')[0];" +
//            "head.appendChild(meta);"
//
//        let viewScript = WKUserScript(source: viewScriptString,
//                                      injectionTime: .atDocumentEnd,
//                                      forMainFrameOnly: true)
//
//        let userContentController = WKUserContentController()
//        userContentController.addUserScript(viewScript)
//        userContentController.add(self, name: "callbackHandler")
//
//        let configuration = WKWebViewConfiguration()
//        configuration.userContentController = userContentController
//        webView = WKWebView(frame: view.bounds, configuration: configuration)
//        webView?.backgroundColor = .white
//        webView?.navigationDelegate = self
//        view = webView
//    }
//
//    /// Called if the user taps the cancel button.
//    @objc func closeView() {
//        delegate?.HPPViewControllerWillDismiss()
//        dismiss(animated: true, completion: nil)
//    }
//
//    /// Loads the network request and displays the result in the webview.
//    /// - Parameter request: The network request to be loaded.
//    func loadRequest(_ request: URLRequest) {
//        let session = URLSession.shared
//        let dataTask = session.dataTask(with: request, completionHandler: { data, response, error in
//            DispatchQueue.main.async {
//                UIApplication.shared.isNetworkActivityIndicatorVisible = false
//
//                guard let data = data, data.count > 0 else {
//                    self.delegate?.HPPViewControllerFailedWithError(error)
//                    self.dismiss(animated: true, completion: nil)
//                    return
//                }
//                let htmlString = String(data: data, encoding: String.Encoding.utf8)
//                self.webView?.loadHTMLString(htmlString!, baseURL: request.url)
//            }
//        })
//
//        dataTask.resume()
//    }
//
//    // MARK: - WKWebView Delegate Callbacks
//
//    func webView(_ webView: WKWebView,
//                 didStartProvisionalNavigation navigation: WKNavigation) {
//
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//    }
//
//    func webView(_ webView: WKWebView,
//                 didFinish navigation: WKNavigation) {
//
//        UIApplication.shared.isNetworkActivityIndicatorVisible = false
//    }
//
//    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
//
//        UIApplication.shared.isNetworkActivityIndicatorVisible = false
//        delegate?.HPPViewControllerFailedWithError(error)
//    }
//
//    /// Allow all requests to be loaded
//    func webView(_ webView: WKWebView,
//                 decidePolicyFor navigationResponse: WKNavigationResponse,
//                 decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
//
//        decisionHandler(.allow)
//    }
//
//    /// Allow all navigation actions
//    func webView(_ webView: WKWebView,
//                 decidePolicyFor navigationAction: WKNavigationAction,
//                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//
//        decisionHandler(.allow)
//    }
//
//    // MARK: - Javascript Message Callback
//
//    /// Delegate callback which receives any massages from the Javascript bridge
//    func userContentController(_ userContentController: WKUserContentController,
//                               didReceive message: WKScriptMessage) {
//
//        if let messageString = message.body as? String {
//            delegate?.HPPViewControllerCompletedWithResult(messageString)
//        } else {
//            delegate?.HPPViewControllerFailedWithError(nil)
//        }
//
//        dismiss(animated: true, completion: nil)
//    }
//}
