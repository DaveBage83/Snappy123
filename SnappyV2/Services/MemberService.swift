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
                        appState.value.userData.memberSignedIn = false
                        keychain["memberSignedIn"] = nil
                        promise(.success(()))
                    }
                }
                .store(in: cancelBag)
            
        }
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
    
}
