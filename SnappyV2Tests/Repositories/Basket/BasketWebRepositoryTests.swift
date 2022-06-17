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
    
    func test_getBasket_givenAllTheParameters_returnFetchedBasket() async throws {
        
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

        let result = try await sut.getBasket(
            basketToken: "8c6f3a9a1f2ffa9e93a9ec2920a4a911",
            storeId: 910,
            fulfilmentMethod: RetailStoreOrderMethodType.delivery,
            fulfilmentLocation: fulfimentLocation,
            isFirstOrder: true
        )
        
        XCTAssertEqual(result, data, file: #file, line: #line)
    }
    
    // MARK: - reserveTimeSlot(basketToken:storeId:timeSlotDate:timeSlotTime:postcode:fulfilmentMethod:)
    
    func test_reserveTimeSlot_givenAllTheParameters_returnBasket() async throws {
        
        let data = BasketSelectedSlot.mockedTodayData

        let parameters: [String: Any] = [
            "basketToken": "8c6f3a9a1f2ffa9e93a9ec2920a4a911",
            "storeId": 910,
            "timeSlotDate": "2022-02-02",
            "timeSlotTime": "10:15 - 10:30",
            "postcode": "DD2 3DB",
            "fulfilmentMethod": RetailStoreOrderMethodType.delivery
        ]

        try mock(.reserveTimeSlot(parameters), result: .success(data))

        let result = try await sut.reserveTimeSlot(
            basketToken: "8c6f3a9a1f2ffa9e93a9ec2920a4a911",
            storeId: 910,
            timeSlotDate: "2022-02-02",
            timeSlotTime: "10:15 - 10:30",
            postcode: "DD2 3DB",
            fulfilmentMethod: RetailStoreOrderMethodType.delivery
        )
        
        XCTAssertEqual(result, data, file: #file, line: #line)
    }
    
    // MARK: - addItem(basketToken:item:fulfilmentMethod:)
    
    func test_addItem_givenAllTheParameters_returnBasket() async throws {
        
        let data = Basket.mockedData
        
        let basketItemRequest = BasketItemRequest.mockedData

        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "basketToken": "8c6f3a9a1f2ffa9e93a9ec2920a4a911",
            "menuItem": basketItemRequest,
            "fulfilmentMethod": RetailStoreOrderMethodType.delivery
        ]

        try mock(.addItem(parameters), result: .success(data))

        let result = try await sut.addItem(
            basketToken: "8c6f3a9a1f2ffa9e93a9ec2920a4a911",
            item: basketItemRequest,
            fulfilmentMethod: RetailStoreOrderMethodType.delivery
        )
        
        XCTAssertEqual(result, data, file: #file, line: #line)
    }
    
    // MARK: - removeItem(basketToken:basketLineId:)
    
    func test_removeItem_givenAllTheParameters_returnBasket() async throws {
        
        let data = Basket.mockedData

        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "basketToken": "8c6f3a9a1f2ffa9e93a9ec2920a4a911",
            "basketLineId": 129
        ]

        try mock(.removeItem(parameters), result: .success(data))

        let result = try await sut.removeItem(
            basketToken: "8c6f3a9a1f2ffa9e93a9ec2920a4a911",
            basketLineId: 129
        )
        
        XCTAssertEqual(result, data, file: #file, line: #line)
    }

    // MARK: - updateItem(basketToken:basketLineId:item:)
    
    func test_updateItem_givenAllTheParameters_returnBasket() async throws {
        
        let data = Basket.mockedData
        
        let basketItemRequest = BasketItemRequest.mockedData

        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "basketToken": "8c6f3a9a1f2ffa9e93a9ec2920a4a911",
            "basketLineId": 129,
            "menuItem": basketItemRequest
        ]

        try mock(.updateItem(parameters), result: .success(data))

        let result = try await sut.updateItem(
            basketToken: "8c6f3a9a1f2ffa9e93a9ec2920a4a911",
            basketLineId: 129,
            item: basketItemRequest
        )
        
        XCTAssertEqual(result, data, file: #file, line: #line)
    }
    
    // MARK: - applyCoupon(basketToken:code:)
    
    func test_applyCoupon_givenAllTheParameters_returnBasket() async throws {
        
        let data = Basket.mockedData

        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "basketToken": "8c6f3a9a1f2ffa9e93a9ec2920a4a911",
            "coupon": "FIVE4FREE"
        ]

        try mock(.applyCoupon(parameters), result: .success(data))

        let result = try await sut.applyCoupon(
            basketToken: "8c6f3a9a1f2ffa9e93a9ec2920a4a911",
            code: "FIVE4FREE"
        )
        
        XCTAssertEqual(result, data, file: #file, line: #line)
    }
    
    // MARK: - removeCoupon(basketToken:)
    
    func test_removeCoupon_givenAllTheParameters_returnBasket() async throws {
        
        let data = Basket.mockedData

        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "basketToken": "8c6f3a9a1f2ffa9e93a9ec2920a4a911"
        ]

        try mock(.removeCoupon(parameters), result: .success(data))

        let result = try await sut.removeCoupon(
            basketToken: "8c6f3a9a1f2ffa9e93a9ec2920a4a911"
        )
        
        XCTAssertEqual(result, data, file: #file, line: #line)
    }
    
    // MARK: - clearItems(basketToken:)
    
    func test_clearItems_givenAllTheParameters_returnBasket() async throws {
        
        let data = Basket.mockedData

        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "basketToken": "8c6f3a9a1f2ffa9e93a9ec2920a4a911"
        ]

        try mock(.clearItems(parameters), result: .success(data))

        let result = try await sut.clearItems(
            basketToken: "8c6f3a9a1f2ffa9e93a9ec2920a4a911"
        )
        
        XCTAssertEqual(result, data, file: #file, line: #line)
    }
    
    // MARK: - setBillingAddress(basketToken:address:)
    
    func test_setContactDetails_givenAllTheParameters_returnBasket() async throws {
        
        let data = Basket.mockedData
        
        let basketContactDetailsRequest = BasketContactDetailsRequest.mockedData

        let parameters: [String: Any] = [
            "basketToken": "8c6f3a9a1f2ffa9e93a9ec2920a4a911",
            "firstName": basketContactDetailsRequest.firstName,
            "lastName": basketContactDetailsRequest.lastName,
            "email": basketContactDetailsRequest.email,
            "phoneNumber": basketContactDetailsRequest.telephone
        ]

        try mock(.setContactDetails(parameters), result: .success(data))

        let result = try await sut.setContactDetails(
            basketToken: "8c6f3a9a1f2ffa9e93a9ec2920a4a911",
            details: basketContactDetailsRequest
        )
        
        XCTAssertEqual(result, data, file: #file, line: #line)
    }

    // MARK: - setBillingAddress(basketToken:address:)
    
    func test_setBillingAddress_givenAllTheParameters_returnBasket() async throws {
        
        let data = Basket.mockedData
        
        let basketAddressRequest = BasketAddressRequest.mockedBillingData

        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "basketToken": "8c6f3a9a1f2ffa9e93a9ec2920a4a911",
            "address": basketAddressRequest
        ]

        try mock(.setBillingAddress(parameters), result: .success(data))

        let result = try await sut.setBillingAddress(
            basketToken: "8c6f3a9a1f2ffa9e93a9ec2920a4a911",
            address: basketAddressRequest
        )
        
        XCTAssertEqual(result, data, file: #file, line: #line)
    }
    
    // MARK: - setDeliveryAddress(basketToken:address:)
    
    func test_setDeliveryAddress_givenAllTheParameters_returnBasket() async throws {
        
        let data = Basket.mockedData
        
        let basketAddressRequest = BasketAddressRequest.mockedDeliveryData

        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "basketToken": "8c6f3a9a1f2ffa9e93a9ec2920a4a911",
            "address": basketAddressRequest
        ]

        try mock(.setDeliveryAddress(parameters), result: .success(data))

        let result = try await sut.setDeliveryAddress(
            basketToken: "8c6f3a9a1f2ffa9e93a9ec2920a4a911",
            address: basketAddressRequest
        )
        
        XCTAssertEqual(result, data, file: #file, line: #line)
    }
    
    // MARK: - updateTip(basketToken:tip:)
    
    func test_updateTip_givenAllTheParameters_returnBasket() async throws {
        
        let data = Basket.mockedData
        
        let parameters: [String: Any] = [
            "basketToken": "8c6f3a9a1f2ffa9e93a9ec2920a4a911",
            "tip": 0.5
        ]

        try mock(.updateTip(parameters), result: .success(data))

        let result = try await sut.updateTip(
            basketToken: "8c6f3a9a1f2ffa9e93a9ec2920a4a911",
            tip: 0.5
        )
            
        XCTAssertEqual(result, data, file: #file, line: #line)
    }
    
    func test_populateRepeatOrder_givenAllTheParameters_returnBasket() async throws {
        
        let data = Basket.mockedData
        
        let parameters: [String: Any] = [
            "businessId": AppV2Constants.Business.id,
            "basketToken": "8c6f3a9a1f2ffa9e93a9ec2920a4a911",
            "businessOrderId": 1670,
            "fulfilmentMethod": RetailStoreOrderMethodType.delivery
        ]

        try mock(.populateRepeatOrder(parameters), result: .success(data))

        let result = try await sut.populateRepeatOrder(
            basketToken: "8c6f3a9a1f2ffa9e93a9ec2920a4a911",
            businessOrderId: 1670,
            fulfilmentMethod: RetailStoreOrderMethodType.delivery
        )
        
        XCTAssertEqual(result, data, file: #file, line: #line)
    }
    
    // MARK: - Helper
    
    private func mock<T>(_ apiCall: API, result: Result<T, Swift.Error>) throws where T: Encodable {
        let mock = try Mock(apiCall: apiCall, baseURL: sut.baseURL, result: result)
        RequestMocking.add(mock: mock)
    }
    
}

