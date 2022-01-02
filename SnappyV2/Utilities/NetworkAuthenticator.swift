//
//  NetworkAuthenticator.swift
//  NetworkAuthenticatorClass
//
//  Created by Kevin Palser on 02/09/2021.
//

import Foundation
import Combine

// 3rd party
import KeychainAccess

struct APIErrorResult: Decodable, Error {
    var errorCode: Int
    var errorText: String
    var errorDisplay: String
    var success: Bool
}

enum NetworkAuthenticatorError: Swift.Error {
    case unkown
}

extension NetworkAuthenticatorError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .unkown:
            return "Internal error in NetworkAuthenticator"
        }
    }
}

// The Authenticator object is responsible for providing tokens and refreshing them.

class NetworkAuthenticator {
    
    static let shared = NetworkAuthenticator()
    
    private let authenticationURL: URL
    private let signOutURL: URL
    
    private let accessTokenKey = "accessToken"
    private let refreshTokenKey = "refreshToken"
    
    private let keychain = Keychain(service: Bundle.main.bundleIdentifier!)
    
    private var currentToken: Token
    private var debugTrace: Bool = false
    
    /// The Token object is a simple object that I defined to easily fake an expired token
    struct Token {
        let accessToken: String?
        let refreshToken: String?
    }
    
    struct ApiAuthenticationResult: Decodable {
        var token_type: String
        var expires_in: Int
        var access_token: String
        var refresh_token: String?
    }
    
    struct ApiSignOutResult: Decodable {
        var success: Bool
    }
    
    init(
        authenticateURL: URL = URL(string: AppV2Constants.API.baseURL + AppV2Constants.API.authenticationURL)!,
        signOutURL: URL = URL(string: AppV2Constants.API.baseURL + AppV2Constants.API.signOutURL)!,
        accessToken: String? = nil,
        refreshToken: String? = nil
    ) {
        
        self.authenticationURL = authenticateURL
        self.signOutURL = signOutURL
        
        if let accessToken = accessToken {
            // use a specified access token and save it persistently
            keychain[accessTokenKey] = accessToken
            if let refreshToken = refreshToken {
                keychain[refreshTokenKey] = refreshToken
            }
            currentToken = Token(
                accessToken: accessToken,
                refreshToken: refreshToken
            )
        } else {
            // use the persistent access token
            currentToken = Token(
                accessToken: keychain[accessTokenKey],
                refreshToken: keychain[refreshTokenKey]
            )
        }
    }
    
    func refreshToken<S: Subject>(
        using subject: S,
        priorStatusCode: Int? = nil,
        connectionTimeout: TimeInterval,
        cancellable: @escaping ((inout AnyCancellable?) -> Void) -> Void
    ) where S.Output == (Token, Int?) {
    
        var requestParameters: [String: Any] = [
            "client_id": AppV2Constants.API.clientId,
            "client_secret": AppV2Constants.API.clientSecret
        ]
        
        if let refreshToken = currentToken.refreshToken {
            requestParameters["grant_type"] = "refresh_token"
            requestParameters["refresh_token"] = refreshToken
        } else {
            requestParameters["grant_type"] = "client_credentials"
            requestParameters["scope"] = "*"
        }
        
        let publisher: AnyPublisher<ApiAuthenticationResult, Error> = requestURL(
                authenticationURL,
                connectionTimeout: connectionTimeout,
                parameters: requestParameters
            )
            .share()
            .eraseToAnyPublisher()

        cancellable { cancellableValue in
            cancellableValue = publisher
                .sink(receiveCompletion: { [weak self] completion in
                    guard let self = self else {
                        subject.send(completion: Subscribers.Completion<S.Failure>.failure(NetworkAuthenticatorError.unkown as! S.Failure))
                        return
                    }
                    if case .failure(let error) = completion {
                        if error is APIErrorResult && self.currentToken.refreshToken != nil {
                            // the attempt with the refresh token failed so
                            // clear the refresh token and recursively call
                            // this function to get a standard refresh token
                            self.keychain[self.refreshTokenKey] = nil
                            self.currentToken = Token(
                                accessToken: nil,
                                refreshToken: nil
                            )
                            
                            self.refreshToken(
                                using: subject,
                                connectionTimeout:connectionTimeout,
                                cancellable: cancellable
                            )
                            
                        } else {
                            subject.send(completion: Subscribers.Completion<S.Failure>.failure(error as! S.Failure))
                        }
                    } else {
                        subject.send((self.currentToken, priorStatusCode))
                    }
                }, receiveValue: { (result: ApiAuthenticationResult) in
                    self.keychain[self.accessTokenKey] = result.access_token
                    self.keychain[self.refreshTokenKey] = result.refresh_token
                    self.currentToken = Token(
                        accessToken: result.access_token,
                        refreshToken: result.refresh_token
                    )
                })/*.store(in: &cancellables)*/
        }
    }
    
