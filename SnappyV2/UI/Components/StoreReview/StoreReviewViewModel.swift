//
//  StoreReviewViewModel.swift
//  SnappyV2
//
//  Created by Kevin Palser on 06/09/2022.
//

import Foundation
import Combine
import CoreGraphics

@MainActor
class StoreReviewViewModel: ObservableObject {
    let container: DIContainer
    let dismissStoreReviewViewHandler: () -> ()
    let review: RetailStoreReview
    
    @Published var rating = 0
    @Published var commentsPlaceholder = ""
    @Published var comments = ""
    @Published var missingWarning = "Select the star rating above to continue."
    @Published var submittingReview = false
    @Published var showSubmittedConfirmation = false
    @Published var error: Error?
    
    let minimumCommentsLength = 10
    
    var instructions: String {
        StoreReviewStrings.InstructionsText.instructions.localizedFormat(AppV2Constants.Business.businessLocationName)
    }
    
    // MARK: - Typealiases
    typealias StoreReviewStrings = Strings.StoreReview
    
    private(set) var showTelephoneNumber = ""
    private var cancellables = Set<AnyCancellable>()

    init(container: DIContainer, review: RetailStoreReview, dismissStoreReviewViewHandler: @escaping ()->()) {
        self.container = container
        self.review = review
        self.dismissStoreReviewViewHandler = dismissStoreReviewViewHandler
        commentsPlaceholder = StoreReviewStrings.CommentsPlaceholderText.neutralCommentsPlaceholder.localizedFormat(AppV2Constants.Business.businessLocationName)
        
        $rating.sink { [weak self] rating in
            guard let self = self else { return } 
            self.commentsPlaceholder = rating == 0 || rating > 3 ? StoreReviewStrings.CommentsPlaceholderText.neutralCommentsPlaceholder.localizedFormat(AppV2Constants.Business.businessLocationName) : StoreReviewStrings.CommentsPlaceholderText.negativeCommentsPlaceholder.localizedFormat(AppV2Constants.Business.businessLocationName)
        }
        .store(in: &cancellables)
        
        $comments.sink { [weak self] comments in
            guard let self = self else { return }
            if self.rating != 0 {
                self.updateMissingWarning()
            }
        }
        .store(in: &cancellables)
    }
    
    private var trimmedComments: String {
        comments.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    private func updateMissingWarning() {
        if rating > 3 || trimmedComments.count >= minimumCommentsLength {
            missingWarning = ""
        } else {
            missingWarning = "To continue add some information to help improve the service."
        }
    }
    
    func tappedStar(rating: Int) {
        self.rating = rating
        updateMissingWarning()
    }
    
    func tappedSubmitReview() {
        dismissStoreReviewViewHandler()
    }
    
}
