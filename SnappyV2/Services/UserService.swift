//
//  UserService.swift
//  SnappyV2
//
//  Created by Kevin Palser on 16/12/2021.
//

import Combine
import Foundation

// 3rd Party
import KeychainAccess

enum UserServiceError: Swift.Error {
    case memberRequiredToBeSignedIn
    case unableToPersistResult
    case unableToProceedWithoutBasket
}

extension UserServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .memberRequiredToBeSignedIn:
            return "function requires member to be signed in"
        case .unableToPersistResult:
            return "Unable to persist web fetch result"
        case .unableToProceedWithoutBasket:
            return "Unable to proceed because of missing basket information"
        }
    }
}

protocol UserServiceProtocol {
    func login(email: String, password: String) -> Future<Void, Error>
    // methods that require a member to be signed in
    func logout() -> Future<Void, Error>
    func getProfile(profile: LoadableSubject<MemberProfile>)
    func addAddress(profile: LoadableSubject<MemberProfile>, address: Address)
    func removeAddress(profile: LoadableSubject<MemberProfile>, addressId: Int)
    func getPastOrders(pastOrders: LoadableSubject<[PastOrder]?>, dateFrom: String?, dateTo: String?, status: String?, page: Int?, limit: Int?)
    // methods where a signed in user is optional
    func getMarketingOptions(options: LoadableSubject<UserMarketingOptionsFetch>, isCheckout: Bool, notificationsEnabled: Bool)
    func updateMarketingOptions(result: LoadableSubject<UserMarketingOptionsUpdateResponse>, options: [UserMarketingOptionRequest])
}

struct UserService: UserServiceProtocol {

    let webRepository: UserWebRepositoryProtocol
    let dbRepository: UserDBRepositoryProtocol
    let appState: Store<AppState>
    
    private let keychain = Keychain(service: Bundle.main.bundleIdentifier!)
    private var cancelBag = CancelBag()
    
    init(webRepository: UserWebRepositoryProtocol, dbRepository: UserDBRepositoryProtocol, appState: Store<AppState>) {
        self.webRepository = webRepository
        self.dbRepository = dbRepository
        self.appState = appState
        
        appState.value.userData.memberSignedIn = keychain["memberSignedIn"] != nil
    }
    
    func login(email: String, password: String) -> Future<Void, Error> {
        return Future() { promise in

            webRepository
                .login(email: email, password: password)
                .flatMap({ success -> AnyPublisher<Bool, Error> in
                    if success {
                        return clearAllMarketingOptions(passThrough: success)
                    } else {
                        return Just<Bool>.withErrorType(success, Error.self)
                    }
                })
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
                promise(.failure(UserServiceError.memberRequiredToBeSignedIn))
                return
            }
            
            webRepository
                .logout()
                .catch({ error -> AnyPublisher<Bool, Error> in
                    return checkMemberAuthenticationFailure(for: error)
                })
                .flatMap({ success -> AnyPublisher<Bool, Error> in
                    if success {
                        //return clearAllMarketingOptions(passThrough: success)
                        return clearMemberProfile(passThrough: success)
                            .flatMap { _ -> AnyPublisher<Bool, Error> in
                                return clearAllMarketingOptions(passThrough: success)
                            }
                            .eraseToAnyPublisher()
                        
                    } else {
                        return Just<Bool>.withErrorType(success, Error.self)
                    }
                })
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
            Fail(outputType: MemberProfile.self, failure: UserServiceError.memberRequiredToBeSignedIn)
                .eraseToAnyPublisher()
                .sinkToLoadable { profile.wrappedValue = $0 }
                .store(in: cancelBag)
            return
        }
        
