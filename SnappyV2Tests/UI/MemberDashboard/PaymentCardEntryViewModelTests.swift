//
//  PaymentCardEntryViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 28/08/2022.
//

import XCTest
import Combine
@testable import SnappyV2

@MainActor
class PaymentCardEntryViewModelTests: XCTestCase {
    
    func test_init() {
        let sut = makeSUT()
        
        XCTAssertTrue(sut.creditCardNumber.isEmpty)
        XCTAssertTrue(sut.creditCardName.isEmpty)
        XCTAssertTrue(sut.creditCardExpiryYear.isEmpty)
        XCTAssertTrue(sut.creditCardExpiryMonth.isEmpty)
        XCTAssertTrue(sut.creditCardCVV.isEmpty)
        XCTAssertNil(sut.shownCardType)
        XCTAssertTrue(sut.showVisaCard)
        XCTAssertTrue(sut.showMasterCardCard)
        XCTAssertTrue(sut.showDiscoverCard)
        XCTAssertTrue(sut.showJCBCard)
        XCTAssertNil(sut.cardType)
        XCTAssertFalse(sut.isUnvalidCardName)
        XCTAssertFalse(sut.isUnvalidCardNumber)
        XCTAssertFalse(sut.isUnvalidExpiry)
        XCTAssertFalse(sut.isUnvalidCVV)
        XCTAssertFalse(sut.showCardCamera)
        XCTAssertNil(sut.error)
        XCTAssertFalse(sut.dismissView)
        XCTAssertFalse(sut.isUnvalidCardName)
        XCTAssertTrue(sut.saveNewCardButtonDisabled)
    }
    
    func test_givenCardTypeIsVisa_whenVisaNumberIsPopulated_thenShowVisaCardIsTrue() {
        let sut = makeSUT()
        sut.creditCardNumber = "4242424242424242" // Visa test number
        
        let expectation = expectation(description: "setupCreditCardNumber")
        var cancellables = Set<AnyCancellable>()
        
        sut.$creditCardNumber
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertTrue(sut.showVisaCard)
        XCTAssertFalse(sut.showMasterCardCard)
        XCTAssertFalse(sut.showDiscoverCard)
        XCTAssertFalse(sut.showJCBCard)
    }
    
    func test_givenCardTypeIsMasterCard_whenCardNumberIsPopulated_thenShowMastercardCardIsTrue() {
        let sut = makeSUT()
        sut.creditCardNumber = "5436031030606378" // Mastercard test number
        
        let expectation = expectation(description: "setupCreditCardNumber")
        var cancellables = Set<AnyCancellable>()
        
        sut.$creditCardNumber
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertFalse(sut.showVisaCard)
        XCTAssertTrue(sut.showMasterCardCard)
        XCTAssertFalse(sut.showDiscoverCard)
        XCTAssertFalse(sut.showJCBCard)
    }
    
    func test_givenCardTypeIsDiscover_whenCardNumberIsPopulated_thenShowDiscoverCardIsTrue() {
        let sut = makeSUT()
        sut.creditCardNumber = "6011111111111117" // Discover test number
        
        let expectation = expectation(description: "setupCreditCardNumber")
        var cancellables = Set<AnyCancellable>()
        
        sut.$creditCardNumber
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertFalse(sut.showVisaCard)
        XCTAssertFalse(sut.showMasterCardCard)
        XCTAssertTrue(sut.showDiscoverCard)
        XCTAssertFalse(sut.showJCBCard)
    }
    
    func test_givenCardTypeIsJCB_whenCardNumberIsPopulated_thenShowJCBCardIsTrue() {
        let sut = makeSUT()
        sut.creditCardNumber = "3530111333300000" // JCB test number
        
        let expectation = expectation(description: "setupCreditCardNumber")
        var cancellables = Set<AnyCancellable>()
        
        sut.$creditCardNumber
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertFalse(sut.showVisaCard)
        XCTAssertFalse(sut.showMasterCardCard)
        XCTAssertFalse(sut.showDiscoverCard)
        XCTAssertTrue(sut.showJCBCard)
    }
    
    func test_givenCorrectCardNumber_thenIsUnvalidCardNumberIsFalse() {
        let sut = makeSUT()
        
        let expectation = expectation(description: "setupCreditCardNumber")
        var cancellables = Set<AnyCancellable>()
        
        sut.$creditCardNumber
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.creditCardNumber = "4242424242424242"
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertFalse(sut.isUnvalidCardNumber)
    }
    
