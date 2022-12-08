//
//  CreateAccountCardViewModelTests.swift
//  SnappyV2Tests
//
//  Created by David Bage on 05/09/2022.
//

import XCTest
@testable import SnappyV2

@MainActor
class CreateAccountCardViewModelTests: XCTestCase {
    func test_whenInit_thenPasswordHasErrorFalse() {
        let sut = makeSUT()
        XCTAssertFalse(sut.passwordHasError)
    }
    
    func test_whenCreateAccountTapped_givenPasswordIsEmpty_thenPasswordHasErrorIsTrue() async {
        let sut = makeSUT()
        sut.password = ""
        await sut.createAccountTapped()
        XCTAssertTrue(sut.passwordHasError)
    }
    
    func test_whenCreateAccountTapped_givenPasswordIsNotEmptyAndSuccessCheckoutBasketIsNil_thenPasswordHasErrorIsFalseAndErrorIsGenericError() async {
        let sut = makeSUT()
        sut.password = "test"
        await sut.createAccountTapped()
        XCTAssertFalse(sut.passwordHasError)    }
    
    func test_whenCreateAccountTapped_givenPasswordIsNotEmptyAndSuccessCheckoutBasketIsNotNil_thenPasswordHasErrorIsFalseAndCreateAccount() async {
        
        let member = MemberProfileRegisterRequest(
            firstname: "Kevin",
            lastname: "Dover",
            emailAddress: "kevin.dover@me.com",
            referFriendCode: nil,
            mobileContactNumber: "07925304522",
            defaultBillingDetails: nil, savedAddresses: nil)

        
        let container = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked(memberService: [.register(member: member, password: "password1", referralCode: nil, marketingOptions: nil, atCheckout: false)]))
        
        container.appState.value.userData.successCheckoutBasket = .mockedData

        let sut = makeSUT(container: container)
        sut.password = "password1"
        await sut.createAccountTapped()
        XCTAssertFalse(sut.passwordHasError)
        container.services.verify(as: .member)
    }
    
    func makeSUT(container: DIContainer = DIContainer(appState: AppState(), eventLogger: MockedEventLogger(), services: .mocked())) -> CreateAccountCardViewModel {
        let sut = CreateAccountCardViewModel(container: container, isInCheckout: false)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