    func signIn(with provider: String? = nil, connectionTimeout: TimeInterval, parameters: [String: Any], withDebugTrace debugTrace: Bool = false) -> AnyPublisher<Bool, Error> {
        
        self.debugTrace = debugTrace
        
        var requestParameters: [String: Any] = [
            "client_id": AppV2Constants.API.clientId,
            "client_secret": AppV2Constants.API.clientSecret,
            "scope": "*"
        ]
        
        if let provider = provider {
            requestParameters["provider"] = provider
            requestParameters["grant_type"] = "custom_request"
        } else {
            requestParameters["grant_type"] = "password"
        }
        
        // merge the parameters into the request replacing any of the existing
        // entries with new values
        requestParameters = requestParameters.merging(parameters) { (_, new) in new }
        
        let publisher: AnyPublisher<ApiAuthenticationResult, Error> = requestURL(
                authenticationURL,
                connectionTimeout: connectionTimeout,
                parameters: requestParameters
            )
            .share()
            .eraseToAnyPublisher()
        
        return publisher.flatMap({ authenticationResult -> AnyPublisher<Bool, Error> in
            
            self.keychain[self.accessTokenKey] = authenticationResult.access_token
            self.keychain[self.refreshTokenKey] = authenticationResult.refresh_token
            
            return Just(true)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
            
        }).eraseToAnyPublisher()
        
    }
    
    func signOut(connectionTimeout: TimeInterval, parameters requestParameters: [String: Any], withDebugTrace debugTrace: Bool = false)  -> AnyPublisher<Bool, Error> {
        
        self.debugTrace = debugTrace

        let publisher: AnyPublisher<ApiSignOutResult, Error> = requestURL(
                signOutURL,
                connectionTimeout: connectionTimeout,
                parameters: requestParameters,
                includeAccessToken: true
            )
            .share()
            .eraseToAnyPublisher()
        
        return publisher.flatMap({ signOutResult -> AnyPublisher<Bool, Error> in
            
            if signOutResult.success {
                self.keychain[self.accessTokenKey] = nil
                self.keychain[self.refreshTokenKey] = nil
            }
            
            return Just(true)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
            
        }).eraseToAnyPublisher()
        
    }
    
    func tokenSubject(withDebugTrace debugTrace: Bool = false) -> CurrentValueSubject<(Token, Int?), Error> {
        self.debugTrace = debugTrace
        return CurrentValueSubject((currentToken, nil))
    }
    
    private func requestURL<T: Decodable>(_ url: URL, connectionTimeout: TimeInterval, parameters: [String: Any]?, includeAccessToken: Bool = false) -> AnyPublisher<T, Error> {

        let config = URLSessionConfiguration.default
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = connectionTimeout
        
        do {
            request.httpBody = try requestBodyFrom(parameters: parameters, forDebug: debugTrace)
        } catch {
            return Fail<T, Error>(error: APIError.parameterEncoding(error.localizedDescription)).eraseToAnyPublisher()
        }
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if
            includeAccessToken,
            let accessToken = self.keychain[self.accessTokenKey]
        {
            let bearerString = "Bearer " + accessToken
            
            // https://ampersandsoftworks.com/posts/bearer-authentication-nsurlsession/
            request.setValue(bearerString, forHTTPHeaderField: "Authentication")
            config.httpAdditionalHeaders = ["Authorization" : bearerString]
            
            // just in case this starts failing for because Apple decides to remove
            // the above workaround
            request.setValue(bearerString, forHTTPHeaderField: "Alt-Bearer")
        }
        
        if debugTrace {
            print("REQUEST: " + url.absoluteString)
            if
                let httpBody = request.httpBody,
                let jsonText = String(data: httpBody, encoding: String.Encoding.utf8)
            {
                print(jsonText)
            }
            if
                includeAccessToken,
                let accessToken = self.keychain[self.accessTokenKey]
            {
                print("Access Token: " + accessToken)
            }
        }

        return URLSession(configuration: config).dataTaskPublisher(for: request)
            .mapError({ $0 as Error })
            .tryMap({ result in

                if self.debugTrace {
                    print("RESULT: " + url.absoluteString)
                    if
                        let object = try? JSONSerialization.jsonObject(with: result.data, options: []),
                        let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
                        let jsonText = String(data: data, encoding: String.Encoding.utf8)
                    {
                        print(jsonText)
                    }
                }

                let decoder = JSONDecoder()

                guard
                    let urlResponse = result.response as? HTTPURLResponse,
                    (200...299).contains(urlResponse.statusCode)
                else {
                    let apiError = try decoder.decode(APIErrorResult.self, from: result.data)
                    throw apiError
                }

                return try decoder.decode(T.self, from: result.data)

            }).eraseToAnyPublisher()
    }
    
}
