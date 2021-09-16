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

let clientId = "944d5b2d-a8d5-4fd0-ac40-91bd6cd2ad4d"
let clientSecret = "KPJQYTORajTsMJUUigX9MxtamIimNHdRNBrmKq9e"

let domain = "https://api-staging.snappyshopper.co.uk"
let authenticationURL = "/api/v2/oauth/token"

struct APIError: Decodable, Error {
    var errorCode: Int
    var errorText: String
    var errorDisplay: String
    var success: Bool
}

let authenticateURL = URL(string: domain + authenticationURL)!

// The Authenticator object is responsible for providing tokens and refreshing them.

class NetworkAuthenticator {
    
    static let shared = NetworkAuthenticator()
    
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
    
    init(accessToken: String? = nil, refreshToken: String? = nil) {
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
    
    func refreshToken<S: Subject>(using subject: S, cancellable: inout AnyCancellable?) where S.Output == Token {
    
        var requestParameters: [String: Any] = [
            "client_id": clientId,
            "client_secret": clientSecret
        ]
        
        if let refreshToken = currentToken.refreshToken {
            requestParameters["grant_type"] = "refresh_token"
            requestParameters["refresh_token"] = refreshToken
        } else {
            requestParameters["grant_type"] = "client_credentials"
            requestParameters["scope"] = "*"
        }
        
        let publisher: AnyPublisher<ApiAuthenticationResult, Error> = requestURL(
                authenticateURL,
                parameters: requestParameters
            )
            .share()
            .eraseToAnyPublisher()

        cancellable = publisher
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    subject.send(completion: Subscribers.Completion<S.Failure>.failure(error as! S.Failure))
                } else {
                    subject.send(self.currentToken)
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
    
    func signIn(with provider: String? = nil, parameters: [String: Any], withDebugTrace debugTrace: Bool = false) -> AnyPublisher<Bool, Error> {
        
        self.debugTrace = debugTrace
        
        var requestParameters: [String: Any] = [
            "client_id": clientId,
            "client_secret": clientSecret,
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
                authenticateURL,
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
    
    func tokenSubject(withDebugTrace debugTrace: Bool = false) -> CurrentValueSubject<Token, Error> {
        self.debugTrace = debugTrace
        return CurrentValueSubject(currentToken)
    }
    
    private func requestURL<T: Decodable>(_ url: URL, parameters: [String: Any]? = nil) -> AnyPublisher<T, Error> {

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = requestBodyFrom(parameters: parameters, forDebug: debugTrace)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if debugTrace {
            print("REQUEST: " + url.absoluteString)
            if
                let httpBody = request.httpBody,
                let jsonText = String(data: httpBody, encoding: String.Encoding.utf8)
            {
                print(jsonText)
            }
        }

        return URLSession.shared.dataTaskPublisher(for: request)
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
                    let apiError = try decoder.decode(APIError.self, from: result.data)
                    throw apiError
                }

                return try decoder.decode(T.self, from: result.data)

            }).eraseToAnyPublisher()
    }
    
}
