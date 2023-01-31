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

// The APIErrorResult is Codable instead of Decodable to facilitate testing
struct APIErrorResult: Codable, Error, Equatable {

    var errorCode: Int
    var errorText: String
    var errorTitle: String?
    var errorDisplay: String
    
    /*
    // Kevin Palser - 2022-04-26: The following is commented out for time being
    // because the backend team are debating whether the metaData should ever
    // interpret the metaData for production logic. Plus currently there are
    // examples of null being returned within the array.
    
    var metaData: [String: Any]?
    
    enum CodingKeys: String, CodingKey {
        case errorCode
        case errorText
        case errorDisplay
        case success
        case metaData
    }
    
    // the following is required because of the Any in fields
    
    static func == (lhs: APIErrorResult, rhs: APIErrorResult) -> Bool {
        
        var metaDataMatch = true
        if lhs.metaData != nil || rhs.metaData != nil {
            if
                let lhsMetaData = lhs.metaData,
                let rhsMetaData = rhs.metaData
            {
                metaDataMatch = lhsMetaData.isEqual(to: rhsMetaData)
            } else {
                metaDataMatch = false
            }
        }
        
        return metaDataMatch && lhs.errorCode == rhs.errorCode && lhs.errorText == rhs.errorText && lhs.errorDisplay == rhs.errorDisplay && lhs.success == rhs.success
    }
    
    init (from decoder: Decoder) throws {
        let container =  try decoder.container(keyedBy: CodingKeys.self)
        errorCode = try container.decode(Int.self, forKey: .errorCode)
        errorText = try container.decode(String.self, forKey: .errorText)
        errorDisplay = try container.decode(String.self, forKey: .errorDisplay)
        success = try container.decode(Bool.self, forKey: .success)
        metaData = try container.decodeIfPresent([String: Any].self, forKey: .metaData)
    }
    
    func encode (to encoder: Encoder) throws {
        var container = encoder.container (keyedBy: CodingKeys.self)
        try container.encode(errorCode, forKey: .errorCode)
        try container.encode(errorText, forKey: .errorText)
        try container.encode(errorDisplay, forKey: .errorDisplay)
        try container.encode(success, forKey: .success)
        try container.encodeIfPresent(metaData, forKey: .metaData)
    }
    
     init(errorCode: Int, errorText: String, errorDisplay: String, success: Bool, metaData: [String: Any]?) {
        self.errorCode = errorCode
        self.errorText = errorText
        self.errorDisplay = errorDisplay
        self.success = success
        self.metaData = metaData
    }
    */
}

// Avoid the "The operation couldn’t be completed. (SnappyV2.APIErrorResult error 1.)"
// default because APIErrorResult.errorDisplay will always be more specific and
// user-friendly.
extension APIErrorResult: LocalizedError {
    var errorDescription: String? {
        return errorDisplay
    }
}

enum NetworkAuthenticatorError: Swift.Error {
    case selfError
    case passwordReset
    case unknown
}

extension NetworkAuthenticatorError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .selfError:
            return Strings.NetworkAuthenticator.Errors.unableToUnwrapSelf.localized
        case .passwordReset:
            return Strings.NetworkAuthenticator.Errors.passwordResetFailure.localized
        case .unknown:
            return Strings.NetworkAuthenticator.Errors.unknown.localized
        }
    }
}

struct ApiAuthenticationResult: Codable, Equatable {
    var token_type: String
    var expires_in: Int
    var access_token: String
    var refresh_token: String?
    
    // Messed up - trying to get backend to rething having this here and
    // place within the LoginResult struct
    var newMemberRegistered: Bool?
}

// The Authenticator object is responsible for providing tokens and refreshing them.

class NetworkAuthenticator {
    
    static let shared = NetworkAuthenticator()
    
    private let authenticationURL: URL
    private let signOutURL: URL
    private let resetPasswordURL: URL
    
    private let accessTokenKey = "accessToken"
    private let refreshTokenKey = "refreshToken"
    
    private let apiErrorEventHandler: ([String : Any]) -> Void
    
    private let keychain = Keychain(service: Bundle.main.bundleIdentifier!)
    
    private(set) var currentToken: Token
    private var debugTrace: Bool = false
    
    /// The Token object is a simple object that I defined to easily fake an expired token
    struct Token {
        let accessToken: String?
        let refreshToken: String?
    }
    
    struct ApiSignOutResult: Decodable {
        var success: Bool
    }
    
    struct ApiResetPasswordAndSignInResult: Decodable {
        var success: Bool
        var token: ApiAuthenticationResult?
    }
    
    init(
        authenticateURL: URL = URL(string: AppV2Constants.API.baseURL + AppV2Constants.API.authenticationURL)!,
        signOutURL: URL = URL(string: AppV2Constants.API.baseURL + AppV2Constants.API.signOutURL)!,
        resetPasswordURL: URL = URL(string: AppV2Constants.API.baseURL + AppV2Constants.API.resetPasswordURL)!,
        accessToken: String? = nil,
        refreshToken: String? = nil,
        apiErrorEventHandler: @escaping ([String : Any]) -> Void = { _ in }
    ) {
        
        self.authenticationURL = authenticateURL
        self.signOutURL = signOutURL
        self.resetPasswordURL = resetPasswordURL
        
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
        
        self.apiErrorEventHandler = apiErrorEventHandler
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
                        // Note: No point attempting event sending if self is unavailable
                        subject.send(completion: Subscribers.Completion<S.Failure>.failure(NetworkAuthenticatorError.unknown as! S.Failure))
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
                            
                            self.apiErrorEventHandler(
                                [
                                    "url" : self.authenticationURL.absoluteString,
                                    "error": error.localizedDescription
                                ]
                            )
                            
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
        
        return publisher.flatMap({ [weak self] authenticationResult -> AnyPublisher<Bool, Error> in
            guard let self = self else {
                // Note: No point attempting event sending if self is unavailable
                return Fail<Bool, Error>(error: NetworkAuthenticatorError.selfError).eraseToAnyPublisher()
            }
            self.setAccessToken(to: authenticationResult)
            return Just(true)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
            
        }).eraseToAnyPublisher()
        
    }
    
