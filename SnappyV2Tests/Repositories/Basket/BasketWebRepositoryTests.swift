//
//  BasketWebRepositoryTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 30/01/2022.
//

import XCTest
import Combine
@testable import SnappyV2

final class BasketWebRepositoryTests: XCTestCase {
    
    private var sut: BasketWebRepository!
    private var subscriptions = Set<AnyCancellable>()
    
    typealias API = BasketWebRepository.API
    typealias Mock = RequestMocking.MockedResponse

    override func setUp() {
        subscriptions = Set<AnyCancellable>()
        sut = BasketWebRepository(
            networkHandler: .mockedResponsesOnly,
            baseURL: "https://test.com/"
        )
    }

    override func tearDown() {
        RequestMocking.removeAllMocks()
    }
    
    // MARK: - getBasket(basketToken:storeId:fulfilmentMethod:fulfilmentLocation:isFirstOrder:)
    
    func test_findAddresses_givenValidPostcode_returnFetchedAddresses() throws {
        
        let data = Basket.mockedData
        let fulfimentLocation = FulfilmentLocation(
            country: "GB",
            latitude: 56.473358599999997,
            longitude: -3.0111853000000002,
            postcode: "DD2 3DB"
        )
        
        let parameters: [String: Any] = [
            "storeId": 910,
            "fulfilmentMethod": data.fulfilmentMethod.type,
            "businessId": AppV2Constants.Business.id,
            "isFirstOrder": true,
            "basketToken": "8c6f3a9a1f2ffa9e93a9ec2920a4a911"
        ]
        
        try mock(.getBasket(parameters), result: .success(data))
        let exp = XCTestExpectation(description: "Completion")

        sut.getBasket(
            basketToken: "8c6f3a9a1f2ffa9e93a9ec2920a4a911",
            storeId: 910,
            fulfilmentMethod: RetailStoreOrderMethodType.delivery,
            fulfilmentLocation: fulfimentLocation,
            isFirstOrder: true
        ).sinkToResult { result in
            result.assertSuccess(value: data)
            exp.fulfill()
        }.store(in: &subscriptions)

        wait(for: [exp], timeout: 2)
    }
    
    // used to fetch or create new baskets and change the fulfilmentMethod
//    func getBasket(
//        basketToken: String?,
//        storeId: Int,
//        fulfilmentMethod: RetailStoreOrderMethodType,
//        fulfilmentLocation: FulfilmentLocation?,
//        isFirstOrder: Bool
//    ) -> AnyPublisher<Basket, Error>
    
    // MARK: - reserveTimeSlot(basketToken:storeId:timeSlotDate:timeSlotTime:postcode:fulfilmentMethod:)
    
    //func reserveTimeSlot(basketToken: String, storeId: Int, timeSlotDate: String, timeSlotTime: String?, postcode: String,  fulfilmentMethod: RetailStoreOrderMethodType) -> AnyPublisher<Basket, Error>
    
    // MARK: - addItem(basketToken:item:fulfilmentMethod:)
    
    // func addItem(basketToken: String, item: BasketItemRequest, fulfilmentMethod: RetailStoreOrderMethodType) -> AnyPublisher<Basket, Error>
    
    // MARK: - removeItem(basketToken:basketLineId:)
    
    // func removeItem(basketToken: String, basketLineId: Int) -> AnyPublisher<Basket, Error>
    
    // MARK: - updateItem(basketToken:basketLineId:item:)
    
    // func updateItem(basketToken: String, basketLineId: Int, item: BasketItemRequest) -> AnyPublisher<Basket, Error>
    
    // MARK: - applyCoupon(basketToken:code:)
    
    // func applyCoupon(basketToken: String, code: String) -> AnyPublisher<Basket, Error>
    
    // MARK: - removeCoupon(basketToken:)
    
    // func removeCoupon(basketToken: String) -> AnyPublisher<Basket, Error>
    
    // MARK: - clearItems(basketToken:)
    
    // func clearItems(basketToken: String) -> AnyPublisher<Basket, Error>
    
    // MARK: - setBillingAddress(basketToken:address:)
    
    // func setBillingAddress(basketToken: String, address: BasketAddressRequest) -> AnyPublisher<Basket, Error>
    
    // MARK: - setDeliveryAddress(basketToken:address:)
    
    // func setDeliveryAddress(basketToken: String, address: BasketAddressRequest) -> AnyPublisher<Basket, Error>
    
    
    // MARK: - Helper
    
    private func mock<T>(_ apiCall: API, result: Result<T, Swift.Error>) throws where T: Encodable {
        let mock = try Mock(apiCall: apiCall, baseURL: sut.baseURL, result: result)
        RequestMocking.add(mock: mock)
    }
    
}

