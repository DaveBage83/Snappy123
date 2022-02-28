//
//  MockedUserService.swift
//  SnappyV2Tests
//
//  Created by Kevin Palser on 19/12/2021.
//

import XCTest
import Combine
@testable import SnappyV2

struct MockedUserService: Mock, UserServiceProtocol {
    
    enum Action: Equatable {
        case login(email: String, password: String)
        case logout
        case getProfile
        case getPastOrders(dateFrom: String?, dateTo: String?, status: String?, page: Int?, limit: Int?)
        case getMarketingOptions(isCheckout: Bool, notificationsEnabled: Bool)
        case updateMarketingOptions(options: [UserMarketingOptionRequest])
    }
    
    let actions: MockActions<Action>
    
    init(expected: [Action]) {
        self.actions = .init(expected: expected)
    }
    
    func login(email: String, password: String) -> Future<Void, Error> {
        register(.login(email: email, password: password))
        return Future { $0(.success(())) }
    }
    
    func logout() -> Future<Void, Error> {
        register(.logout)
        return Future { $0(.success(())) }
    }
    
    func getProfile(profile: LoadableSubject<MemberProfile>) {
        register(.getProfile)
    }
    
    func getPastOrders(pastOrders: LoadableSubject<[PastOrder]?>, dateFrom: String?, dateTo: String?, status: String?, page: Int?, limit: Int?) {
        register(.getPastOrders(dateFrom: dateFrom, dateTo: dateTo, status: status, page: page, limit: limit))
    }
    
    func getMarketingOptions(options: LoadableSubject<UserMarketingOptionsFetch>, isCheckout: Bool, notificationsEnabled: Bool) {
        register(.getMarketingOptions(isCheckout: isCheckout, notificationsEnabled: notificationsEnabled))
    }
    
    func updateMarketingOptions(result: LoadableSubject<UserMarketingOptionsUpdateResponse>, options: [UserMarketingOptionRequest]) {
        register(.updateMarketingOptions(options: options))
    }
    
}
