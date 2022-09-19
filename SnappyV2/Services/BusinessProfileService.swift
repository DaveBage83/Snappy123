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
    func getProfile() async throws
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
    
    init(webRepository: BusinessProfileWebRepositoryProtocol, dbRepository: BusinessProfileDBRepositoryProtocol, appState: Store<AppState>, eventLogger: EventLoggerProtocol) {
        self.webRepository = webRepository
        self.dbRepository = dbRepository
        self.appState = appState
        self.eventLogger = eventLogger
    }
    
    func getProfile() async throws {
        
        let currentLocale = AppV2Constants.Client.languageCode
        
        let profile: BusinessProfile
        do {
            profile = try await webRepository.getProfile()
        } catch {
            // falling back to any cached business profile and from here on
            // only the original web error will returned
            do {
                if
                    let cachedProfile = try await dbRepository.businessProfile(forLocaleCode: currentLocale),
                    // check that the data is not too old
                    let fetchTimestamp = cachedProfile.fetchTimestamp,
                    fetchTimestamp > AppV2Constants.Business.businessProfileCachedExpiry
                {
                    appState.value.businessData.businessProfile = cachedProfile
                    return
                }
            } catch { }
            // unsuccesful with the cached result so throw the original primary web error
            throw error
        }
        
        // got a result from the API so store it
        try await dbRepository.clearBusinessProfile(forLocaleCode: currentLocale)
        try await dbRepository.store(businessProfile: profile, forLocaleCode: currentLocale)
        appState.value.businessData.businessProfile = profile
    }
    
}

struct StubBusinessProfileService: BusinessProfileServiceProtocol {
    func getProfile() async throws { }    
}