        webRepository
            .getProfile(storeId: appState.value.userData.selectedStore.value?.id)
            .catch({ error -> AnyPublisher<MemberProfile, Error> in
                return checkMemberAuthenticationFailure(for: error)
            })
            .ensureTimeSpan(requestHoldBackTimeInterval)
            // convert the result to include a Bool indicating the
            // source of the data
            .flatMap({ memberResult -> AnyPublisher<(Bool, MemberProfile), Error> in
                return Just<(Bool, MemberProfile)>.withErrorType((true, memberResult), Error.self)
            })
            .catch({ error in
                // failed to fetch from the API so try to get a
                // result from the persistent store
                return dbRepository
                    .memberProfile()
                    .flatMap { memberResult -> AnyPublisher<(Bool, MemberProfile), Error> in
                        if
                            let memberResult = memberResult,
                            // check that the data is not too old
                            let fetchTimestamp = memberResult.fetchTimestamp,
                            fetchTimestamp > AppV2Constants.Business.userCachedExpiry
                        {
                            return Just<(Bool, MemberProfile)>.withErrorType((false, memberResult), Error.self)
                        } else {
                            return Fail(outputType: (Bool, MemberProfile).self, failure: error)
                                .eraseToAnyPublisher()
                        }
                    }
            })
            .flatMap({ (fromWeb, profile) -> AnyPublisher<MemberProfile, Error> in
                if fromWeb {
                    // need to remove the previous result in the
                    // database and store a new value
                    return dbRepository
                        .clearMemberProfile()
                        .flatMap { _ -> AnyPublisher<MemberProfile, Error> in
                            dbRepository
                                .store(memberProfile: profile)
                                .eraseToAnyPublisher()
                        }
                        .eraseToAnyPublisher()
                } else {
                    return Just<MemberProfile>.withErrorType(profile, Error.self)
                }
            })
            .eraseToAnyPublisher()
            .sinkToLoadable { profile.wrappedValue = $0 }
            .store(in: cancelBag)
    }
    
    private func processMemberProfilePublisher(publisher: AnyPublisher<MemberProfile, Error>, profile: LoadableSubject<MemberProfile>) {
        publisher
            .catch({ error -> AnyPublisher<MemberProfile, Error> in
                return checkMemberAuthenticationFailure(for: error)
            })
            .flatMap({ profile -> AnyPublisher<MemberProfile, Error> in
                // need to remove the previous result in the
                // database and store a new value
                return dbRepository
                    .clearMemberProfile()
                    .flatMap { _ -> AnyPublisher<MemberProfile, Error> in
                        dbRepository
                            .store(memberProfile: profile)
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
            .sinkToLoadable { profile.wrappedValue = $0 }
            .store(in: cancelBag)
    }
    
    func addAddress(profile: LoadableSubject<MemberProfile>, address: Address) {
        
        let cancelBag = CancelBag()
        profile.wrappedValue.setIsLoading(cancelBag: cancelBag)
        
        if appState.value.userData.memberSignedIn == false {
            Fail(outputType: MemberProfile.self, failure: UserServiceError.memberRequiredToBeSignedIn)
                .eraseToAnyPublisher()
                .sinkToLoadable { profile.wrappedValue = $0 }
                .store(in: cancelBag)
            return
        }
        
        processMemberProfilePublisher(
            publisher: webRepository.addAddress(storeId: appState.value.userData.selectedStore.value?.id, address: address),
            profile: profile
        )
    }
    
    func removeAddress(profile: LoadableSubject<MemberProfile>, addressId: Int) {
        
        let cancelBag = CancelBag()
        profile.wrappedValue.setIsLoading(cancelBag: cancelBag)
        
        if appState.value.userData.memberSignedIn == false {
            Fail(outputType: MemberProfile.self, failure: UserServiceError.memberRequiredToBeSignedIn)
                .eraseToAnyPublisher()
                .sinkToLoadable { profile.wrappedValue = $0 }
                .store(in: cancelBag)
            return
        }
        
        processMemberProfilePublisher(
            publisher: webRepository.removeAddress(storeId: appState.value.userData.selectedStore.value?.id, addressId: addressId),
            profile: profile
        )
    }
    
    func getPastOrders(pastOrders: LoadableSubject<[PastOrder]?>, dateFrom: String?, dateTo: String?, status: String?, page: Int?, limit: Int?) {
        
        let cancelBag = CancelBag()
        pastOrders.wrappedValue.setIsLoading(cancelBag: cancelBag)
        
        if appState.value.userData.memberSignedIn == false {
            Fail(outputType: [PastOrder]?.self, failure: UserServiceError.memberRequiredToBeSignedIn)
                .eraseToAnyPublisher()
                .sinkToLoadable { pastOrders.wrappedValue = $0 }
                .store(in: cancelBag)
            return
        }
        
        webRepository
            .getPastOrders(dateFrom: dateFrom, dateTo: dateTo, status: status, page: page, limit: limit)
            .catch({ error -> AnyPublisher<[PastOrder]?, Error> in
                return checkMemberAuthenticationFailure(for: error)
            })
            .ensureTimeSpan(requestHoldBackTimeInterval)
            // convert the result to include a Bool indicating the
            // source of the data
//            .flatMap({ pastOrdersResult -> AnyPublisher<(Bool, [PastOrder]?), Error> in
//                return Just<(Bool, [PastOrder]?)>.withErrorType((true, pastOrdersResult), Error.self)
//            })
//            .catch({ error in
//                // failed to fetch from the API so try to get a
//                // result from the persistent store
//                return dbRepository
//                    .memberProfile()
//                    .flatMap { memberResult -> AnyPublisher<(Bool, MemberProfile), Error> in
//                        if
//                            let memberResult = memberResult,
//                            // check that the data is not too old
//                            let fetchTimestamp = memberResult.fetchTimestamp,
//                            fetchTimestamp > AppV2Constants.Business.userCachedExpiry
//                        {
//                            return Just<(Bool, MemberProfile)>.withErrorType((false, memberResult), Error.self)
//                        } else {
//                            return Fail(outputType: (Bool, MemberProfile).self, failure: error)
//                                .eraseToAnyPublisher()
//                        }
//                    }
//            })
//            .flatMap({ (fromWeb, profile) -> AnyPublisher<MemberProfile, Error> in
//                if fromWeb {
//                    // need to remove the previous result in the
//                    // database and store a new value
//                    return dbRepository
//                        .clearMemberProfile()
//                        .flatMap { _ -> AnyPublisher<MemberProfile, Error> in
//                            dbRepository
//                                .store(memberProfile: profile)
//                                .eraseToAnyPublisher()
//                        }
//                        .eraseToAnyPublisher()
//                } else {
//                    return Just<MemberProfile>.withErrorType(profile, Error.self)
//                }
//            })
            .eraseToAnyPublisher()
            .sinkToLoadable { pastOrders.wrappedValue = $0 }
            .store(in: cancelBag)
    }
    
    func getMarketingOptions(options: LoadableSubject<UserMarketingOptionsFetch>, isCheckout: Bool, notificationsEnabled: Bool) {
        
        let cancelBag = CancelBag()
        options.wrappedValue.setIsLoading(cancelBag: cancelBag)
        
        var basketToken: String?
        if isCheckout {
            // Basket token is required if the member is not signed in because the
            // server is recording marketing options for that specific order.
            // Otherwise it should not be passed because it is against their member
            // preferences.
            if appState.value.userData.memberSignedIn == false {
                if let currentBasketToken = appState.value.userData.basket?.basketToken {
                    basketToken = currentBasketToken
                }
            }
            // for isCheckout a basket should always exist even if not passed
            // as a request value
            if appState.value.userData.basket?.basketToken == nil {
                Fail(outputType: UserMarketingOptionsFetch.self, failure: UserServiceError.unableToProceedWithoutBasket)
                    .eraseToAnyPublisher()
                    .sinkToLoadable { options.wrappedValue = $0 }
                    .store(in: cancelBag)
                return
            }
        } else if appState.value.userData.memberSignedIn == false {
            // the user should be signed in when not fetching options for checkout
            Fail(outputType: UserMarketingOptionsFetch.self, failure: UserServiceError.memberRequiredToBeSignedIn)
                .eraseToAnyPublisher()
                .sinkToLoadable { options.wrappedValue = $0 }
                .store(in: cancelBag)
            return
        }
        
        webRepository
            .getMarketingOptions(isCheckout: isCheckout, notificationsEnabled: notificationsEnabled, basketToken: basketToken)
            .ensureTimeSpan(requestHoldBackTimeInterval)
            // convert the result to include a Bool indicating the
            // source of the data
            .flatMap({ optionsResult -> AnyPublisher<(Bool, UserMarketingOptionsFetch), Error> in
                return Just<(Bool, UserMarketingOptionsFetch)>.withErrorType((true, optionsResult), Error.self)
            })
            .catch({ error in
                // failed to fetch from the API so try to get a
                // result from the persistent store
                return dbRepository
                    .userMarketingOptionsFetch(
                        isCheckout: isCheckout,
                        notificationsEnabled: notificationsEnabled,
                        basketToken: basketToken
                    )
                    .flatMap { optionsResult -> AnyPublisher<(Bool, UserMarketingOptionsFetch), Error> in
                        if
                            let optionsResult = optionsResult,
                            // check that the data is not too old
                            let fetchTimestamp = optionsResult.fetchTimestamp,
                            fetchTimestamp > AppV2Constants.Business.userCachedExpiry
                        {
                            return Just<(Bool, UserMarketingOptionsFetch)>.withErrorType((false, optionsResult), Error.self)
                        } else {
                            return Fail(outputType: (Bool, UserMarketingOptionsFetch).self, failure: error)
                                .eraseToAnyPublisher()
                        }
                    }
            })
            .flatMap({ (fromWeb, fetch) -> AnyPublisher<UserMarketingOptionsFetch, Error> in
                if fromWeb {
                    // need to remove the previous result in the
                    // database and store a new value
                    return dbRepository
                        .clearFetchedUserMarketingOptions(
                            isCheckout: isCheckout,
                            notificationsEnabled: notificationsEnabled,
                            basketToken: basketToken
                        )
                        .flatMap { _ -> AnyPublisher<UserMarketingOptionsFetch, Error> in
                            dbRepository
                                .store(
                                    marketingOptionsFetch: fetch,
                                    isCheckout: isCheckout,
                                    notificationsEnabled: notificationsEnabled,
                                    basketToken: basketToken
                                )
                                .eraseToAnyPublisher()
                        }
                        .eraseToAnyPublisher()
                } else {
                    return Just<UserMarketingOptionsFetch>.withErrorType(fetch, Error.self)
                }
            })
            .eraseToAnyPublisher()
            //.receive(on: RunLoop.main)
            .sinkToLoadable { options.wrappedValue = $0 }
            .store(in: cancelBag)
        
    }
    
    func updateMarketingOptions(result: LoadableSubject<UserMarketingOptionsUpdateResponse>, options: [UserMarketingOptionRequest]) {
        let cancelBag = CancelBag()
        result.wrappedValue.setIsLoading(cancelBag: cancelBag)
        
        // Only need the basket token if the user is not signed in
        var basketToken: String?
        if !appState.value.userData.memberSignedIn {
            if let currentBasketToken = appState.value.userData.basket?.basketToken {
                basketToken = currentBasketToken
            } else {
                Fail(outputType: UserMarketingOptionsUpdateResponse.self, failure: UserServiceError.unableToProceedWithoutBasket)
                    .eraseToAnyPublisher()
                    .sinkToLoadable { result.wrappedValue = $0 }
                    .store(in: cancelBag)
                return
            }
        }
        
        webRepository
            .updateMarketingOptions(options: options, basketToken: basketToken)
            .flatMap({ result -> AnyPublisher<UserMarketingOptionsUpdateResponse, Error> in
                // we could try to do something clever like update the cached
                // values but since they are only used as a fallback if there
                // is a network problem this can be left as low priority future
                // extension
                return clearAllMarketingOptions(passThrough: result)
            })
            .eraseToAnyPublisher()
            .sinkToLoadable { result.wrappedValue = $0 }
            .store(in: cancelBag)
    }
    
    /// Intended for when a member status changes (login/logout) or the member privileges of
    /// the access token fail
    private func clearMemberProfile<T>(passThrough: T) -> AnyPublisher<T, Error> {
        return dbRepository
            .clearMemberProfile()
            .flatMap { _ -> AnyPublisher<T, Error> in
                return Just(passThrough)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    /// Intended for when a member status changes (login/logout) or the member privileges of
    /// the access token fail
    private func clearAllMarketingOptions<T>(passThrough: T) -> AnyPublisher<T, Error> {
        return dbRepository
            .clearAllFetchedUserMarketingOptions()
            .flatMap { _ -> AnyPublisher<T, Error> in
                return Just(passThrough)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    /// The NetworkHandler code attempts to refresh the access token. If that fails this function
    /// checks is the error was an authentication problem and if so sets the user as no longer
    /// being signed in.
    private func checkMemberAuthenticationFailure<T>(for error: Error) -> AnyPublisher<T, Error> {
        if
            let error = error as? APIErrorResult,
            error.errorCode == 401
        {
            markUserSignedOut()
            return
                clearMemberProfile(passThrough: error)
                .flatMap({ errorValue -> AnyPublisher<T, Error> in
                    return clearAllMarketingOptions(passThrough: error)
                        .flatMap({ errorValue -> AnyPublisher<T, Error> in
                            return Fail(outputType: T.self, failure: errorValue)
                                .eraseToAnyPublisher()
                        })
                        .eraseToAnyPublisher()
                })
                .eraseToAnyPublisher()
        }
        return Fail(outputType: T.self, failure: error)
            .eraseToAnyPublisher()
    }
    
    private func markUserSignedOut() {
        appState.value.userData.memberSignedIn = false
        keychain["memberSignedIn"] = nil
    }
    
    private var requestHoldBackTimeInterval: TimeInterval {
        return ProcessInfo.processInfo.isRunningTests ? 0 : 0.5
    }
    
}

struct StubUserService: UserServiceProtocol {

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
    
    func addAddress(profile: LoadableSubject<MemberProfile>, address: Address) { }
    
    func removeAddress(profile: LoadableSubject<MemberProfile>, addressId: Int) { }
    
    func getMarketingOptions(options: LoadableSubject<UserMarketingOptionsFetch>, isCheckout: Bool, notificationsEnabled: Bool) { }
    
    func updateMarketingOptions(result: LoadableSubject<UserMarketingOptionsUpdateResponse>, options: [UserMarketingOptionRequest]) { }
    
    func getPastOrders(pastOrders: LoadableSubject<[PastOrder]?>, dateFrom: String?, dateTo: String?, status: String?, page: Int?, limit: Int?) { }
    
}
