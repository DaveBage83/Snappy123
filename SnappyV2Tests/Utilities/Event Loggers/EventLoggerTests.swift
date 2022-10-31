//
//  EventLoggerTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 15/04/2022.
//

import XCTest

// 3rd party
import AppsFlyerLib
import Firebase

@testable import SnappyV2

class EventLoggerTests: XCTestCase {
    
    func test_withoutSelectedStore_includesNoStoreInfo() {

        let givenParameters: [String : Any] = [
            "number": 123,
            "name": "test"
        ]
        
        var defaultParameters: [String : Any] = [
            "store_id": 0,
            "platform": AppV2Constants.Client.platform,
        ]
        if let appVersion = AppV2Constants.Client.appVersion {
            defaultParameters["app_version"] = appVersion
        }
        let expectedParameters = givenParameters.merging(defaultParameters) { (_, new) in new }
    
        let sut = makeSUT()
        let result = sut.exposeAddDefaultParameters(to: givenParameters)
        
        XCTAssertTrue(result.isEqual(to: expectedParameters), file: #file, line: #line)
    }
    
    func test_withSelectedStore_includesStoreInfo() {
        
        let store = RetailStoreDetails.mockedData
        
        var appState = AppState()
        appState.userData.selectedStore = .loaded(store)
        
        let givenParameters: [String : Any] = [
            "number": 123,
            "name": "test"
        ]
        
        var defaultParameters: [String : Any] = [
            "store_id": store.id,
            "store_name": store.storeName,
            "platform": AppV2Constants.Client.platform,
        ]
        if let appVersion = AppV2Constants.Client.appVersion {
            defaultParameters["app_version"] = appVersion
        }
        let expectedParameters = givenParameters.merging(defaultParameters) { (_, new) in new }
        
        let sut = makeSUT(appState: appState)
        let result = sut.exposeAddDefaultParameters(to: givenParameters)
        
        XCTAssertTrue(result.isEqual(to: expectedParameters), file: #file, line: #line)
    }
    
    func test_whenSetCustomerID_thenCuidIsSetInAppsFlyerLib() {
        let sut = makeSUT()
        let uuid = UUID().uuidString
        
        sut.setCustomerID(profileUUID: uuid)
        
        XCTAssertEqual(AppsFlyerLib.shared().customerUserID, uuid, file: #file, line: #line)
    }
    
    func test_givenAppsFlyerCuidSet_whenClearCustomerIDTriggered_thenAppsFlyerCuidIsNil() {
        let sut = makeSUT()
        let uuid = UUID().uuidString
        AppsFlyerLib.shared().customerUserID = uuid
        
        sut.clearCustomerID()
        
        XCTAssertNil(AppsFlyerLib.shared().customerUserID, file: #file, line: #line)
    }
    
    func test_getFirebaseItemsArray_givenBasketItemsArray_returnFirebaseItemsArray() {
        let basketItem = BasketItem.mockedDataComplex
        
        var item: [String: Any] = [
            AnalyticsParameterItemID: AppV2Constants.EventsLogging.analyticsItemIdPrefix + "\(basketItem.menuItem.id)",
            AnalyticsParameterItemName: basketItem.menuItem.name,
            AnalyticsParameterPrice: NSDecimalNumber(value: basketItem.price).rounding(accordingToBehavior: EventLogger.decimalBehavior).doubleValue,
            AnalyticsParameterQuantity: basketItem.quantity
        ]
        if let size = basketItem.size {
            item[AnalyticsParameterItemVariant] = AppV2Constants.EventsLogging.analticsSizeIdPrefix + "\(size.id)"
        }
        
        // no "sut" instance because of the static function being tested
        
        let firebaseItemsArray = EventLogger.getFirebaseItemsArray(from: [basketItem])
        
        // cannot use XCTAssertEqual because of the "Any" in the dictionary despite trying:
        //extension Array {
        //    static func == (lhs: Array<[String : Any]>, rhs: Array<[String : Any]>) -> Bool {
        //        guard lhs.count == rhs.count else { return false }
        //        for (index, entry) in lhs.enumerated() {
        //            if entry.isEqual(to: rhs[index]) == false {
        //                return false
        //            }
        //        }
        //        return true
        //    }
        //}
        
        XCTAssertTrue(firebaseItemsArray.first!.isEqual(to: item), file: #file, line: #line)
    }
    
    func test_createParamsArrayString_givenSomeJSON_returnCensoredString() {
        
        let parameters: [String: Any] = [
            "password": "password123",
            "username": "username",
            "emailAddress": "test@test.com",
            "mobileContactNumber": "07956212272",
            "example1": 1,
            "example2": "2"
        ]
        
        // cannot test against a fixed result string because disctionaries loose
        // the insertion order
        let expectedValues = [
            "password:*censored*",
            "username:*censored*",
            "emailAddress:test@test.com",
            "mobileContactNumber:07956212272",
            "example1:1",
            "example2:2"
        ]
        
        do {
            let data = try requestBodyFrom(parameters: parameters)
            // no "sut" instance because of the static function being tested
            let paramsString = EventLogger.createParamsArrayString(httpBody: data)
            for value in expectedValues {
                XCTAssertTrue(paramsString.contains(value), file: #file, line: #line)
            }
        } catch {
            XCTFail("Unexpected error: \(error)", file: #file, line: #line)
        }
    }
    
    func test_createParamsArrayString_givenBodyThatCannotBeConverted_returnEmptyString() {
        
        // no "sut" instance because of the static function being tested
        
        let paramsStringFromNil = EventLogger.createParamsArrayString(httpBody: nil)
        XCTAssertEqual(paramsStringFromNil, "", file: #file, line: #line)
        
        let paramsStringFromNotJSON = EventLogger.createParamsArrayString(httpBody: Data("not JSON".utf8))
        XCTAssertEqual(paramsStringFromNotJSON, "", file: #file, line: #line)
    }
    
    func makeSUT(webRepository: EventLoggerWebRepositoryProtocol = MockedEventLoggerWebRepository(), appState: AppState = AppState()) -> EventLogger {
        let sut = EventLogger(webRepository: webRepository, appState: Store<AppState>(appState))
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
