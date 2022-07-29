//
//  StoreCardInfoViewModelTests.swift
//  SnappyV2Tests
//
//  Created by Henrik Gustavii on 03/10/2021.
//

import XCTest
@testable import SnappyV2

class StoreCardInfoViewModelTests: XCTestCase {

    func test_init() {
        let sut = makeSUT(storeDetails: storeInit)
        
        XCTAssertEqual(sut.distance, "0")
        XCTAssertEqual(sut.deliveryChargeString, "")
        XCTAssertEqual(sut.storeDetails.storeName, "Most Basic Store Ever")
    }
    
    func test_given4DecimalDistance_thenConvertedTo2DecimalString() {
        let storeDetails = RetailStore(id: 1, storeName: "Slightly Better Store", distance: 3.9638, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, ratings: nil, currency: RetailStoreCurrency.mockedGBPData)
        let sut = makeSUT(storeDetails: storeDetails)
        
        XCTAssertEqual(sut.distance, "3.96")
    }
    
    func test_givenDeliveryOrderMethodWithNoCharge_thenFreeDeliveryString() {
        let deliveryMethod = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: 0, fulfilmentIn: nil)
        let storeDetails = RetailStore(id: 1, storeName: "Slightly Better Store", distance: 3.9638, storeLogo: nil, storeProductTypes: nil, orderMethods: ["delivery": deliveryMethod], ratings: nil, currency: RetailStoreCurrency.mockedGBPData)
        let sut = makeSUT(storeDetails: storeDetails)
        
        XCTAssertEqual(sut.deliveryChargeString, "Free delivery")
    }
    
    func test_givenDeliveryOrderMethodWithCharge_thenCorrectDeliveryString() {
        let deliveryMethod = RetailStoreOrderMethod(name: .delivery, earliestTime: nil, status: .open, cost: 3.5, fulfilmentIn: nil)
        let storeDetails = RetailStore(id: 1, storeName: "Slightly Better Store", distance: 3.9638, storeLogo: nil, storeProductTypes: nil, orderMethods: ["delivery": deliveryMethod], ratings: nil, currency: RetailStoreCurrency.mockedGBPData)
        let sut = makeSUT(storeDetails: storeDetails)
        
        XCTAssertEqual(sut.deliveryChargeString, "£3.50 delivery")
    }
   
    func makeSUT(storeDetails: RetailStore) -> StoreCardInfoViewModel {
        let sut = StoreCardInfoViewModel(container: .preview, storeDetails: storeDetails)
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
    
    let storeInit = RetailStore(id: 1, storeName: "Most Basic Store Ever", distance: 0, storeLogo: nil, storeProductTypes: nil, orderMethods: nil, ratings: nil, currency: RetailStoreCurrency.mockedGBPData)

}
