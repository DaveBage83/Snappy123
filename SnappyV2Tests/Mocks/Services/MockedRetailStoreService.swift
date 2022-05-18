//
//  MockedRetailStoreService.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 19/12/2021.
//

import XCTest
import Combine
import CoreLocation
@testable import SnappyV2

struct MockedRetailStoreService: Mock, RetailStoresServiceProtocol {

    enum Action: Equatable {
        case repeatLastSearch
        case searchRetailStores(postcode: String)
        case searchRetailStores(location: CLLocationCoordinate2D)
        case getStoreDetails(storeId: Int, postcode: String)
        case getStoreDeliveryTimeSlots(storeId: Int, startDate: Date, endDate: Date, location: CLLocationCoordinate2D)
        case getStoreCollectionTimeSlots(storeId: Int, startDate: Date, endDate: Date)
        case futureContactRequest(email: String)
    }
    
    let actions: MockActions<Action>
    
    init(expected: [Action]) {
        self.actions = .init(expected: expected)
    }
    
    func repeatLastSearch() async throws {
        register(.repeatLastSearch)
    }
    
    func searchRetailStores(postcode: String) -> Future<Void, Error> {
        register(.searchRetailStores(postcode: postcode))
        return Future { $0(.success(())) }
    }
    
    func searchRetailStores(location: CLLocationCoordinate2D) -> Future<Void, Error> {
        register(.searchRetailStores(location: location))
        return Future { $0(.success(())) }
    }
    
    func getStoreDetails(storeId: Int, postcode: String) -> Future<Void, Error> {
        register(.getStoreDetails(storeId: storeId, postcode: postcode))
        return Future { $0(.success(())) }
    }
    
    func getStoreDeliveryTimeSlots(slots: LoadableSubject<RetailStoreTimeSlots>, storeId: Int, startDate: Date, endDate: Date, location: CLLocationCoordinate2D) {
        register(.getStoreDeliveryTimeSlots(storeId: storeId, startDate: startDate, endDate: endDate, location: location))
    }
    
    func getStoreCollectionTimeSlots(slots: LoadableSubject<RetailStoreTimeSlots>, storeId: Int, startDate: Date, endDate: Date) {
        register(.getStoreCollectionTimeSlots(storeId: storeId, startDate: startDate, endDate: endDate))
    }
    
    func futureContactRequest(email: String) async throws -> String? {
        register(.futureContactRequest(email: email))
        return nil
    }
}
