//
//  StoreReviewViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 14/09/2022.
//

import XCTest
import Combine
@testable import SnappyV2

@MainActor
final class StoreReviewViewModelTests: XCTestCase {
    
    // Present here because published vars cannot be used as local function variables
    @Published var reviewSentResult: Bool?
    
    @MainActor override func tearDown() {
        reviewSentResult = nil
    }

    func test_init() {
        let review = RetailStoreReview.mockedData
        let sut = makeSUT(review: review)
        XCTAssertEqual(sut.rating, 0, file: #file, line: #line)
        XCTAssertEqual(sut.commentsPlaceholder, Strings.StoreReview.CommentsPlaceholderText.neutralCommentsPlaceholder.localizedFormat(AppV2Constants.Business.businessLocationName), file: #file, line: #line)
        XCTAssertTrue(sut.showMissingWarning, file: #file, line: #line)
        XCTAssertEqual(sut.missingWarning, Strings.StoreReview.StaticText.missingRating.localized, file: #file, line: #line)
        XCTAssertFalse(sut.submittingReview, file: #file, line: #line)
        XCTAssertNil(sut.error, file: #file, line: #line)
    }
    
    func test_commentsPlaceholder_changesWhenRatingLessThanFour() {
        let rating = 3
        let sut = makeSUT()
        sut.tappedStar(rating: rating)
        XCTAssertEqual(sut.commentsPlaceholder, Strings.StoreReview.CommentsPlaceholderText.negativeCommentsPlaceholder.localizedFormat(AppV2Constants.Business.businessLocationName), file: #file, line: #line)
    }
    
    func test_comments_whenLessThanFourStarAndCommentsLengthSufficient_missingWarningRemoved() {
        let rating = 3
        let sut = makeSUT()
        
        sut.comments = "small"
        sut.tappedStar(rating: rating)
        
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: #function)

        sut.$missingWarning
            .filter { $0.isEmpty } // only want true case
            .receive(on: RunLoop.main)
            .sink { text in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.comments = "comment that is not too small"
        
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(sut.rating, rating, file: #file, line: #line)
        XCTAssertEqual(sut.missingWarning, "", file: #file, line: #line)
    }
    
    func test_tappedStar_whenThreeSelected_missingInfoChanges() {
        
        let rating = 3
        let sut = makeSUT()
        
        sut.tappedStar(rating: rating)
        
        XCTAssertEqual(sut.rating, rating, file: #file, line: #line)
        XCTAssertTrue(sut.showMissingWarning, file: #file, line: #line)
        XCTAssertEqual(sut.missingWarning, Strings.StoreReview.StaticText.missingComment.localized, file: #file, line: #line)
    }
    
    func test_tappedStar_whenThreeSelectedWithTooSmallComment_missingInfoChanges() {
        
        let rating = 3
        let sut = makeSUT()
        
        sut.comments = "small"
        sut.tappedStar(rating: rating)
        
        XCTAssertEqual(sut.rating, rating, file: #file, line: #line)
        XCTAssertTrue(sut.showMissingWarning, file: #file, line: #line)
        XCTAssertEqual(sut.missingWarning, Strings.StoreReview.StaticText.missingComment.localized, file: #file, line: #line)
    }
    
    func test_tappedStar_whenThreeSelectedWithComment_missingInfoChanges() {
        
        let rating = 3
        let sut = makeSUT()
        
        sut.comments = "comment that is not too small"
        sut.tappedStar(rating: rating)
        
        XCTAssertEqual(sut.rating, rating, file: #file, line: #line)
        XCTAssertFalse(sut.showMissingWarning, file: #file, line: #line)
        XCTAssertEqual(sut.missingWarning, "", file: #file, line: #line)
    }
    
    func test_tappedSubmitReview_whenRatingCriteriaIsMet_sendRatingAndComments() async {
        
        let review = RetailStoreReview.mockedData
        let rating = 4
        let comments = "My test comments"
        
        let sut = makeSUT(
            retailStoreService: MockedRetailStoreService(expected: [.sendReview(for: review, rating: rating, comments: comments)]),
            review: review
        ) { [weak self] reviewSent in
            guard let self = self else { return }
            self.reviewSentResult = reviewSent
        }
        
        sut.tappedStar(rating: 4)
        sut.comments = comments
        
        var cancellables = Set<AnyCancellable>()
        
        var submittingReviewStarted = false
        
        // check that the submitting flag was set to true at some point
        // even if it reverted to false
        sut.$submittingReview
            .filter { $0 } // only want true case
            .receive(on: RunLoop.main)
            .sink { _ in
                submittingReviewStarted = true
            }
            .store(in: &cancellables)
        
        await sut.tappedSubmitReview()
        
        XCTAssertTrue(submittingReviewStarted, file: #file, line: #line)
        XCTAssertNotNil(reviewSentResult, file: #file, line: #line)
        if let reviewSentResult = reviewSentResult {
            XCTAssertTrue(reviewSentResult, file: #file, line: #line)
        }
        XCTAssertNil(sut.error, file: #file, line: #line)
    }
    
    func test_tappedSubmitReview_whenRatingCriteriaIsMetWithSendError_setError() async {
        
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: [:])
        
        let review = RetailStoreReview.mockedData
        let rating = 4
        let comments = "My test comments"
        
        let retailStoreService = MockedRetailStoreService(expected: [.sendReview(for: review, rating: rating, comments: comments)])
        
        let sut = makeSUT(
            retailStoreService: retailStoreService,
            review: review
        ) { [weak self] reviewSent in
            guard let self = self else { return }
            self.reviewSentResult = reviewSent
        }
        
        retailStoreService.sendReviewError = networkError
        
        sut.tappedStar(rating: 4)
        sut.comments = comments
        
        var cancellables = Set<AnyCancellable>()
        
        var submittingReviewStarted = false
        
        // check that the submitting flag was set to true at some point
        // even if it reverted to false
        sut.$submittingReview
            .filter { $0 } // only want true case
            .receive(on: RunLoop.main)
            .sink { _ in
                submittingReviewStarted = true
            }
            .store(in: &cancellables)
        
        await sut.tappedSubmitReview()
        
        XCTAssertTrue(submittingReviewStarted, file: #file, line: #line)
        XCTAssertFalse(sut.submittingReview, file: #file, line: #line)
        XCTAssertNil(reviewSentResult, file: #file, line: #line)
        XCTAssertEqual(sut.error as? NSError, networkError, file: #file, line: #line)
    }

    func test_tappedClose() {
        var reviewSentResult: Bool?
        let sut = makeSUT() { reviewSent in
            reviewSentResult = reviewSent
        }
        
        sut.tappedClose()
        
        XCTAssertNotNil(reviewSentResult, file: #file, line: #line)
        if let reviewSentResult = reviewSentResult {
            XCTAssertFalse(reviewSentResult, file: #file, line: #line)
        }
    }
    
    func makeSUT(
        appState: AppState = AppState(),
        retailStoreService: MockedRetailStoreService = MockedRetailStoreService(expected: []),
        review: RetailStoreReview = RetailStoreReview.mockedData,
        dismissStoreReviewViewHandler: @escaping (Bool)->() = { _ in }
    ) -> StoreReviewViewModel {
        
        let services = DIContainer.Services(
            businessProfileService: MockedBusinessProfileService(expected: []),
            retailStoreService: retailStoreService,
            retailStoreMenuService: MockedRetailStoreMenuService(expected: []),
            basketService: MockedBasketService(expected: []),
            memberService: MockedUserService(expected: []),
            checkoutService: MockedCheckoutService(expected: []),
            addressService: MockedAddressService(expected: []),
            utilityService: MockedUtilityService(expected: []),
            imageService: MockedImageService(expected: []),
            notificationService: MockedNotificationService(expected: []),
            userPermissionsService: MockedUserPermissionsService(expected: [])
        )
        
        let sut = StoreReviewViewModel(
            container: DIContainer(appState: appState, eventLogger: MockedEventLogger(), services: services),
            review: review,
            dismissStoreReviewViewHandler: dismissStoreReviewViewHandler
        )
        trackForMemoryLeaks(sut)
        return sut
    }

}