    func resetPasswordAndSignIn(connectionTimeout: TimeInterval, parameters: [String: Any], withDebugTrace debugTrace: Bool = false) -> AnyPublisher<Bool, Error> {
        
        self.debugTrace = debugTrace
        
        var requestParameters: [String: Any] = [
            "client_id": AppV2Constants.API.clientId,
            "client_secret": AppV2Constants.API.clientSecret,
            "grant_type": "password",
            "scope": "*"
        ]
        
        // merge the parameters into the request replacing any of the existing
        // entries with new values
        requestParameters = requestParameters.merging(parameters) { (_, new) in new }
        
        let publisher: AnyPublisher<ApiResetPasswordAndSignInResult, Error> = requestURL(
                resetPasswordURL,
                connectionTimeout: connectionTimeout,
                parameters: requestParameters,
                includeAccessToken: true
            )
            .share()
            .eraseToAnyPublisher()
        
        return publisher.flatMap({ [weak self] resetAndAuthenticationResult -> AnyPublisher<Bool, Error> in
            guard let self = self else {
                // Note: No point attempting event sending if self is unavailable
                return Fail<Bool, Error>(error: NetworkAuthenticatorError.selfError).eraseToAnyPublisher()
            }
            if
                let token = resetAndAuthenticationResult.token,
                resetAndAuthenticationResult.success
            {
                self.setAccessToken(to: token)
                return Just(true)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            
            return Fail<Bool, Error>(error: NetworkAuthenticatorError.passwordReset).eraseToAnyPublisher()
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
        // total time allowed for the request - can includes pauses
        config.timeoutIntervalForResource = connectionTimeout + 2
        // maxiumum time allowed with no data being returned
        config.timeoutIntervalForRequest = connectionTimeout
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        
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
            .mapError { [weak self] error in
                // raw network error
                self?.apiErrorEventHandler(
                    [
                        "url" : request.url?.absoluteString ?? "unknown",
                        "error": error.localizedDescription,
                        "request_params": EventLogger.createParamsArrayString(httpBody: request.httpBody)
                    ]
                )
                return error as Error
            }
            .tryMap({ [weak self] result in
                guard let self = self else {
                    // Note: No point attempting event sending if self is unavailable
                    throw NetworkAuthenticatorError.selfError
                }
                
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
                    do {
                        let apiError = try decoder.decode(APIErrorResult.self, from: result.data)
                        self.apiErrorEventHandler(
                            [
                                "url" : self.authenticationURL.absoluteString,
                                "error": apiError.errorDisplay
                            ]
                        )
                        throw apiError
                    } catch {
                        self.apiErrorEventHandler(
                            [
                                "url" : self.authenticationURL.absoluteString,
                                "error": error.localizedDescription
                            ]
                        )
                        throw error
                    }
                }
                
                // The standard localizedDescription is too vague:
                // https://stackoverflow.com/questions/46959625/the-data-couldn-t-be-read-because-it-is-missing-error-when-decoding-json-in-sw/53231548
                let jsonError: Error
                
                do {
                    return try decoder.decode(T.self, from: result.data)
                } catch let DecodingError.dataCorrupted(context) {
                    jsonError = APIError.jsonDecoding(context.debugDescription)
                } catch let DecodingError.keyNotFound(key, context) {
                    let description = "Key '\(key)' not found: \(context.debugDescription) codingPath: \(context.codingPath)"
                    jsonError = APIError.jsonDecoding(description)
                } catch let DecodingError.valueNotFound(value, context) {
                    let description = "Value '\(value)' not found: \(context.debugDescription) codingPath: \(context.codingPath)"
                    jsonError = APIError.jsonDecoding(description)
                } catch let DecodingError.typeMismatch(type, context)  {
                    let description = "Type '\(type)' mismatch: \(context.debugDescription) codingPath: \(context.codingPath)"
                    jsonError = APIError.jsonDecoding(description)
                } catch {
                    jsonError = APIError.jsonDecoding(error.localizedDescription)
                }
                     
                if self.debugTrace {
                    print(jsonError.localizedDescription)
                }
                
                self.apiErrorEventHandler(
                    [
                        "url" : request.url?.absoluteString ?? "unknown",
                        "error": "unable to decode JSON",
                        "response": jsonError.localizedDescription
                    ]
                )
                     
                throw jsonError
            }).eraseToAnyPublisher()
    }
    
    func setAccessToken(to token: ApiAuthenticationResult) {
        self.keychain[self.accessTokenKey] = token.access_token
        self.keychain[self.refreshTokenKey] = token.refresh_token
        self.currentToken = Token(
            accessToken: token.access_token,
            refreshToken: token.refresh_token
        )
    }
    
    func flushAccessTokens() {
        keychain[accessTokenKey] = nil
        keychain[refreshTokenKey] = nil
    }
    
}