    func test_givenIncorrectCardNumber_thenIsUnvalidCardNumberIsTrue() {
        let sut = makeSUT()
        
        let expectation = expectation(description: "setupCreditCardNumber")
        var cancellables = Set<AnyCancellable>()
        
        sut.$creditCardNumber
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.creditCardNumber = "4242 4242 4242 4242"
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertTrue(sut.isUnvalidCardNumber)
    }
    
    func test_givenCorrectCardExpiryMonth_thenIsUnvalidCardExpiryIsFalse() {
        let sut = makeSUT()
        
        let expectation = expectation(description: "setupCreditCardExpiry")
        var cancellables = Set<AnyCancellable>()
        sut.creditCardExpiryYear = "24"
        
        sut.$creditCardExpiryMonth
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.creditCardExpiryMonth = "09"
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertFalse(sut.isUnvalidExpiry)
    }
    
    func test_givenIncorrectCardExpiryMonth_thenIsUnvalidCardExpiryIsTrue() {
        let sut = makeSUT()
        
        let expectation = expectation(description: "setupCreditCardExpiry")
        var cancellables = Set<AnyCancellable>()
        sut.creditCardExpiryYear = "24"
        
        sut.$creditCardExpiryMonth
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.creditCardExpiryMonth = "13"
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertTrue(sut.isUnvalidExpiry)
    }
    
    func test_givenCorrectCardExpiryYear_thenIsUnvalidCardExpiryIsFalse() {
        let sut = makeSUT()
        
        let expectation = expectation(description: "setupCreditCardExpiry")
        var cancellables = Set<AnyCancellable>()
        sut.creditCardExpiryMonth = "09"
        
        sut.$creditCardExpiryYear
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.creditCardExpiryYear = "24"
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertFalse(sut.isUnvalidExpiry)
    }
    
    func test_givenIncorrectCardExpiryYear_thenIsUnvalidCardExpiryIsTrue() {
        let sut = makeSUT()
        
        let expectation = expectation(description: "setupCreditCardExpiry")
        var cancellables = Set<AnyCancellable>()
        sut.creditCardExpiryMonth = "09"
        
        sut.$creditCardExpiryYear
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.creditCardExpiryYear = "14"
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertTrue(sut.isUnvalidExpiry)
    }
    
    func test_givenCorrectCardCVV_thenIsUnvalidCardCVVIsFalse() {
        let sut = makeSUT()
        
        let expectation = expectation(description: "setupCreditCardCVV")
        var cancellables = Set<AnyCancellable>()
        
        sut.$creditCardCVV
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.creditCardCVV = "100"
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertFalse(sut.isUnvalidCVV)
    }
    
    func test_givenIncorrectCardCVV_thenIsUnvalidCardCVVIsTrue() {
        let sut = makeSUT()
        sut.creditCardNumber = "4242424242424242"
        
        let expectation = expectation(description: "setupCreditCardCVV")
        var cancellables = Set<AnyCancellable>()
        
        sut.$creditCardCVV
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.creditCardCVV = "1000"
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertTrue(sut.isUnvalidCVV)
    }

    func test_givenCorrectDetails_whenAreCardDetailsValidTriggered_thenReturnsTrue() {
        let sut = makeSUT()
        sut.creditCardName = "Some Name"
        sut.creditCardNumber = "4242424242424242"
        sut.creditCardExpiryMonth = "03"
        sut.creditCardExpiryYear = "24"
        sut.creditCardCVV = "100"
        
        XCTAssertTrue(sut.areCardDetailsValid())
    }
    
    func test_givenIncorrectNumberDetails_whenAreCardDetailsValidTriggered_thenReturnsFalse() {
        let sut = makeSUT()
        sut.creditCardName = "Some Name"
        sut.creditCardNumber = "4242 4242 4242 4242"
        sut.creditCardExpiryMonth = "03"
        sut.creditCardExpiryYear = "24"
        sut.creditCardCVV = "100"
        
        XCTAssertFalse(sut.areCardDetailsValid())
    }
    
    func test_givenIncorrectExpiryMonthDetails_whenAreCardDetailsValidTriggered_thenReturnsFalse() {
        let sut = makeSUT()
        sut.creditCardName = "Some Name"
        sut.creditCardNumber = "4242424242424242"
        sut.creditCardExpiryMonth = "13"
        sut.creditCardExpiryYear = "24"
        sut.creditCardCVV = "100"
        
        XCTAssertFalse(sut.areCardDetailsValid())
    }
    
