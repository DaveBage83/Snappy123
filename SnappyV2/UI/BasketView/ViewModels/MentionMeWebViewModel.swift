//
//  MentionMeWebViewModel.swift
//  SnappyV2
//
//  Created by Kevin Palser on 19/06/2022.
//

import Combine
import Foundation
import OSLog

@MainActor
class MentionMeWebViewModel: ObservableObject {

    let container: DIContainer
    let mentionMeRequestResult: MentionMeRequestResult
    private let parentDismissWebViewHandler: (MentionMeCouponAction?) -> Void
    var couponAction: MentionMeCouponAction?
    
    lazy var title: String = {
        mentionMeRequestResult.buttonText ?? Strings.MentionMe.Webview.fallbackTitle.localized
    }()
    
    init(container: DIContainer, mentionMeRequestResult: MentionMeRequestResult, dismissWebViewHandler: @escaping (MentionMeCouponAction?) -> Void) {
        self.container = container
        self.mentionMeRequestResult = mentionMeRequestResult
        self.parentDismissWebViewHandler = dismissWebViewHandler
    }
    
    func setCouponActionHandler(couponAction: MentionMeCouponAction?) {
        self.couponAction = couponAction
    }
    
    func dismissWebViewHandler() {
        parentDismissWebViewHandler(couponAction)
    }

}
