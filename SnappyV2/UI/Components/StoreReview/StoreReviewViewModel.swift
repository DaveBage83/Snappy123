//
//  StoreReviewViewModel.swift
//  SnappyV2
//
//  Created by Kevin Palser on 06/09/2022.
//

import Foundation
import Combine

@MainActor
class StoreReviewViewModel: ObservableObject {
    let container: DIContainer
    let dismissPushNotificationViewHandler: () -> ()
    let notification: DisplayablePushNotification
    
    @Published var rating = 0
    @Published var commentsPlaceholder = ""
    @Published var comments = ""
    @Published var submittingReview = false
    @Published var showSubmittedConfirmation = false
    @Published var error: Error?
    
    // MARK: - Typealiases
    typealias StoreReviewStrings = Strings.StoreReview
    
    private(set) var showTelephoneNumber = ""
    private var cancellables = Set<AnyCancellable>()

    init(container: DIContainer, notification: DisplayablePushNotification, dismissPushNotificationViewHandler: @escaping ()->()) {
        self.container = container
        self.notification = notification
        self.dismissPushNotificationViewHandler = dismissPushNotificationViewHandler
        commentsPlaceholder = StoreReviewStrings.CommentsPlaceholderText.neutralCommentsPlaceholder.localizedFormat(AppV2Constants.Business.businessLocationName)
        
        $rating.sink { [weak self] rating in
            guard let self = self else { return } 
            self.commentsPlaceholder = rating == 0 || rating > 3 ? StoreReviewStrings.CommentsPlaceholderText.neutralCommentsPlaceholder.localizedFormat(AppV2Constants.Business.businessLocationName) : StoreReviewStrings.CommentsPlaceholderText.negativeCommentsPlaceholder.localizedFormat(AppV2Constants.Business.businessLocationName)
        }
        .store(in: &cancellables)
    }
    
    func tappedStar(rating: Int) {
        self.rating = rating
    }
    
    func dismissPushNotificationPrompt() {
        dismissPushNotificationViewHandler()
    }
    
}
