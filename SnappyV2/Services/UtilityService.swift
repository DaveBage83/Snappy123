//
//  UtilityService.swift
//  SnappyV2
//
//  Created by David Bage on 19/01/2022.
//

import Foundation
import Combine

enum UtilityServiceError: Swift.Error {
    case invalidParameters([String])
}

extension UtilityServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .invalidParameters(parameters):
            return "Parameters Error: \(parameters.joined(separator: ", "))"
        }
    }
}

enum MentionMeRequest: String {
    case offer
    case referee
    case dashboard
    case consumerOrder = "consumer_order"
}

protocol UtilityServiceProtocol {
    func setDeviceTimeOffset()
    func mentionMeCallHome(requestType: MentionMeRequest, businessOrderId: Int?) async throws -> MentionMeCallHomeResponse
}

class UtilityService: UtilityServiceProtocol {
    
    private let webRepository: UtilityWebRepositoryProtocol
    private let eventLogger: EventLoggerProtocol
    private var cancelBag = CancelBag()
    private let formatter = DateFormatter()
    
    init(webRepository: UtilityWebRepositoryProtocol, eventLogger: EventLoggerProtocol) {
        self.webRepository = webRepository
        self.eventLogger = eventLogger
    }
    
    func setDeviceTimeOffset() {
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        self.webRepository.getServerTime()
            .map { serverTime in
                return serverTime?.timeUTC
            }
            .map { timeUTC -> Double in
                if let timeUTC = timeUTC, let date = self.formatter.date(from: timeUTC) {
                    return date.timeIntervalSince1970 - Date().timeIntervalSince1970
                } else {
                    return 0.0
                }
            }
            .sink { completion in
                switch completion {
                case .failure(let error):
                #if DEBUG
                    print(error)
                #endif

                case .finished:
                #if DEBUG
                    print("Successfully acquired server time")
                #endif
                }
            } receiveValue: { serverTime in
                Date.deviceTimeOffset = serverTime
            }
            .store(in: self.cancelBag)
    }
    
    func mentionMeCallHome(requestType: MentionMeRequest, businessOrderId: Int?) async throws -> MentionMeCallHomeResponse {
        return try await webRepository.mentionMeCallHome(requestType: requestType, businessOrderId: businessOrderId)
    }
}

struct StubUtilityService: UtilityServiceProtocol {
    func setDeviceTimeOffset() {}
    func mentionMeCallHome(requestType: MentionMeRequest, businessOrderId: Int?) async throws -> MentionMeCallHomeResponse {
        MentionMeCallHomeResponse(
            result: ShimmedMentionMeCallHomeResponse(
                status: true,
                message: nil,
                requestURL: nil,
                request: nil,
                openInBrowser: nil,
                applyCoupon: nil,
                postMessageEvent: nil
            )
        )
    }
}

extension Date {
    fileprivate(set) static var deviceTimeOffset: Double = 0
    
    var trueDate: Date {
        let trueTimeInterval = self.timeIntervalSince1970 + Date.deviceTimeOffset
        return Date(timeIntervalSince1970: trueTimeInterval)
    }
}
