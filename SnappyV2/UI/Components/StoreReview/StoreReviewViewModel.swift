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
    @Published var missingWarning = StoreReviewStrings.StaticText.missingRating.localized
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
            missingWarning = StoreReviewStrings.StaticText.missingComment.localized
        }
    }
    
    func tappedStar(rating: Int) {
        self.rating = rating
        updateMissingWarning()
    }
    
    func tappedSubmitReview() {
        // Sanity check but should not be able to reach submit button if:
        // - the rating has not be chosen
        // - if the rating is less than 4 without minimum comments content
        guard rating > 3 || (rating > 0 && rating < 4 && trimmedComments.count >= minimumCommentsLength) else { return }
        // update the interface
        submittingReview = true
        
        dismissStoreReviewViewHandler()
    }
    
}
