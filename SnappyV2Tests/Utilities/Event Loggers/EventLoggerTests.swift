//
//  EventLoggerTests.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 15/04/2022.
//

import XCTest
import AppsFlyerLib
@testable import SnappyV2

class EventLoggerTests: XCTestCase {
    
    func test_withoutSelectedStore_includesNoStoreInfo() {
        
        let appState = Store<AppState>(AppState())
        
        let givenParameters: [String : Any] = [
            "number": 123,
            "name": "test"
        ]
        
        var defaultParameters: [String : Any] = [
            "store_id": 0,
            "platform": AppV2Constants.Client.platform,
        ]
        if let bundleNumber: Any = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") {
            defaultParameters["app_version"] = "\(bundleNumber)"
        }
        let expectedParameters = givenParameters.merging(defaultParameters) { (_, new) in new }
    
        let sut = EventLogger(appState: appState)
        let result = sut.exposeAddDefaultParameters(to: givenParameters)
        
        XCTAssertTrue(result.isEqual(to: expectedParameters))
    }
    
    func test_withSelectedStore_includesStoreInfo() {
        
        let store = RetailStoreDetails.mockedData
        
        let appState = Store<AppState>(AppState())
        appState.value.userData.selectedStore = .loaded(store)
        
        let givenParameters: [String : Any] = [
            "number": 123,
            "name": "test"
        ]
        
        var defaultParameters: [String : Any] = [
            "store_id": store.id,
            "store_name": store.storeName,
            "platform": AppV2Constants.Client.platform,
        ]
        if let bundleNumber: Any = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") {
            defaultParameters["app_version"] = "\(bundleNumber)"
        }
        let expectedParameters = givenParameters.merging(defaultParameters) { (_, new) in new }
        
        let sut = EventLogger(appState: appState)
        let result = sut.exposeAddDefaultParameters(to: givenParameters)
        
        XCTAssertTrue(result.isEqual(to: expectedParameters))
    }
    
    func test_whenSetCustomerID_thenCuidIsSetInAppsFlyerLib() {
        let sut = makeSUT()
        let uuid = UUID().uuidString
        
        sut.setCustomerID(profileUUID: uuid)
        
        XCTAssertEqual(AppsFlyerLib.shared().customerUserID, uuid)
    }
    
    func test_givenAppsFlyerCuidSet_whenClearCustomerIDTriggered_thenAppsFlyerCuidIsNil() {
        let sut = makeSUT()
        let uuid = UUID().uuidString
        AppsFlyerLib.shared().customerUserID = uuid
        
        sut.clearCustomerID()
        
        XCTAssertNil(AppsFlyerLib.shared().customerUserID)
    }
    
    func makeSUT(appState: AppState = AppState()) -> EventLogger {
        let sut = EventLogger(appState: Store<AppState>(appState))
        
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
