//
//  NetworkHandler.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 16/09/2021.
//

import Combine
import Foundation

enum NetworkHandlerError: Swift.Error {
    case couldNotDecodeToData
}

extension NetworkHandlerError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .couldNotDecodeToData:
            return "Ordering did not return Data"
        }
    }
}

// The UserApi is the object that will make authenticated network requests.

struct NetworkHandler {
    
    private let authenticator: NetworkAuthenticator
    private let urlSessionConfiguration: URLSessionConfiguration
    let debugTrace: Bool
    private let apiErrorEventHandler: ([String : Any]) -> Void
        
    init(
        authenticator: NetworkAuthenticator,
        urlSessionConfiguration: URLSessionConfiguration = .default,
        debugTrace: Bool = false,
        apiErrorEventHandler: @escaping ([String : Any]) -> Void)
    {
        self.authenticator = authenticator
        self.urlSessionConfiguration = urlSessionConfiguration
        self.debugTrace = debugTrace
        self.apiErrorEventHandler = apiErrorEventHandler
    }

    func request<T: Decodable>(for request: URLRequest, dateDecoding: JSONDecoder.DateDecodingStrategy = AppV2Constants.API.defaultTimeDecodingStrategy) -> AnyPublisher<T, Error> {
        
        let tokenSubject = authenticator.tokenSubject(withDebugTrace: debugTrace)
        var authenticationCancellable: AnyCancellable?
        
        return tokenSubject
            .flatMap({ (token, priorStatusCode) -> AnyPublisher<T, Error> in
                
                if let accessToken = token.accessToken {
                    
                    // flatMap over the CurrentValueSubject to kick off a network call whenever we receive a token
                    
                    return createDataPublisher(for: request, accessToken: accessToken)
                        .mapError {
                            // raw network error
                            apiErrorEventHandler(
                                [
                                    "url" : request.url?.absoluteString ?? "unknown",
                                    "error": $0.localizedDescription,
                                    "request_params": EventLogger.createParamsArrayString(httpBody: request.httpBody)
                                ]
                            )
                            return $0 as Error
                        }
                        .flatMap({ result -> AnyPublisher<T, Error> in
                            
                            if debugTrace {
                                print("RESULT: " + (request.url?.absoluteString ?? "NO URL"))
                            }
                            
                            if let errorPublisher: AnyPublisher<T, Error> = self.checkResultStatus(
                                for: result,
                                from: request,
                                token: token,
                                subject: tokenSubject,
                                connectionTimeout: request.timeoutInterval,
                                cancellable: { $0(&authenticationCancellable) }
                            ) {
                                return errorPublisher
                            }
                            
                            if T.self is Data.Type {
                                
                                // when the result is raw data
                                if let data = result.data as? T {
                                    return Just(data)
                                        .setFailureType(to: Error.self)
                                        .eraseToAnyPublisher()
                                } else {
                                    apiErrorEventHandler(
                                        [
                                            "url" : request.url?.absoluteString ?? "unknown",
                                            "error": "unable to decode Data",
                                            "request_params": EventLogger.createParamsArrayString(httpBody: request.httpBody)
                                        ]
                                    )
                                    return Fail(outputType: T.self, failure: NetworkHandlerError.couldNotDecodeToData)
                                        .eraseToAnyPublisher()
                                }
                                
                            } else {
                            
                                // when the result is a model
                                let decoder = JSONDecoder()
                                decoder.dateDecodingStrategy = dateDecoding
                                
                                // The standard localizedDescription is too vague:
                                // https://stackoverflow.com/questions/46959625/the-data-couldn-t-be-read-because-it-is-missing-error-when-decoding-json-in-sw/53231548
                                let jsonError: Error
                                
                                do {
                                    let model = try decoder.decode(T.self, from: result.data)
                                    return Just(model)
                                        .setFailureType(to: Error.self)
                                        .eraseToAnyPublisher()
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
                                     
                                if debugTrace {
                                    print(jsonError.localizedDescription)
                                }
                                
                                apiErrorEventHandler(
                                    [
                                        "url" : request.url?.absoluteString ?? "unknown",
                                        "error": "unable to decode JSON",
                                        "response": jsonError.localizedDescription,
                                        "request_params": EventLogger.createParamsArrayString(httpBody: request.httpBody)
                                    ]
                                )
                                     
                                return Fail(outputType: T.self, failure: jsonError)
                                    .eraseToAnyPublisher()
                                
                            }
                                 
                        })
                        .eraseToAnyPublisher()
                
                } else {
                    // starting with no access token so we need aquire one
                    self.authenticator.refreshToken(
                        using: tokenSubject,
                        connectionTimeout: request.timeoutInterval,
                        cancellable: { $0(&authenticationCancellable) }
                    )
                    return Empty().eraseToAnyPublisher()
                }
            })
            .handleEvents(receiveOutput: { _ in
                tokenSubject.send(completion: .finished)
            }, receiveCancel: {
                authenticationCancellable?.cancel()
            })
            .eraseToAnyPublisher()
    }
    
    func request(for request: URLRequest) -> AnyPublisher<Data, Error> {
        
        let tokenSubject = authenticator.tokenSubject(withDebugTrace: debugTrace)
        var authenticationCancellable: AnyCancellable?
        
        return tokenSubject
            .flatMap({ (token, priorStatusCode) -> AnyPublisher<Data, Error> in
                
                if let accessToken = token.accessToken {
                    
                    // flatMap over the CurrentValueSubject to kick off a network call whenever we receive a token
                    
                    return createDataPublisher(for: request, accessToken: accessToken)
                        .mapError {
                            // raw network error
                            apiErrorEventHandler(
                                [
                                    "url" : request.url?.absoluteString ?? "unknown",
                                    "error": $0.localizedDescription,
                                    "request_params": EventLogger.createParamsArrayString(httpBody: request.httpBody)
                                ]
                            )
                            return $0 as Error
                        }
                        .flatMap({ result -> AnyPublisher<Data, Error> in
                            
                            if debugTrace {
                                print("RESULT: " + (request.url?.absoluteString ?? "NO URL"))
                            }
                            
                            if let errorPublisher: AnyPublisher<Data, Error> = self.checkResultStatus(
                                for: result,
                                from: request,
                                token: token,
                                subject: tokenSubject,
                                connectionTimeout: request.timeoutInterval,
                                cancellable: { $0(&authenticationCancellable) }
                            ) {
                                return errorPublisher
                            }
                            
                            return Just(result.data)
                                .setFailureType(to: Error.self)
                                .eraseToAnyPublisher()
                        })
                        .eraseToAnyPublisher()
                
                } else {
                    // starting with no access token so we need aquire one
                    self.authenticator.refreshToken(
                        using: tokenSubject,
                        connectionTimeout: request.timeoutInterval,
                        cancellable: { $0(&authenticationCancellable) }
                    )
                    return Empty().eraseToAnyPublisher()
                }
            })
            .handleEvents(receiveOutput: { _ in
                tokenSubject.send(completion: .finished)
            }, receiveCancel: {
                authenticationCancellable?.cancel()
            })
            .eraseToAnyPublisher()
    }
    
    private func createDataPublisher(for parameterRequest: URLRequest, accessToken: String) -> URLSession.DataTaskPublisher {
        
        var request = parameterRequest
        
        let config = urlSessionConfiguration
        let bearerString = "Bearer " + accessToken
        
        // https://ampersandsoftworks.com/posts/bearer-authentication-nsurlsession/
        request.setValue(bearerString, forHTTPHeaderField: "Authentication")
        config.httpAdditionalHeaders = ["Authorization" : bearerString]
        
        // just in case this starts failing for because Apple decides to remove
        // the above workaround
        request.setValue(bearerString, forHTTPHeaderField: "Alt-Bearer")
        
        if debugTrace {
            print("REQUEST: " + (request.url?.absoluteString ?? "NO URL"))
            if
                let httpBody = request.httpBody,
                let jsonText = String(data: httpBody, encoding: String.Encoding.utf8)
            {
                print(jsonText)
            }
            print("Access Token: " + accessToken)
        }
        
        return URLSession(configuration: config).dataTaskPublisher(for: request)
    }
    
    private func checkResultStatus<T>(
        for result: URLSession.DataTaskPublisher.Output,
        from request: URLRequest,
        token: NetworkAuthenticator.Token, subject: CurrentValueSubject<(NetworkAuthenticator.Token, Int?), Error>,
        connectionTimeout: TimeInterval,
        cancellable: @escaping ((inout AnyCancellable?) -> Void) -> Void
    ) -> AnyPublisher<T, Error>? {
        
        if debugTrace {
            //print("RESULT: " + url.absoluteString)
            if
                let object = try? JSONSerialization.jsonObject(with: result.data, options: []),
                let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
                let jsonText = String(data: data, encoding: String.Encoding.utf8)
            {
                print(jsonText)
            }
        }
        
        if let httpResponse = result.response as? HTTPURLResponse {
            
            if debugTrace {
                print("Status Code: \(httpResponse.statusCode)")
            }
            
            // 401 can be returned when either:
            // - no valid client access token was passed, or
            // - the end point requires a member authenticated access token
            
            // The subject.value.1 (priorStatusCode) prevents an infinite
            // loop of self.authenticator.refreshToken(...) after an
            // "Unauthenticated" access error

            if httpResponse.statusCode != subject.value.1 && (httpResponse.statusCode == 401 || (httpResponse.statusCode == 400 && token.refreshToken != nil)) {
            
                // If the result of the data task that’s created in this flatMap has a 401 status code,
                // we do not want to forward this value to subscribers. Instead, we want to pretend we
                // never received this value and kick off a token refresh and subsequently retry the
                // network request.
                self.authenticator.refreshToken(
                    using: subject,
                    priorStatusCode: httpResponse.statusCode,
                    connectionTimeout: connectionTimeout,
                    cancellable: cancellable
                )
                return Empty().eraseToAnyPublisher()
                
            } else if (200...299).contains(httpResponse.statusCode) == false {
                
                let decoder = JSONDecoder()
                
                if let apiError = try? decoder.decode(APIErrorResult.self, from: result.data) {
                    
                    apiErrorEventHandler(
                        [
                            "url" : result.response.url?.absoluteString ?? "unknown",
                            "error": apiError.errorDisplay,
                            "request_params": EventLogger.createParamsArrayString(httpBody: request.httpBody)
                        ]
                    )
                    
                    return Fail(outputType: T.self, failure: apiError)
                        .eraseToAnyPublisher()
                }
            }
        }
        
        return nil
    }
    
    // a convenience wrapper that can also set the debug trace
    func signIn(with provider: String? = nil, connectionTimeout: TimeInterval = AppV2Constants.API.connectionTimeout, parameters: [String: Any]) -> AnyPublisher<Bool, Error> {
        return authenticator.signIn(
            with: provider,
            connectionTimeout: connectionTimeout,
            parameters: parameters,
            withDebugTrace: debugTrace
        )
    }
    
    func signOut(connectionTimeout: TimeInterval = AppV2Constants.API.connectionTimeout, parameters: [String: Any]) -> AnyPublisher<Bool, Error> {
        return authenticator.signOut(
            connectionTimeout: connectionTimeout,
            parameters: parameters,
            withDebugTrace: debugTrace
        )
    }
    
    func flushAccessTokens() {
        authenticator.flushAccessTokens()
    }
    
    func setAccessToken(to token: ApiAuthenticationResult) {
        authenticator.setAccessToken(to: token)
    }
    
}
