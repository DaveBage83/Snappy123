//
//  CheckoutServiceTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 06/02/2022.
//

import XCTest
import Combine
@testable import SnappyV2

class CheckoutServiceTests: XCTestCase {
    
    var appState = CurrentValueSubject<AppState, Never>(AppState())
    var mockedWebRepo: MockedCheckoutWebRepository!
    var mockedDBRepo: MockedCheckoutDBRepository!
    var subscriptions = Set<AnyCancellable>()
    var sut: CheckoutService!

    override func setUp() {
        mockedWebRepo = MockedCheckoutWebRepository()
        mockedDBRepo = MockedCheckoutDBRepository()
        sut = CheckoutService(
            webRepository: mockedWebRepo,
            dbRepository: mockedDBRepo,
            appState: appState
        )
    }
    
    func delay(_ closure: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: closure)
    }

    override func tearDown() {
        appState = CurrentValueSubject<AppState, Never>(AppState())
        subscriptions = Set<AnyCancellable>()
        mockedWebRepo = nil
        mockedDBRepo = nil
        sut = nil
    }
}

// MARK: - func createDraftOrder(fulfilmentDetails:paymentGateway:instructions:firstname:lastname:emailAddress:phoneNumber:)
final class CreateDraftOrderTests: CheckoutServiceTests {
    
