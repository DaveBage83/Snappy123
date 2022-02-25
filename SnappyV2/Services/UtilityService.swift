//
//  UtilityService.swift
//  SnappyV2
//
//  Created by David Bage on 19/01/2022.
//

import Foundation
import Combine

protocol UtilityServiceProtocol {
    func setDeviceTimeOffset()
}

struct TrueTime: Codable, Equatable {
    let timeUTC: String
}

class UtilityService: UtilityServiceProtocol {
    
    private let webRepository: UtilityWebRepositoryProtocol
    private var cancelBag = CancelBag()
    private let formatter = DateFormatter()
    
    init(webRepository: UtilityWebRepositoryProtocol) {
        self.webRepository = webRepository
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
}

struct StubUtilityService: UtilityServiceProtocol {
    func setDeviceTimeOffset() {}
}

extension Date {
    fileprivate(set) static var deviceTimeOffset: Double = 0
    
    var trueDate: Date {
        let trueTimeInterval = Date().timeIntervalSince1970 + Date.deviceTimeOffset
        return Date(timeIntervalSince1970: trueTimeInterval)
    }
}
