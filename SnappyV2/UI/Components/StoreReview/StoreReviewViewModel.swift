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
    let dismissStoreReviewViewHandler: (Bool) -> ()
    let review: RetailStoreReview
    
    @Published var rating = 0
    @Published var commentsPlaceholder = StoreReviewStrings.CommentsPlaceholderText.neutralCommentsPlaceholder.localizedFormat(AppV2Constants.Business.businessLocationName)
    @Published var comments = ""
    @Published var missingWarning = StoreReviewStrings.StaticText.missingRating.localized
    @Published var submittingReview = false
    @Published var error: Error?
    
    let minimumCommentsLength = 10
    
    var instructions: String {
        StoreReviewStrings.InstructionsText.instructions.localizedFormat(AppV2Constants.Business.businessLocationName)
    }
    
    // MARK: - Typealiases
    typealias StoreReviewStrings = Strings.StoreReview
    
    private(set) var showTelephoneNumber = ""
    private var cancellables = Set<AnyCancellable>()

    init(container: DIContainer, review: RetailStoreReview, dismissStoreReviewViewHandler: @escaping (Bool)->()) {
        self.container = container
        self.review = review
        self.dismissStoreReviewViewHandler = dismissStoreReviewViewHandler
        
        $rating.sink { [weak self] rating in
            guard let self = self else { return } 
            self.commentsPlaceholder = rating == 0 || rating > 3 ? StoreReviewStrings.CommentsPlaceholderText.neutralCommentsPlaceholder.localizedFormat(AppV2Constants.Business.businessLocationName) : StoreReviewStrings.CommentsPlaceholderText.negativeCommentsPlaceholder.localizedFormat(AppV2Constants.Business.businessLocationName)
        }
        .store(in: &cancellables)
        
        $comments.sink { [weak self] comments in
            guard let self = self else { return }
            if self.rating != 0 {
                self.updateMissingWarning(comment: comments)
            }
        }
        .store(in: &cancellables)
    }
    
    private func updateMissingWarning(comment: String) {
        if rating > 3 || comment.trimmingCharacters(in: CharacterSet.whitespaces).count >= minimumCommentsLength {
            missingWarning = ""
        } else {
            missingWarning = StoreReviewStrings.StaticText.missingComment.localized
        }
    }
    
    func tappedStar(rating: Int) {
        self.rating = rating
        updateMissingWarning(comment: comments)
    }
    
    func tappedClose() {
        dismissStoreReviewViewHandler(false)
    }
    
    func tappedSubmitReview() {
        // Sanity check but should not be able to reach submit button if:
        // - the rating has not be chosen
        // - if the rating is less than 4 without minimum comments content
        let trimmedComments = comments.trimmingCharacters(in: CharacterSet.whitespaces)
        guard rating > 3 || (rating > 0 && rating < 4 && trimmedComments.count >= minimumCommentsLength) else { return }
        // update the interface
        submittingReview = true
        
        Task { [weak self] in
            guard let self = self else { return }
            do {
                try await container.services.retailStoresService.sendReview(
                    for: review,
                    rating: rating,
                    comments: trimmedComments
                )
                dismissStoreReviewViewHandler(true)
            } catch {
                submittingReview = false
                self.error = error
            }
        }
    }
    
}
