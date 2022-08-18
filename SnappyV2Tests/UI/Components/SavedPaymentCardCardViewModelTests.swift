//
//  SavedPaymentCardCardViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 18/08/2022.
//

import XCTest
@testable import SnappyV2

class SavedPaymentCardCardViewModelTests: XCTestCase {
    
    func test_givenCardDetails_whenInit_thenCorrrectComputedValues() {
        let card = MemberCardDetails.mockedData
        let sut = makeSUT(card: card)
        
        XCTAssertEqual(sut.formattedCardString, "**** **** **** \(card.last4)")
        XCTAssertEqual(sut.cardType, .visa)
        XCTAssertEqual(sut.expiryYear, card.expiryYear-2000)
    }
    
    func test_givenCardDetailsMasterCard_whenInit_thenCorrectCardType() {
        let card = MemberCardDetails.mockedDataMastercard
        let sut = makeSUT(card: card)
        
        XCTAssertEqual(sut.formattedCardString, "**** **** **** \(card.last4)")
        XCTAssertEqual(sut.cardType, .masterCard)
        XCTAssertEqual(sut.expiryYear, card.expiryYear-2000)
    }

    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), card: MemberCardDetails) -> SavedPaymentCardCardViewModel {
        let sut = SavedPaymentCardCardViewModel(container: container, card: card)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }

}
