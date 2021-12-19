//
//  MemberService.swift
//  SnappyV2
//
//  Created by Kevin Palser on 16/12/2021.
//

import Combine
import Foundation

protocol MemberServiceProtocol {
    func login(email: String, password: String) -> Future<Void, Error>
}

struct MemberService: MemberServiceProtocol {

    let webRepository: MemberWebRepositoryProtocol
    let dbRepository: MemberDBRepositoryProtocol
    let appState: Store<AppState>
    
    private var cancelBag = CancelBag()
    
    init(webRepository: MemberWebRepositoryProtocol, dbRepository: MemberDBRepositoryProtocol, appState: Store<AppState>) {
        self.webRepository = webRepository
        self.dbRepository = dbRepository
        self.appState = appState
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
                            // re-queue this request for after the change
                            promise(.success(()))

                        }

                    }, receiveValue: { _ in
                        
                        // The following is required because it does not
                        // reach the above on a finished state
                        appState.value.userData.memberSignedIn = true
                        promise(.success(()))
                    }
                )
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
    
}