    func test_successfulCreateDraftOrder_whenCashOrder_thenDraftOrderWithBusinessOrderId() {
        let draftOrderResult = DraftOrderResult.mockedCashData
        
        // Configuring app prexisting states
        appState.value.userData.basket = Basket.mockedData
        appState.value.userData.selectedStore = .loaded(RetailStoreDetails.mockedData)
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .createDraftOrder(
                basketToken: Basket.mockedData.basketToken,
                fulfilmentDetails: DraftOrderFulfilmentDetailsRequest.mockedData,
                instructions: "Knock twice!",
                paymentGateway: .cash,
                storeId: RetailStoreDetails.mockedData.id,
                firstname: "Harold",
                lastname: "Dover",
                emailAddress: "h.dover@gmail.com",
                phoneNumber: "07923335522"
            )
        ])
        mockedDBRepo.actions = .init(expected: [
            .clearBasket
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.createDraftOrderResponse = .success(draftOrderResult)
        mockedDBRepo.clearBasketResult = .success(true)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .createDraftOrder(
                fulfilmentDetails: DraftOrderFulfilmentDetailsRequest.mockedData,
                paymentGateway: .cash,
                instructions: "Knock twice!",
                firstname: "Harold",
                lastname: "Dover",
                emailAddress: "h.dover@gmail.com",
                phoneNumber: "07923335522"
            )
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .success(resultValue):
                    XCTAssertEqual(resultValue.businessOrderId, draftOrderResult.businessOrderId, file: #file, line: #line)
                    XCTAssertEqual(resultValue.savedCards, draftOrderResult.paymentMethods, file: #file, line: #line)
                case let .failure(error):
                    XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
    func test_unsuccessfulCreateDraftOrder_whenNoBasket_thenError() {

        // Configuring app prexisting states
        appState.value.userData.selectedStore = .loaded(RetailStoreDetails.mockedData)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .createDraftOrder(
                fulfilmentDetails: DraftOrderFulfilmentDetailsRequest.mockedData,
                paymentGateway: .cash,
                instructions: "Knock twice!",
                firstname: "Harold",
                lastname: "Dover",
                emailAddress: "h.dover@gmail.com",
                phoneNumber: "07923335522"
            )
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .success(resultValue):
                    XCTFail("Unexpected result: \(resultValue)", file: #file, line: #line)
                case let .failure(error):
                    if let checkoutError = error as? CheckoutServiceError {
                        XCTAssertEqual(checkoutError, CheckoutServiceError.unableToProceedWithoutBasket, file: #file, line: #line)
                    } else {
                        XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
                    }
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }
    
    func test_unsuccessfulCreateDraftOrder_whenNoSelectedStore_thenError() {
        
        // Configuring app prexisting states
        appState.value.userData.basket = Basket.mockedData
        
        let exp = XCTestExpectation(description: #function)
        sut
            .createDraftOrder(
                fulfilmentDetails: DraftOrderFulfilmentDetailsRequest.mockedData,
                paymentGateway: .cash,
                instructions: "Knock twice!",
                firstname: "Harold",
                lastname: "Dover",
                emailAddress: "h.dover@gmail.com",
                phoneNumber: "07923335522"
            )
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .success(resultValue):
                    XCTFail("Unexpected result: \(resultValue)", file: #file, line: #line)
                case let .failure(error):
                    if let checkoutError = error as? CheckoutServiceError {
                        XCTAssertEqual(checkoutError, CheckoutServiceError.storeSelectionRequired, file: #file, line: #line)
                    } else {
                        XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
                    }
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [exp], timeout: 0.5)
    }

}

// MARK: - func getRealexHPPProducerData()
final class GetRealexHPPProducerDataTests: CheckoutServiceTests {
    
    func test_successfulGetRealexHPPProducerData_whenDraftOrder_thenDataForHPP() {
        
        // Create a draft order because sut.draftOrderId needs to be
        // set and is private
        let draftOrderResult = DraftOrderResult.mockedCardData
        let getRealexHPPProducerDataResult = Data.mockedGlobalpaymentsProducerData
        
        // Configuring app prexisting states
        appState.value.userData.basket = Basket.mockedData
        appState.value.userData.selectedStore = .loaded(RetailStoreDetails.mockedData)
        
        // Configuring expected actions on repositories
        mockedWebRepo.actions = .init(expected: [
            .createDraftOrder(
                basketToken: Basket.mockedData.basketToken,
                fulfilmentDetails: DraftOrderFulfilmentDetailsRequest.mockedData,
                instructions: "Knock twice!",
                paymentGateway: .realex,
                storeId: RetailStoreDetails.mockedData.id,
                firstname: "Harold",
                lastname: "Dover",
                emailAddress: "h.dover@gmail.com",
                phoneNumber: "07923335522"
            ),
            .getRealexHPPProducerData(orderId: draftOrderResult.draftOrderId)
        ])
        
        // Configuring responses from repositories
        mockedWebRepo.createDraftOrderResponse = .success(draftOrderResult)
        mockedWebRepo.getRealexHPPProducerDataResponse = .success(getRealexHPPProducerDataResult)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .createDraftOrder(
                fulfilmentDetails: DraftOrderFulfilmentDetailsRequest.mockedData,
                paymentGateway: .realex,
                instructions: "Knock twice!",
                firstname: "Harold",
                lastname: "Dover",
                emailAddress: "h.dover@gmail.com",
                phoneNumber: "07923335522"
            )
            .sinkToResult { [weak self] _ in
                // will now have sut.draftOrderId set
                guard let self = self else { return }
                self.sut
                    .getRealexHPPProducerData()
                    .sinkToResult { [weak self] result in
                        guard let self = self else { return }
                        switch result {
                        case let .success(resultValue):
                            XCTAssertEqual(resultValue, getRealexHPPProducerDataResult, file: #file, line: #line)
                        case let .failure(error):
                            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
                        }
                        self.mockedWebRepo.verify()
                        self.mockedDBRepo.verify()
                        exp.fulfill()
                    }
                    .store(in: &self.subscriptions)
            }
            .store(in: &subscriptions)
        
        
        wait(for: [exp], timeout: 2)
    }
    
    func test_unsuccessfulGetRealexHPPProducerData_whenNoDraftOrder_thenError() {
        
        // Configuring app prexisting states
        appState.value.userData.basket = Basket.mockedData
        appState.value.userData.selectedStore = .loaded(RetailStoreDetails.mockedData)
        
        let exp = XCTestExpectation(description: #function)
        sut
            .getRealexHPPProducerData()
            .sinkToResult { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .success(resultValue):
                    XCTFail("Unexpected result: \(resultValue)", file: #file, line: #line)
                case let .failure(error):
                    if let checkoutError = error as? CheckoutServiceError {
                        XCTAssertEqual(checkoutError, CheckoutServiceError.draftOrderRequired, file: #file, line: #line)
                    } else {
                        XCTFail("Unexpected error type: \(error)", file: #file, line: #line)
                    }
                }
                self.mockedWebRepo.verify()
                self.mockedDBRepo.verify()
                exp.fulfill()
            }
            .store(in: &subscriptions)
        
        
        wait(for: [exp], timeout: 2)
    }
    
}
