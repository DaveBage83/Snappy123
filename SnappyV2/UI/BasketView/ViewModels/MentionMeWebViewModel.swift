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
    private let dismissWebViewHandler: (MentionMeCouponAction?) -> Void
    
    init(container: DIContainer, mentionMeRequestResult: MentionMeRequestResult, dismissWebViewHandler: @escaping (MentionMeCouponAction?) -> Void) {
        self.container = container
        self.mentionMeRequestResult = mentionMeRequestResult
        self.dismissWebViewHandler = dismissWebViewHandler
    }
    
    func dismissWebViewHandler(couponAction: MentionMeCouponAction?) {
        dismissWebViewHandler(couponAction)
    }

}
