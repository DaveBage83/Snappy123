//
//  NetworkHandler.swift
//  SnappyV2
//
//  Created by Henrik Gustavii on 16/09/2021.
//

import Combine
import Foundation

// The UserApi is the object that will make authenticated network requests.

struct NetworkHandler {
    
    private let authenticator: NetworkAuthenticator
    private let urlSessionConfiguration: URLSessionConfiguration
    let debugTrace: Bool
        
    init(authenticator: NetworkAuthenticator, urlSessionConfiguration: URLSessionConfiguration = .default, debugTrace: Bool = false) {
        self.authenticator = authenticator
        self.urlSessionConfiguration = urlSessionConfiguration
        self.debugTrace = debugTrace
    }

    func request<T: Decodable>(for request: URLRequest, dateDecoding: JSONDecoder.DateDecodingStrategy = AppV2Constants.API.defaultTimeDecodingStrategy) -> AnyPublisher<T, Error> {
        
        let tokenSubject = authenticator.tokenSubject(withDebugTrace: debugTrace)
        var authenticationCancellable: AnyCancellable?
        
        return tokenSubject
            .flatMap({ token -> AnyPublisher<T, Error> in
                
                if let accessToken = token.accessToken {
                    
                    // flatMap over the CurrentValueSubject to kick off a network call whenever we receive a token
                    
                    return createDataPublisher(for: request, accessToken: accessToken)
                        .mapError({ $0 as Error })
                        .flatMap({ result -> AnyPublisher<T, Error> in
                            
                            if debugTrace {
                                print("RESULT: " + (request.url?.absoluteString ?? "NO URL"))
                            }
                            
                            if let errorPublisher: AnyPublisher<T, Error> = self.checkResultStatus(
                                for: result,
                                token: token,
                                subject: tokenSubject,
                                connectionTimeout: request.timeoutInterval,
                                cancellable: &authenticationCancellable
                            ) {
                                return errorPublisher
                            }
                            
                            let decoder = JSONDecoder()
                            decoder.dateDecodingStrategy = dateDecoding
                            
                            // The standard localizedDescription is too vague:
                            // https://stackoverflow.com/questions/46959625/the-data-couldn-t-be-read-because-it-is-missing-error-when-decoding-json-in-sw/53231548
                            let jsonError: Error!
                            
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
                                 
                            return Fail(outputType: T.self, failure: jsonError)
                                .eraseToAnyPublisher()
                                 
                        })
                        .eraseToAnyPublisher()
                
                } else {
                    // starting with no access token so we need aquire one
                    self.authenticator.refreshToken(
                        using: tokenSubject,
                        connectionTimeout: request.timeoutInterval,
                        cancellable: &authenticationCancellable
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
            .flatMap({ token -> AnyPublisher<Data, Error> in
                
                if let accessToken = token.accessToken {
                    
                    // flatMap over the CurrentValueSubject to kick off a network call whenever we receive a token
                    
                    return createDataPublisher(for: request, accessToken: accessToken)
                        .mapError({ $0 as Error })
                        .flatMap({ result -> AnyPublisher<Data, Error> in
                            
                            if debugTrace {
                                print("RESULT: " + (request.url?.absoluteString ?? "NO URL"))
                            }
                            
                            if let errorPublisher: AnyPublisher<Data, Error> = self.checkResultStatus(
                                for: result,
                                token: token,
                                subject: tokenSubject,
                                connectionTimeout: request.timeoutInterval,
                                cancellable: &authenticationCancellable
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
                        cancellable: &authenticationCancellable
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
    
    private func checkResultStatus<T>(for result: URLSession.DataTaskPublisher.Output, token: NetworkAuthenticator.Token, subject: CurrentValueSubject<NetworkAuthenticator.Token, Error>, connectionTimeout: TimeInterval, cancellable: inout AnyCancellable?) -> AnyPublisher<T, Error>? {
        
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

            if httpResponse.statusCode == 401 || (httpResponse.statusCode == 400 && token.refreshToken != nil) {
            
                // If the result of the data task that’s created in this flatMap has a 401 status code,
                // we do not want to forward this value to subscribers. Instead, we want to pretend we
                // never received this value and kick off a token refresh and subsequently retry the
                // network request.
                self.authenticator.refreshToken(using: subject, connectionTimeout: connectionTimeout, cancellable: &cancellable)
                return Empty().eraseToAnyPublisher()
                
            } else if (200...299).contains(httpResponse.statusCode) == false {
                
                let decoder = JSONDecoder()
                
                if let apiError = try? decoder.decode(APIErrorResult.self, from: result.data) {
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
    
}
