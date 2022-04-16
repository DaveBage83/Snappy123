//
//  BusinessProfileService.swift
//  SnappyV2
//
//  Created by Kevin Palser on 02/03/2022.
//

import Combine
import Foundation

enum BusinessProfileServiceError: Swift.Error {
    case unableToPersistResult
}

extension BusinessProfileServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .unableToPersistResult:
            return "Unable to persist web fetch result"
        }
    }
}

protocol BusinessProfileServiceProtocol {
    // Sets the business profile in the app state
    func getProfile() -> Future<Void, Error>
}

struct BusinessProfileService: BusinessProfileServiceProtocol {

    let webRepository: BusinessProfileWebRepositoryProtocol
    let dbRepository: BusinessProfileDBRepositoryProtocol
    
    // Example in the clean architecture Countries exampe of the appState
    // being passed to a service (but not used the code). Using this as
    // a justification to be an acceptable method to update the
    // BusinessProfile
    // Henrik/Kevin: 2021-10-26
    let appState: Store<AppState>
    
    let eventLogger: EventLoggerProtocol
    
    private var cancelBag = CancelBag()
    
    init(webRepository: BusinessProfileWebRepositoryProtocol, dbRepository: BusinessProfileDBRepositoryProtocol, appState: Store<AppState>, eventLogger: EventLoggerProtocol) {
        self.webRepository = webRepository
        self.dbRepository = dbRepository
        self.appState = appState
        self.eventLogger = eventLogger
    }
    
    func getProfile() -> Future<Void, Error> {
        
        return Future { promise in
            
            let currentLocale = AppV2Constants.Client.languageCode
            
            webRepository
                .getProfile()
                .sinkToResult { result in
                    switch result {
                    case let .success(webResult):
                        // got a result from the API so store it
                        dbRepository
                            // first clear any existing result
                            .clearBusinessProfile(forLocaleCode: currentLocale)
                            .sinkToResult { clearResult in
                                switch clearResult {
                                case .success:
                                    dbRepository
                                        .store(businessProfile: webResult, forLocaleCode: currentLocale)
                                        .sinkToResult { result in
                                            switch result {
                                            case let .success(savedProfile):
                                                appState.value.businessData.businessProfile = savedProfile
                                                promise(.success(()))
                                            case let .failure(storingResultError):
                                                promise(.failure(storingResultError))
                                            }
                                        }
                                        .store(in: cancelBag)
                                    
                                case let .failure(clearResultError):
                                    promise(.failure(clearResultError))
                                }
                            }
                            .store(in: cancelBag)
                        
                    case let .failure(error):
                        // bad result from the API so attempt to use
                        // cached data
                        dbRepository
                            .businessProfile(forLocaleCode: currentLocale)
                            .sinkToResult { result in
                                switch result {
                                case let .success(cachedProfile):
                                    if
                                        let cachedProfile = cachedProfile,
                                        // check that the data is not too old
                                        let fetchTimestamp = cachedProfile.fetchTimestamp,
                                        fetchTimestamp > AppV2Constants.Business.businessProfileCachedExpiry
                                    {
                                        appState.value.businessData.businessProfile = cachedProfile
                                        promise(.success(()))
                                    } else {
                                        // pass back the network error rather
                                        // than any database error
                                        promise(.failure(error))
                                    }
                                case .failure:
                                    // pass back the network error rather
                                    // than any database error
                                    promise(.failure(error))
                                }
                            }
                            .store(in: cancelBag)
                    }
                }
                .store(in: cancelBag)
        }
        
    }
    
    private var requestHoldBackTimeInterval: TimeInterval {
        return ProcessInfo.processInfo.isRunningTests ? 0 : 0.5
    }
    
}

struct StubBusinessProfileService: BusinessProfileServiceProtocol {
    
    func getProfile() -> Future<Void, Error> {
        return Future { promise in
            promise(.success(()))
        }
    }
    
}
