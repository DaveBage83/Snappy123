//
//  MemberService.swift
//  SnappyV2
//
//  Created by Kevin Palser on 16/12/2021.
//

import Combine
import Foundation

// 3rd Party
import KeychainAccess

enum MemberServiceError: Swift.Error {
    case memberRequiredToBeSignedIn
}

extension MemberServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .memberRequiredToBeSignedIn:
            return "function requires member to be signed in"
        }
    }
}

protocol MemberServiceProtocol {
    func login(email: String, password: String) -> Future<Void, Error>
    
    // methods that require a member to be signed in
    func logout() -> Future<Void, Error>
    func getProfile(profile: LoadableSubject<MemberProfile>)
}

struct MemberService: MemberServiceProtocol {

    let webRepository: MemberWebRepositoryProtocol
    let dbRepository: MemberDBRepositoryProtocol
    let appState: Store<AppState>
    
    private let keychain = Keychain(service: Bundle.main.bundleIdentifier!)
    private var cancelBag = CancelBag()
    
    init(webRepository: MemberWebRepositoryProtocol, dbRepository: MemberDBRepositoryProtocol, appState: Store<AppState>) {
        self.webRepository = webRepository
        self.dbRepository = dbRepository
        self.appState = appState
        
        appState.value.userData.memberSignedIn = keychain["memberSignedIn"] != nil
    }
    
    func login(email: String, password: String) -> Future<Void, Error> {
        return Future() { promise in

            webRepository
                .login(email: email, password: password)
                .sink(
                    receiveCompletion: { completion in

                        // Only seems to get here if there is an error

                        switch completion {

                        case .failure(let error):
                            // report the error back to the original future
                            promise(.failure(error))

                        case .finished:
                            // should no finish before receiveValue
                            promise(.success(()))

                        }

                    }, receiveValue: { _ in
                        
                        // The following is required because it does not
                        // reach the above on a finished state
                        appState.value.userData.memberSignedIn = true
                        keychain["memberSignedIn"] = "email"
                        promise(.success(()))
                    }
                )
                .store(in: cancelBag)
        }
    }
    
    func logout() -> Future<Void, Error> {
        return Future() { promise in
            
            if appState.value.userData.memberSignedIn == false {
                promise(.failure(MemberServiceError.memberRequiredToBeSignedIn))
            }
            
            webRepository
                .logout()
                .sink { completion in
                    
                    // Only seems to get here if there is an error

                    switch completion {

                    case .failure(let error):
                        // report the error back to the original future
                        promise(.failure(error))

                    case .finished:
                        // should no finish before receiveValue
                        promise(.success(()))

                    }
                    
                } receiveValue: { success in
                    if success {
                        markUserSignedOut()
                        promise(.success(()))
                    }
                }
                .store(in: cancelBag)
            
        }
    }
    
    func getProfile(profile: LoadableSubject<MemberProfile>) {
        
        let cancelBag = CancelBag()
        profile.wrappedValue.setIsLoading(cancelBag: cancelBag)
        
        if appState.value.userData.memberSignedIn == false {
            Fail(outputType: MemberProfile.self, failure: MemberServiceError.memberRequiredToBeSignedIn)
                .eraseToAnyPublisher()
                .sinkToLoadable { profile.wrappedValue = $0 }
                .store(in: cancelBag)
            return
        }
        
        webRepository
            .getProfile(storeId: appState.value.userData.selectedStore.value?.id)
            .catch({ error -> AnyPublisher<MemberProfile, Error> in
                self.checkMemberAuthenticationFailure(for: error)
                return Fail(outputType: MemberProfile.self, failure: error)
                    .eraseToAnyPublisher()
            })
            .ensureTimeSpan(requestHoldBackTimeInterval)
            .flatMap { profile -> AnyPublisher<MemberProfile, Error> in
                return dbRepository
                    .clearMemberProfile()
                    .flatMap { _ -> AnyPublisher<MemberProfile, Error> in
                        dbRepository.store(memberProfile: profile)
                    }
                    .eraseToAnyPublisher()
            }
            .sinkToLoadable { profile.wrappedValue = $0 }
            .store(in: cancelBag)
    }
    
    /// The NetworkHandler code attempts to refresh the access token. If that fails this function
    /// checks is the error was an authentication problem and if so sets the user as no longer
    /// being signed in.
    private func checkMemberAuthenticationFailure(for error: Error) {
        if
            let error = error as? APIErrorResult,
            error.errorCode == 401
        {
            markUserSignedOut()
        }
    }
    
    private func markUserSignedOut() {
        appState.value.userData.memberSignedIn = false
        keychain["memberSignedIn"] = nil
    }
    
    private var requestHoldBackTimeInterval: TimeInterval {
        return ProcessInfo.processInfo.isRunningTests ? 0 : 0.5
    }
    
}

struct StubMemberService: MemberServiceProtocol {

    func login(email: String, password: String) -> Future<Void, Error> {
        return Future { promise in
            promise(.success(()))
        }
    }
    
    func logout() -> Future<Void, Error> {
        return Future { promise in
            promise(.success(()))
        }
    }
    
    func getProfile(profile: LoadableSubject<MemberProfile>) { }
    
}