    func test_givenIncorrectExpiryYearDetails_whenAreCardDetailsValidTriggered_thenReturnsFalse() {
        let sut = makeSUT()
        sut.creditCardName = "Some Name"
        sut.creditCardNumber = "4242424242424242"
        sut.creditCardExpiryMonth = "06"
        sut.creditCardExpiryYear = "13"
        sut.creditCardCVV = "100"
        
        XCTAssertFalse(sut.areCardDetailsValid())
    }
    
    func test_givenIncorrectCVVDetails_whenAreCardDetailsValidTriggered_thenReturnsFalse() {
        let sut = makeSUT()
        sut.creditCardName = "Some Name"
        sut.creditCardNumber = "4242424242424242"
        sut.creditCardExpiryMonth = "09"
        sut.creditCardExpiryYear = "24"
        sut.creditCardCVV = "1000"
        
        let expectation = expectation(description: "setupCreditCardNumber")
        var cancellables = Set<AnyCancellable>()
        
        sut.$creditCardNumber
            .first()
            .receive(on: RunLoop.main)
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertFalse(sut.areCardDetailsValid())
    }
    
    func test_givenMissingCardNameDetails_whenAreCardDetailsValidTriggered_thenReturnsFalse() {
        let sut = makeSUT()
        sut.creditCardName = ""
        sut.creditCardNumber = "4242424242424242"
        sut.creditCardExpiryMonth = "09"
        sut.creditCardExpiryYear = "24"
        sut.creditCardCVV = "100"
        
        XCTAssertFalse(sut.areCardDetailsValid())
    }
    
    func test_givenMemberProfile_whenInit_thenCreditCardNameIsCorrect() {
        let memberProfile = MemberProfile.mockedData
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())
        container.appState.value.userData.memberProfile = memberProfile
        let sut = makeSUT(container: container)
        
        XCTAssertEqual(sut.creditCardName, memberProfile.firstname + " " + memberProfile.lastname)
    }
    
    func test_whenShowCardCameraTapped_thenShowCardCameraIsTrue() {
        let sut = makeSUT()
        
        sut.showCardCameraTapped()
        
        XCTAssertTrue(sut.showCardCamera)
    }
    
    func test_givenCardDetailsWithSpaces_whenHandleCardCameraReturnTriggered_thenCorrectDetailsAreFilled() {
        let sut = makeSUT()
        let name = "Some Name"
        let number = "4242 4242 4242 4242"
        let expiry = "04/24"
        let expectedMonth = "04"
        let expectedYear = "24"
        let expectedNumber = "4242424242424242"
        
        sut.handleCardCameraReturn(name: name, number: number, expiry: expiry)
        
        XCTAssertEqual(sut.creditCardName, name)
        XCTAssertEqual(sut.creditCardNumber, expectedNumber)
        XCTAssertEqual(sut.creditCardExpiryMonth, expectedMonth)
        XCTAssertEqual(sut.creditCardExpiryYear, expectedYear)
    }
    
    func test_givenNumberWithLetters_whenTriggerFilterCardNumber_thenOnlyNumbers() {
        let sut = makeSUT()
        
        sut.filterCardNumber(newValue: "1234AB56")
        
        XCTAssertEqual(sut.creditCardNumber, "123456")
    }
    
    func test_givenNumberWithLetters_whenTriggerFilterCardCVV_thenOnlyNumbers() {
        let sut = makeSUT()
        
        sut.filterCardCVV(newValue: "1234AB56")
        
        XCTAssertEqual(sut.creditCardCVV, "123456")
    }
    
    func test_givenCardDetails_whenSaveCardTapped_thenCorrectCallIsMade() async {
        let address = Address.mockedBillingData
        let businessProfile = BusinessProfile.mockedDataFromAPI
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(memberService: [.saveNewCard(token: "SomeToken")]))
        container.appState.value.businessData.businessProfile = businessProfile
        let checkoutComClient = { MockCheckoutAPIClient(publicKey: $0, environment: $1) }
        let sut = makeSUT(container: container, checkoutComClient: checkoutComClient)
        sut.creditCardName = "Some Name"
        sut.creditCardNumber = "4242424242424242"
        sut.creditCardExpiryMonth = "03"
        sut.creditCardExpiryYear = "24"
        sut.creditCardCVV = "100"
        
        await sut.saveCardTapped(address: address)
        
        XCTAssertTrue(sut.dismissView)
        container.services.verify(as: .member)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked()), checkoutComClient: @escaping PaymentCardEntryViewModel.CheckoutComClient = { MockCheckoutAPIClient(publicKey: $0, environment: $1) }) -> PaymentCardEntryViewModel {
        
        let sut = PaymentCardEntryViewModel(container: container, checkoutComClient: checkoutComClient)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
